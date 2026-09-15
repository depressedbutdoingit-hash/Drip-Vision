import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openRouterKey => dotenv.env['OPENROUTER_KEY'] ?? '';
  static String get falAiKey => dotenv.env['FAL_AI_KEY'] ?? '';
  static String get openAiKey => dotenv.env['OPENAI_KEY'] ?? '';
  static String get elevenLabsKey => dotenv.env['ELEVENLABS_KEY'] ?? '';
  static String get revenueCatIosKey => dotenv.env['REVENUECAT_IOS_KEY'] ?? '';
  static String get revenueCatAndroidKey => dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';
  static String get sunoApiKey => dotenv.env['SUNO_API_KEY'] ?? '';
}
