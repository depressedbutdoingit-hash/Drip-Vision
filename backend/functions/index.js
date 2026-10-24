const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const stripe = require("stripe")(functions.config().stripe.secret);
const endpointSecret = functions.config().stripe.webhook_secret;

// Stripe webhook — verifies signature and updates user entitlements
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    const uid = session.client_reference_id;
    if (!uid) {
      console.error("No client_reference_id on session");
      return res.status(400).send("Missing uid");
    }

    const priceId = session.metadata?.priceId || session.line_items?.data?.[0]?.price?.id || "";
    let tokensToAdd = 0;
    let tier = "free";

    // Map your actual Stripe Price IDs here
    if (priceId.includes("starter") || priceId === "price_starter_id") {
      tokensToAdd = 300;
      tier = "starter";
    } else if (priceId.includes("pro") || priceId === "price_pro_id") {
      tokensToAdd = 1000;
      tier = "pro";
    } else if (priceId.includes("unlimited")) {
      tokensToAdd = 9999;
      tier = "unlimited";
    }

    const userRef = admin.firestore().collection("users").doc(uid);
    await userRef.set(
      {
        tokenBalance: admin.firestore.FieldValue.increment(tokensToAdd),
        subscriptionTier: tier,
        stripeCustomerId: session.customer,
        lastPayment: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    console.log(`Updated user