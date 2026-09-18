import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String _get(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get openRouterKey => _get('OPENROUTER_KEY');
  static String get falAiKey => _get('FAL_AI_KEY');
  static String get openAiKey => _get('OPENAI_KEY');
  static String get elevenLabsKey => _get('ELEVENLABS_KEY');
  static String get revenueCatIosKey => _get('REVENUECAT_IOS_KEY');
  static String get revenueCatAndroidKey => _get('REVENUECAT_ANDROID_KEY');
  static String get sunoApiKey => _get('SUNO_API_KEY');

  static bool get hasOpenRouter => openRouterKey.isNotEmpty;
}
