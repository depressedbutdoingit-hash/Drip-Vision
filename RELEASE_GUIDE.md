# DripVision - Google Play Store Release Guide

## Prerequisites

- [ ] Google Play Developer account ($25 one-time fee)
- [ ] Keystore file created
- [ ] Stripe account with products / Checkout links
- [ ] Firebase project with Crashlytics enabled
- [ ] OpenRouter API key (primary AI provider)

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

**CRITICAL: Back up `upload-keystore.jks` somewhere safe. If you lose it, you can never update your app.**

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

Never commit this file to git. It is already in `.gitignore`.

---

## Step 3: Configure GitHub Secrets (for CI/CD)

Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret:

| Secret Name | Value |
|---|---|
| `OPENROUTER_KEY` | Your OpenRouter key (required) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID |
| `FAL_AI_KEY` | Optional |
| `OPENAI_KEY` | Optional |
| `ELEVENLABS_KEY` | Optional |
| `SUNO_API_KEY` | Optional |

For release signing in CI (optional):
| `KEYSTORE_BASE64` | `base64 -i android/app/upload-keystore.jks` |
| `STORE_PASSWORD` | Your keystore password |
| `KEY_PASSWORD` | Your key password |

---

## Step 4: Stripe Products & Webhook

1. In the Stripe Dashboard, create products and Checkout payment links.
2. Update the links in `lib/views/screens/plan_screen.dart` if they change.
3. Deploy the Cloud Function that handles the webhook:

```bash
cd backend/functions
npm install
firebase deploy --only functions
```

4. In Stripe Dashboard → Developers → Webhooks, point to your function URL.
5. The function updates user entitlements (`isPro`, token balance, etc.) in Firestore.

---

## Step 5: Set Up Google Play Console

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay the one-time fee and complete identity verification
3. Create app → "DripVision"
4. Fill in store listing, content rating, and privacy policy
5. Monetization is handled by Stripe (not Play Billing), so no in-app products are required unless you later add them

---

## Step 6: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Add Android app with package name: `com.dripvision.app`
3. Download `google-services.json` → place in `android/app/`
4. Enable Crashlytics
5. Deploy Cloud Functions (see Step 4)

---

## Step 7: Build Release AAB

### Option A: Local Build

```bash
chmod +x build_release.sh
./build_release.sh
```

### Option B: GitHub Actions

Push to `main`. The workflow builds a debug APK and deploys the web build. For a signed release AAB, use the local script or extend the workflow with keystore secrets.

---

## Step 8: Upload to Google Play

1. Go to Google Play Console → DripVision → Release
2. Create new release
3. Upload `app-release.aab`
4. Add release notes
5. Start with Internal or Closed Testing
6. Submit for review

---

## Troubleshooting

| Issue | Fix |
|---|---|
| Keystore file not found | Run Step 1, verify path in `local.properties` |
| Stripe webhook not updating users | Check function logs and Stripe webhook secret |
| Crashlytics not reporting | Make sure `google-services.json` is in `android/app/` |
| Build too large | Use `flutter build appbundle` (AAB is smaller than APK) |
| AI generation fails | Confirm `OPENROUTER_KEY` is set and valid |
