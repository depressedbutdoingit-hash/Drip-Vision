import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_tiers.dart';
import 'drip_engine_service.dart';
import 'image_generation_service.dart';

/// Unified generation — live OpenRouter image + video engine.
class AIGenerationService {
  final DripEngineService _engine;
  final ImageGenerationService _images;

  AIGenerationService({
    DripEngineService? engine,
    ImageGenerationService? images,
  })  : _engine = engine ?? DripEngineService(),
        _images = images ?? ImageGenerationService();

  DripEngineService get engine => _engine;
  ImageGenerationService get images => _images;

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

  String videoModel(VideoGenTier tier, {String? override}) =>
      (override != null && override.isNotEmpty)
          ? override
          : AiTiers.videoModelId(tier);

  List<String> videoFallbacks(VideoGenTier tier) =>
      AiTiers.videoModelFallbacks(tier);

  bool canGenerateVideo(String? subscriptionTier, VideoGenTier tier) =>
      AiTiers.videoTierAllowed(subscriptionTier, tier);

  Future<String> generateVideo({
    required String prompt,
    required String cameraMotion,
    String quality = 'draft',
    int durationSeconds = 5,
    String? subscriptionTier,
    String? modelOverride,
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
    // Full continuity path is DripEngineService.generateNextScene from Studio.
    throw Exception(
      'Use Studio generate with a character for continuity-aware video '
      '(model: ${videoModel(tier, override: modelOverride)}).',
    );
  }

  int tokenCost({
    required int durationSeconds,
    required String quality,
  }) =>
      AiTiers.videoTokens(
        durationSeconds: durationSeconds,
        quality: quality,
      );

  AiActionCost imageCost(String quality) => AiTiers.imageCost(quality);

  AiActionCost imageCostFor(ImageGenTier tier) => AiTiers.imageCostFor(tier);

  String imageModel(ImageGenTier tier, {String? override}) =>
      (override != null && override.isNotEmpty)
          ? override
          : AiTiers.imageModelId(tier);

  bool canGenerateImage(String? subscriptionTier, ImageGenTier tier) =>
      AiTiers.imageTierAllowed(subscriptionTier, tier);

  /// Live OpenRouter image generation.
  Future<String> generateImage({
    required String prompt,
    String quality = 'standard',
    String? subscriptionTier,
    String? modelOverride,
    List<String>? referenceImageUrls,
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
    return _images.generate(
      prompt: prompt,
      tier: tier,
      modelOverride: modelOverride,
      referenceImageUrls: referenceImageUrls,
    );
  }

  AiActionCost get phoneImportCost =>
      AiTiers.costOf(AiTiers.phoneImportTokens, usdCogs: 0);

  AiActionCost get phoneEnhanceCost => AiTiers.phoneEnhanceCost();
}
