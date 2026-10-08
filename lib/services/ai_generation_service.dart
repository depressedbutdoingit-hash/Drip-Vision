import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_tiers.dart';

class AIGenerationService {
  /// Stub video gen — swap for FAL / Kling / Veo when keys are live.
  Future<String> generateVideo({
    required String prompt,
    required String cameraMotion,
    String quality = 'draft', // draft | pro | cinema
    int durationSeconds = 5,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/generated_video.mp4';
  }

  /// Customer-facing app-token cost for a shot.
  int tokenCost({
    required int durationSeconds,
    required String quality,
  }) =>
      AiTiers.videoTokens(
        durationSeconds: durationSeconds,
        quality: quality,
      );
}

final aiGenerationServiceProvider = Provider((ref) => AIGenerationService());
