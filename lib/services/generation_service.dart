import 'drip_engine_service.dart';
import '../models/scene.dart';

/// Thin wrapper that routes generation through the real DripEngineService
/// (OpenRouter). Prefer AIGenerationService / DripEngineService directly
/// in new code.
class GenerationService {
  static final _engine = DripEngineService();

  /// Returns the generated video URL, or null on failure.
  static Future<String?> generate({
    required String prompt,
    String type = 'video',
    Map<String, dynamic>? characterDna,
    String style = 'cinematic',
  }) async {
    try {
      final scene = await _engine.generateNextScene(
        previousScene: null,
        prompt: prompt,
        cameraMotion: 'slow push-in',
        style: style,
      );
      return scene.videoUrl;
    } catch (_) {
      return null;
    }
  }
}