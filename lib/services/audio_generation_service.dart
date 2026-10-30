import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/env.dart';
import 'lyria_service.dart';

class AudioGenerationService {
  final _dio = Dio();

  Future<String> generateVoiceover({
    required String text,
    String voiceId = '21m00Tcm4TlvDq8ikWAM',
    String modelId = 'eleven_multilingual_v2',
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/voiceover_${DateTime.now().millisecondsSinceEpoch}.mp3';

    final response = await _dio.post(
      'https://api.elevenlabs.io/v1/text-to-speech/$voiceId',
      data: {
        'text': text,
        'model_id': modelId,
        'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
      },
      options: Options(
        headers: {'xi-api-key': Env.elevenLabsKey},
        responseType: ResponseType.bytes,
      ),
    );

    await File(outputPath).writeAsBytes(response.data);
    return outputPath;
  }

  Future<String?> generateSoundtrack(String prompt) async {
    if (Env.openRouterKey.isEmpty) return null;
    try {
      final service = LyriaService(Env.openRouterKey);
      final track = await service.generateScore(prompt: prompt);
      return track.audioUrl;
    } catch (_) {
      return null;
    }
  }
}
