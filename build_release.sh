#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════"
echo "  DripVision - Google Play Release Builder"
echo "═══════════════════════════════════════════════════"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "${RED}Flutter not found. Install it first.${NC}"
    exit 1
fi

# Check if keystore exists
if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo "${YELLOW}⚠️  Keystore not found at android/app/upload-keystore.jks${NC}"
    echo "   Run this first to create one:"
    echo "   keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
    echo ""
    echo "   Then add to android/local.properties:"
    echo "   storeFile=upload-keystore.jks"
    echo "   storePassword=YOUR_STORE_PASSWORD"
    echo "   keyPassword=YOUR_KEY_PASSWORD"
    echo "   keyAlias=upload"
    exit 1
fi

# Check if local.properties has signing info
if ! grep -q "storePassword" android/local.properties; then
    echo "${RED}⚠️  Signing config missing in android/local.properties${NC}"
    exit 1
fi

# Get version
VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "${GREEN}📦 Building DripVision v$VERSION${NC}"

# Clean
echo "🧹 Cleaning..."
flutter clean

# Get dependencies
echo "📥 Installing dependencies..."
flutter pub get

# Run tests
echo "🧪 Running tests..."
flutter test || true

# Build release AAB with dart-define for API keys
echo "🔨 Building release AAB..."
flutter build appbundle \
  --release \
  --dart-define=OPENROUTER_KEY="${OPENROUTER_KEY:-your_openrouter_key_here}" \
  --dart-define=FAL_AI_KEY="${FAL_AI_KEY:-}" \
  --dart-define=OPENAI_KEY="${OPENAI_KEY:-}" \
  --dart-define=ELEVENLABS_KEY="${ELEVENLABS_KEY:-}" \
  --dart-define=REVENUECAT_ANDROID_KEY="${REVENUECAT_ANDROID_KEY:-}"

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
    echo ""
    echo "${GREEN}✅ BUILD SUCCESSFUL${NC}"
    echo "📁 AAB location: $AAB_PATH"
    echo "📊 File size: $(du -h $AAB_PATH | cut -f1)"
    echo ""
    echo "${YELLOW}Next steps:${NC}"
    echo "  1. Go to https://play.google.com/console"
    echo "  2. Create release → Upload $AAB_PATH"
    echo "  3. Add release notes and rollout"
else
    echo "${RED}❌ BUILD FAILED${NC}"
    exit 1
fi
