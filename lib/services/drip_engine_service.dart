import 'package:dio/dio.dart';
import '../core/env.dart';
import '../models/character.dart';
import '../models/scene.dart';

class DripEngineException implements Exception {
  final String message;
  DripEngineException(this.message);
  @override
  String toString() => message;
}

class DripEngineService {
  final Dio _dio;

  DripEngineService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://fal.run/',
            headers: {'Authorization': 'Key ${Env.falAiKey}'},
            connectTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 5),
          ),
        );

  Future<SceneNode> generateNextScene({
    required SceneNode? previousScene,
    required String rawPrompt,
    required String enhancedPrompt,
    required Character character,
    String? cameraMotion,
    void Function(double)? onProgress,
  }) async {
    final activeOutfit = character.activeOutfit;
    final fullPrompt = "${character.name}, wearing ${activeOutfit.description}, $enhancedPrompt"
        "${cameraMotion != null ? '. Camera motion: $cameraMotion' : ''}";

    try {
      final response = await _dio.post(
        'fal-ai/wan/v2.1/image-to-video',
        data: {
          'prompt': fullPrompt,
          if (previousScene?.generatedLastFrameUrl != null)
            'image_url': previousScene!.generatedLastFrameUrl,
          // A character can genuinely have no photo yet — that's a real,
          // valid state (not an error), so this just omits the identity
          // lock rather than crashing on .first of an empty list.
          if (character.faceReferenceUrls.isNotEmpty)
            'ip_adapter_image_url': character.faceReferenceUrls.first,
          'num_frames': 81,
          'aspect_ratio': '16:9',
          'guidance_scale': 7.5,
        },
        onSendProgress: (s, t) => onProgress?.call(t > 0 ? s / t * 0.3 : 0),
        onReceiveProgress: (r, t) => onProgress?.call(t > 0 ? 0.3 + (r / t * 0.7) : 0.3),
      );

      return SceneNode(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sequenceIndex: (previousScene?.sequenceIndex ?? -1) + 1,
        prompt: rawPrompt,
        enhancedPrompt: enhancedPrompt,
        character: character,
        inputLastFrameUrl: previousScene?.generatedLastFrameUrl,
        outputVideoUrl: response.data['video']['url'],
        generatedLastFrameUrl: response.data['last_frame_url'],
        cameraMotion: cameraMotion,
      );
    } on DioException catch (e) {
      throw DripEngineException(
        'Generation failed: ${e.response?.data?['detail'] ?? e.message}',
      );
    }
  }
}
