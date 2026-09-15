import 'package:dio/dio.dart';
import '../core/env.dart';

class AIQueueService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://queue.fal.run/',
    headers: {'Authorization': 'Key ${Env.falAiKey}'},
  ));

  Future<String> submitVideoGeneration({
    required String prompt,
    required String imageUrl,
  }) async {
    final response = await _dio.post(
      'fal-ai/wan/v2.1/image-to-video',
      data: {
        'prompt': prompt,
        'image_url': imageUrl,
      },
    );
    return response.data['request_id'] as String;
  }

  Future<String?> checkVideoStatus(String requestId) async {
    const maxRetries = 20;
    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final response = await _dio.get('fal-ai/wan/v2.1/requests/$requestId/status');
      final status = response.data['status'];

      if (status == 'COMPLETED') {
        final resultResponse = await _dio.get('fal-ai/wan/v2.1/requests/$requestId');
        return resultResponse.data['video']['url'] as String;
      } else if (status == 'FAILED') {
        throw Exception("Generation failed on Fal Engine");
      }
    }
    return null;
  }
}
