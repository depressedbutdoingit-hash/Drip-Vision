import 'dart:convert';
import 'dart:typed_data';
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
      responseType: ResponseType.json,
    ));
  }

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

  Future<Uint8List> speak({
    required String text,
    String voice = 'sarah',
    String model = 'elevenlabs/eleven-v4',
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing.');
    }
    final response = await _dio.post(
      'audio/speech',
      data: {
        'model': model,
        'input': text,
        'voice': voice,
        'response_format': 'mp3',
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  /// Stateless voice clone via Fish Audio on OpenRouter.
  Future<Uint8List> cloneSpeak({
    required String text,
    required Uint8List sampleBytes,
    required String sampleTranscript,
    String model = 'fish-audio/s2.1-pro',
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing.');
    }
    final b64 = base64Encode(sampleBytes);
    final response = await _dio.post(
      'audio/speech',
      data: {
        'model': model,
        'input': text,
        'response_format': 'mp3',
        'input_references': [
          {
            'type': 'input_audio',
            'input_audio': {'data': 'data:audio/wav;base64,$b64'},
          },
          {
            'type': 'text',
            'text': sampleTranscript,
          },
        ],
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }
}

class EnhancedPromptResult {
  final String text;
  final ApiCallResult cost;

  EnhancedPromptResult({required this.text, required this.cost});
}
