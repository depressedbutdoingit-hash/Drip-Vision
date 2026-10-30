import 'package:dio/dio.dart';
import '../core/env.dart';

/// Simple OpenRouter video generation (non-continuity path).
class AiVideoService {
  final Dio _dio;

  AiVideoService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://openrouter.ai/api/v1/',
            headers: {
              'Authorization': 'Bearer ${Env.openRouterKey}',
              'HTTP-Referer': 'https://dripvision.app',
              'X-Title': 'DripVision',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 10),
          ),
        );

  Future<String?> generateVideo({
    required String prompt,
    String? characterDna,
    String style = 'cinematic',
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing.');
    }

    final fullPrompt = characterDna != null && characterDna.isNotEmpty
        ? '$characterDna. $prompt. Style: $style'
        : '$prompt. Style: $style';

    try {
      final submit = await _dio.post('videos', data: {
        'model': 'alibaba/wan-2.7',
        'prompt': fullPrompt,
        'duration': 5,
        'resolution': '720p',
        'aspect_ratio': '16:9',
      });

      final jobId = submit.data['id'] as String?;
      if (jobId == null) return null;

      // Poll until complete (simplified)
      for (var i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 10));
        final statusResp = await _dio.get('videos/$jobId');
        final status = statusResp.data['status'] as String?;
        if (status == 'completed') {
          final urls = statusResp.data['unsigned_urls'] as List?;
          if (urls != null && urls.isNotEmpty) {
            return urls.first as String;
          }
          return 'https://openrouter.ai/api/v1/videos/$jobId/content?index=0';
        }
        if (status == 'failed' || status == 'cancelled') return null;
      }
    } catch (e) {
      // Fall through
    }
    return null;
  }
}
