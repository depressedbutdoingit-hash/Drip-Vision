# DripVision

Next-Gen AI Video Studio with scene continuity, character closets, and Grok-style photorealistic prompting.

## Getting Started

1. Copy `.env.example` to `.env` and fill in your API keys
2. Run `flutter pub get`
3. Connect Firebase (Auth, Firestore, Cloud Messaging)
4. Configure RevenueCat with your product IDs
5. Run `flutter run`

## Architecture

- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, FCM)
- **AI APIs**: Fal.ai, OpenRouter, OpenAI (Whisper), ElevenLabs
- **Payments**: RevenueCat
- **CI/CD**: GitHub Actions

## Features

- Grok-Style Prompt Enhancer
- Character Closet & Outfit Swapping
- Scene Continuity Engine
- Camera Motion Joystick
- Voice Prompting (Whisper)
- AI Voiceover (ElevenLabs)
- Token-Based Generation Gating
- Admin God Mode
- Shorebird Code Push
- Explore Drip Social Feed

## Shipathon-ready workflow

The UI redesign preserves the existing Riverpod/Firebase/generation architecture and adds a premium filmmaking workspace around it. GitHub Actions is configured in `.github/workflows/flutter.yml` to run analysis/tests and an Android release build check on pushes and pull requests.

### CI secrets
Configure these repository secrets when the corresponding services are used in CI: `OPENROUTER_KEY`, `FAL_AI_KEY`, `OPENAI_KEY`, `ELEVENLABS_KEY`, and `SUNO_API_KEY`.
