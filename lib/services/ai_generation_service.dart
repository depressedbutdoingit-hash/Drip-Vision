import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_tiers.dart';
import 'drip_engine_service.dart';

/// Unified generation entry — image + video tiers, costs, model routing.
/// Phone imports stay free; AI generation always goes through [AiTiers] costs.
class AIGenerationService {
  final DripEngineService? _engine;

  AIGenerationService({DripEngineService? engine}) : _engine = engine;

  // ── Video ──────────────────────────────────────────────────────────

  AiActionCost videoCost({
    required int durationSeconds,
    required String quality,
  }) =>
      AiTiers.videoCost(
        durationSeconds: durationSeconds,
        quality: quality,
      );

  AiActionCost videoCostFor({
    required int durationSeconds,
    required VideoGenTier tier,
  }) =>
      AiTiers.videoCostFor(
        durationSeconds: durationSeconds,
        tier: tier,
      );

  String videoModel(VideoGenTier tier) => AiTiers.videoModelId(tier);

  List<String> videoFallbacks(VideoGenTier tier) =>
      AiTiers.videoModelFallbacks(tier);

  bool canGenerateVideo(String? subscriptionTier, VideoGenTier tier) =>
      AiTiers.videoTierAllowed(subscriptionTier, tier);

  /// Stub until OpenRouter/provider keys are live for all models.
  /// Prefer [DripEngineService.generateNextScene] for continuity-aware shots.
  Future<String> generateVideo({
    required String prompt,
    required String cameraMotion,
    String quality = 'draft',
    int durationSeconds = 5,
    String? subscriptionTier,
  }) async {
    final tier = quality.toLowerCase() == 'cinema'
        ? VideoGenTier.cinema
        : quality.toLowerCase() == 'pro'
            ? VideoGenTier.pro
            : VideoGenTier.draft;
    if (!canGenerateVideo(subscriptionTier, tier)) {
      throw Exception(
        'Upgrade required for ${AiTiers.videoTierLabel(tier)} video.',
      );
    }
    // Engine path when available (character + last-frame continuity)
    if (_engine != null) {
      // Callers with full scene context should use DripEngineService directly.
    }
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/generated_video.mp4';
  }

  int tokenCost({
    required int durationSeconds,
    required String quality,
  }) =>
      AiTiers.videoTokens(
        durationSeconds: durationSeconds,
        quality: quality,
      );

  // ── Image ──────────────────────────────────────────────────────────

  AiActionCost imageCost(String quality) => AiTiers.imageCost(quality);

  AiActionCost imageCostFor(ImageGenTier tier) => AiTiers.imageCostFor(tier);

  String imageModel(ImageGenTier tier) => AiTiers.imageModelId(tier);

  bool canGenerateImage(String? subscriptionTier, ImageGenTier tier) =>
      AiTiers.imageTierAllowed(subscriptionTier, tier);

  /// Stub image gen — wire FLUX / GPT Image via OpenRouter or fal next.
  Future<String> generateImage({
    required String prompt,
    String quality = 'standard',
    String? subscriptionTier,
  }) async {
    final tier = quality.toLowerCase().contains('pro') ||
            quality.toLowerCase().contains('poster')
        ? ImageGenTier.pro
        : quality.toLowerCase().contains('draft')
            ? ImageGenTier.draft
            : quality.toLowerCase().contains('board')
                ? ImageGenTier.board
                : ImageGenTier.standard;
    if (!canGenerateImage(subscriptionTier, tier)) {
      throw Exception(
        'Upgrade required for ${AiTiers.imageTierLabel(tier)} images.',
      );
    }
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/generated_image.png';
  }

  // ── Phone ──────────────────────────────────────────────────────────

  /// Local import is free.
  AiActionCost get phoneImportCost =>
      AiTiers.costOf(AiTiers.phoneImportTokens, usdCogs: 0);

  AiActionCost get phoneEnhanceCost => AiTiers.phoneEnhanceCost();
}

final aiGenerationServiceProvider = Provider(
  (ref) => AIGenerationService(engine: DripEngineService()),
);
