const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.revenuecatWebhook = functions.https.onRequest(async (req, res) => {
  const event = req.body.event;
  const userId = event.app_user_id;
  const type = event.type;

  const userRef = admin.firestore().collection("users").doc(userId);

  if (type === "INITIAL_PURCHASE" || type === "RENEWAL") {
    let tokensToAdd = 0;
    if (event.product_id.includes("starter")) tokensToAdd = 300;
    if (event.product_id.includes("pro")) tokensToAdd = 1000;

    await userRef.set(
      {
        tokenBalance: admin.firestore.FieldValue.increment(tokensToAdd),
        subscriptionTier: event.product_id.includes("pro") ? "pro" : "starter",
      },
      { merge: true }
    );
  }

  if (type === "CANCELLATION" || type === "EXPIRATION") {
    await userRef.set(
      {
        subscriptionTier: "free",
      },
      { merge: true }
    );
  }

  res.status(200).send({ success: true });
});

exports.monthlyTokenRefill = functions.pubsub.schedule("0 0 1 * *")
  .timeZone("America/New_York")
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("subscriptionTier", "in", ["starter", "pro"])
      .get();

    const batch = admin.firestore().batch();
    usersSnapshot.forEach((doc) => {
      const tier = doc.data().subscriptionTier;
      const refill = tier === "pro" ? 1000 : 300;
      batch.update(doc.ref, {
        tokenBalance: admin.firestore.FieldValue.increment(refill),
        lastFreeClaimDate: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    console.log(`Refilled tokens for ${usersSnapshot.size} subscribers`);
  });
