# DripVision - Google Play Store Release Guide

## Prerequisites

- [ ] Google Play Developer account ($25 one-time fee)
- [ ] Keystore file created
- [ ] RevenueCat account with products configured
- [ ] Firebase project with Crashlytics enabled

---

## Step 1: Create Your Signing Keystore

Run this ONCE and back up the file securely:

```bash
cd android/app
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You will be prompted for:
- Keystore password (save this!)
- Key password (can be same as keystore)
- Your name/organization

**⚠️ CRITICAL: Back up `upload-keystore.jks` somewhere safe (Google Drive, USB, etc.). If you lose it, you can never update your app.**

---

## Step 2: Configure Signing

Create `android/local.properties` and add:

```properties
flutter.sdk=/path/to/your/flutter
storeFile=upload-keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
```

**Never commit this file to git.** It's already in `.gitignore`.

---

## Step 3: Configure GitHub Secrets (for CI/CD)

Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret:

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -i android/app/upload-keystore.jks` |
| `STORE_PASSWORD` | Your keystore password |
| `KEY_PASSWORD` | Your key password |
| `OPENROUTER_KEY` | `your_openrouter_key_here` |
| `FAL_AI_KEY` | Your Fal.ai key |
| `OPENAI_KEY` | Your OpenAI key |
| `ELEVENLABS_KEY` | Your ElevenLabs key |
| `REVENUECAT_ANDROID_KEY` | Your RevenueCat Android public API key |

---

## Step 4: Set Up RevenueCat Products

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create an app → Select Android
3. Add products:
   - `drip_starter_monthly` (Subscription)
   - `drip_pro_monthly` (Subscription)
   - `tokens_100_pack` (Consumable)
4. Create entitlement `pro`
5. Attach `drip_pro_monthly` to `pro` entitlement
6. Copy Android public API key to `.env`

---

## Step 5: Set Up Google Play Console

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay $25 one-time fee
3. Complete identity verification
4. Create app → "DripVision"
5. Go to **Monetize → Products → Subscriptions**
6. Create the same 3 products with **matching IDs** from RevenueCat
7. Set pricing and billing period
8. Go to **Monetize → Products → In-app products** for the token pack

---

## Step 6: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Add Android app with package name: `com.dripvision.app`
3. Download `google-services.json` → place in `android/app/`
4. Enable **Crashlytics** in Firebase Console
5. Deploy Cloud Functions:

```bash
cd backend/functions
npm install
firebase deploy --only functions
```

6. In RevenueCat dashboard → **Webhooks** → Add:
   - URL: `https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/revenuecatWebhook`
   - Events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`

---

## Step 7: Build Release AAB

### Option A: Local Build

```bash
chmod +x build_release.sh
./build_release.sh
```

### Option B: GitHub Actions (Automated)

Push to `main` branch. GitHub Actions will:
1. Run tests
2. Build signed AAB
3. Upload artifact

Download the AAB from Actions → Artifacts.

---

## Step 8: Upload to Google Play

1. Go to Google Play Console → DripVision → Release
2. Create new release
3. Upload `app-release.aab`
4. Add release notes
5. Set up **Closed Testing** track first (recommended)
6. Add testers via email
7. Submit for review

---

## Step 9: Internal Testing (Before Public)

1. Go to **Testing → Internal testing**
2. Upload your AAB
3. Add your email as tester
4. Join the test via the link
5. Make a test purchase (uses test cards, no real money)
6. Verify tokens are added to Firestore

---

## Step 10: Go Live

Once internal testing works:
1. Move to **Closed testing** → **Open testing** → **Production**
2. Each step requires Google review (1-3 days)
3. Production release = anyone can find and install

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `Keystore file not found` | Run Step 1, verify path in `local.properties` |
| `RevenueCat products not found` | IDs must match exactly between Play Console and RevenueCat |
| `Crashlytics not reporting` | Make sure `google-services.json` is in `android/app/` |
| `Build too large` | Run `flutter build appbundle` (not apk) — AAB is smaller |
| `Test purchase fails` | Add your Google account to License Testing in Play Console |

---

## RevenueCat Shipathon

To be eligible for RevenueCat's Shipathon or similar competitions:

1. ✅ **SDK integrated** (done)
2. ⬜ **App published** on Google Play (do Step 8-10)
3. ⬜ **RevenueCat dashboard** configured with real products
4. ⬜ **At least one test purchase** completed
5. ⬜ **Submit entry** at [revenuecat.com/ship](https://www.revenuecat.com/ship) or similar

Having the SDK alone doesn't qualify — the app must be live on a store with working purchases.
