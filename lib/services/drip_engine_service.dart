import 'package:dio/dio.dart';
import '../core/env.dart';
import '../core/ai_tiers.dart';
import '../models/character.dart';
import '../models/scene.dart';

class DripEngineException implements Exception {
  final String message;
  DripEngineException(this.message);
  @override
  String toString() => message;
}

/// Generates videos through OpenRouter's unified video API.
/// Uses only the OPENROUTER_KEY so no separate Fal key is required.
class DripEngineService {
  final Dio _dio;

  /// Default model — strong quality and good image-to-video support.
  /// Other good options: 'bytedance/seedance-2.0', 'google/veo-3.1-lite',
  /// 'alibaba/wan-2.6', 'kwaivgi/kling-v3.0-std'
  static const String defaultModel = 'alibaba/wan-2.7';

  DripEngineService()
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

  Future<SceneNode> generateNextScene({
    required SceneNode? previousScene,
    required String rawPrompt,
    required String enhancedPrompt,
    required Character character,
    String? cameraMotion,
    void Function(double)? onProgress,
    String? model,
    VideoGenTier tier = VideoGenTier.draft,
  }) async {
    model ??= AiTiers.videoModelId(tier);
    if (Env.openRouterKey.isEmpty) {
      throw DripEngineException(
        'OPENROUTER_KEY is missing. Add it to your .env file.',
      );
    }

    // Prefer selected model, then product fallbacks for this tier.
    final modelCandidates = <String>[
      model!,
      ...AiTiers.videoModelFallbacks(tier).where((m) => m != model),
    ];

    final activeOutfit = character.activeOutfit;
    final outfitDescription = activeOutfit?.description ??
        (character.wardrobeDNA.isNotEmpty ? character.wardrobeDNA.join(', ') : 'their established look');
    final fullPrompt =
        '${character.name}, wearing $outfitDescription, $enhancedPrompt'
        '${cameraMotion != null ? '. Camera motion: $cameraMotion' : ''}';

    // Build frame_images for continuity (previous last frame becomes first frame)
    final List<Map<String, dynamic>> frameImages = [];
    final previousFrame = previousScene?.generatedLastFrameUrl ??
        previousScene?.outputVideoUrl;
    if (previousFrame != null && previousFrame.startsWith('http')) {
      frameImages.add({
        'type': 'image_url',
        'image_url': {'url': previousFrame},
        'frame_type': 'first_frame',
      });
    }

    // Character face as style/identity reference when available
    final List<Map<String, dynamic>> inputReferences = [];
    if (character.faceReferenceUrls.isNotEmpty) {
      final faceUrl = character.faceReferenceUrls.first;
      if (faceUrl.startsWith('http')) {
        inputReferences.add({
          'type': 'image_url',
          'image_url': {'url': faceUrl},
        });
      }
    }

    final payload = <String, dynamic>{
      'model': modelCandidates.first,
      'prompt': fullPrompt,
      'duration': 5,
      'resolution': '720p',
      'aspect_ratio': '16:9',
      'generate_audio': false,
      if (frameImages.isNotEmpty) 'frame_images': frameImages,
      if (inputReferences.isNotEmpty) 'input_references': inputReferences,
    };

    Object? lastError;
    for (var i = 0; i < modelCandidates.length; i++) {
      final candidate = modelCandidates[i];
      payload['model'] = candidate;
      try {
        onProgress?.call(0.05 + (i * 0.02));

        final submitResponse = await _dio.post('videos', data: payload);
        final job = submitResponse.data as Map<String, dynamic>;
        final jobId = job['id'] as String?;
        final pollingUrl = job['polling_url'] as String?;

        if (jobId == null) {
          throw DripEngineException('OpenRouter did not return a job id.');
        }

        onProgress?.call(0.15);

        final completed = await _pollUntilDone(
          jobId: jobId,
          pollingUrl: pollingUrl,
          onProgress: onProgress,
        );

        final unsignedUrls = completed['unsigned_urls'] as List?;
        String? videoUrl;
        if (unsignedUrls != null && unsignedUrls.isNotEmpty) {
          videoUrl = unsignedUrls.first as String;
        } else {
          videoUrl =
              'https://openrouter.ai/api/v1/videos/$jobId/content?index=0';
        }

        onProgress?.call(1.0);

        return SceneNode(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sequenceIndex: (previousScene?.sequenceIndex ?? -1) + 1,
          prompt: rawPrompt,
          enhancedPrompt: enhancedPrompt,
          character: character,
          inputLastFrameUrl: previousScene?.generatedLastFrameUrl,
          outputVideoUrl: videoUrl,
          generatedLastFrameUrl: null,
          cameraMotion: cameraMotion,
        );
      } on DioException catch (e) {
        final detail = e.response?.data;
        final message = detail is Map
            ? (detail['error']?['message'] ?? detail['message'] ?? e.message)
            : e.message;
        lastError = '[$candidate] $message';
        // Try next fallback
        continue;
      } catch (e) {
        if (e is DripEngineException) {
          lastError = '[$candidate] ${e.message}';
          continue;
        }
        lastError = '[$candidate] $e';
        continue;
      }
    }
    throw DripEngineException(
      'Generation failed after ${modelCandidates.length} model(s): $lastError',
    );
  }

  Future<Map<String, dynamic>> _pollUntilDone({
    required String jobId,
    String? pollingUrl,
    void Function(double)? onProgress,
  }) async {
    const maxAttempts = 60;
    const interval = Duration(seconds: 10);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await Future.delayed(interval);

      final url = pollingUrl ?? 'videos/$jobId';
      final response = await _dio.get(url);
      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'unknown';

      final progress = 0.15 + (attempt / maxAttempts) * 0.80;
      onProgress?.call(progress.clamp(0.0, 0.95));

      if (status == 'completed') {
        return data;
      }
      if (status == 'failed' || status == 'cancelled' || status == 'expired') {
        final error = data['error'] ?? status;
        throw DripEngineException('Video job $status: $error');
      }
    }

    throw DripEngineException(
      'Video generation timed out after ${maxAttempts * interval.inSeconds} seconds.',
    );
  }
}