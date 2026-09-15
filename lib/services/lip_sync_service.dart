import 'package:dio/dio.dart';
import '../core/env.dart';

class LipSyncService {
  final _dio = Dio();

  Future<String> syncLips({
    required String videoUrl,
    required String audioUrl,
  }) async {
    final response = await _dio.post(
      'https://fal.run/fal-ai/wav2lip',
      data: {
        'video_url': videoUrl,
        'audio_url': audioUrl,
      },
      options: Options(
        headers: {'Authorization': 'Key ${Env.falAiKey}'},
        contentType: 'application/json',
      ),
    );

    return response.data['video']['url'] as String;
  }
}
