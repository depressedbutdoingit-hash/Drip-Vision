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
}

class EnhancedPromptResult {
  final String text;
  final ApiCallResult cost;

  EnhancedPromptResult({required this.text, required this.cost});
}
