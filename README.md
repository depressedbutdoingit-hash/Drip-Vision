# DripVision

Next-Gen AI Video Studio with scene continuity, character closets, and cinematic prompting.

## Getting Started

1. Copy `.env.example` to `.env` and fill in your keys (at minimum `OPENROUTER_KEY`)
2. Run `flutter pub get`
3. Connect Firebase (Auth, Firestore, Cloud Messaging)
4. Run `flutter run`

Payments use **Stripe** (Checkout links + webhook). AI calls primarily go through **OpenRouter**.

## Architecture

- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, FCM)
- **AI**: OpenRouter (video, image, text). Optional secondary: Fal, ElevenLabs, Suno
- **Payments**: Stripe
- **CI/CD**: GitHub Actions → Cloudflare Workers (web) + debug APK

## Features

- Cinematic prompt enhancement
- Character Closet & Outfit Swapping
- Scene Continuity Engine
- Camera Motion Joystick
- Voice Prompting
- AI Voiceover
- Token-Based Generation Gating
- Admin God Mode
- Shorebird Code Push
- Explore Drip Social Feed
- Ad Generator (script + image)

## Payments (Stripe)

- Plans screen opens Stripe Checkout links
- Backend Cloud Function (`backend/functions/index.js`) handles the Stripe webhook and updates user entitlements in Firestore
- Paywall redirects to the plans screen

## AI (OpenRouter)

Most generation (video via `DripEngineService`, text via `OpenRouterService`, Ad Generator) uses a single `OPENROUTER_KEY`. Secondary keys are optional and only needed for legacy paths.

## CI secrets

Configure these repository secrets as needed:
- Required: `OPENROUTER_KEY`
- Deploy: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
- Optional: `FAL_AI_KEY`, `OPENAI_KEY`, `ELEVENLABS_KEY`, `SUNO_API_KEY`

## Cloudflare Workers (Web)

```bash
flutter build web --release
```

The workflow deploys the `build/web` output via Wrangler.
