import 'package:dio/dio.dart';
import '../core/env.dart';
import 'cost_tracking_service.dart';

class OpenRouterService {
  late final Dio _dio;

  OpenRouterService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1/',
      headers: {
        'Authorization': 'Bearer ${Env.openRouterKey}',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Enhances a prompt and returns both the enhanced text and cost info.
  Future<EnhancedPromptResult> enhancePrompt({
    required String prompt,
    required String modelSlug,
  }) async {
    final response = await _dio.post(
      'chat/completions',
      data: {
        'model': modelSlug,
        'messages': [
          {
            'role': 'system',
            'content': 'Rewrite into cinematic camera motion, lighting, and composition. Keep under 200 words.'
          },
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      },
    );

    final costResult = CostTrackingService.parseAndCharge(
      callType: 'prompt_enhance',
      model: modelSlug,
      responseData: response.data as Map<String, dynamic>,
    );

    return EnhancedPromptResult(
      text: response.data['choices'][0]['message']['content'] as String,
      cost: costResult,
    );
  }

  /// Simple text generation for ad scripts and other short copy.
  Future<String> generateText(String prompt, {String model = 'openai/gpt-4o-mini'}) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing.');
    }
    final response = await _dio.post(
      'chat/completions',
      data: {
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a concise creative copywriter for short-form ads.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      },
    );
    return response.data['choices'][0]['message']['content'] as String;
  }
}

class EnhancedPromptResult {
  final String text;
  final ApiCallResult cost;

  EnhancedPromptResult({required this.text, required this.cost});
}
