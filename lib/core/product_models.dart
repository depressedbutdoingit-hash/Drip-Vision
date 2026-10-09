import 'ai_model_catalog.dart';

/// The *product* model stack for DripVision — best free + best paid for
/// Director / continuity / cinematic image / continuity-aware video.
///
/// Full menu: [AiModelCatalog]. Costs & subscription gates: [AiTiers].
class ProductModels {
  ProductModels._();

  // ── TEXT ───────────────────────────────────────────────────────────
  /// Best free Director (film plan JSON, character bible).
  static const textFree = 'nvidia/nemotron-3-ultra-550b-a55b:free';

  /// Free volume / rate-limit escape hatch.
  static const textFreeFast = 'nvidia/nemotron-3.5-lightning:free';

  /// Free vision when reference frames are in context.
  static const textFreeVision = 'google/gemma-4-31b-it:free';

  /// Best paid value — Starter Director.
  static const textMid = 'anthropic/claude-haiku-5.5';

  /// Best paid creative Director — Pro.
  static const textHigh = 'anthropic/claude-sonnet-5.5';

  /// Best paid max — Studio / premium boost.
  static const textFlagship = 'anthropic/claude-opus-5.5';

  // ── IMAGE ──────────────────────────────────────────────────────────
  static const imageDraft = 'black-forest-labs/flux-schnell';
  static const imageStandard = 'black-forest-labs/flux-2-pro';
  static const imagePro = 'black-forest-labs/flux-2-max';

  // ── VIDEO ──────────────────────────────────────────────────────────
  static const videoDraft = 'alibaba/wan-2.7';
  static const videoPro = 'kwaivgi/kling-v3.0-std';
  static const videoCinema = 'google/veo-3.1';

  static const List<String> videoDraftFallbacks = [
    videoDraft,
    'google/veo-3.1-lite',
    'bytedance/seedance-2.0',
  ];

  static const List<String> videoProFallbacks = [
    videoPro,
    'runway/gen-4.5',
    videoDraft,
  ];

  static const List<String> videoCinemaFallbacks = [
    videoCinema,
    'kwaivgi/kling-v3.0-pro',
    'runway/gen-4.5',
  ];

  static String imageForName(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'pro':
      case 'cinema':
      case 'poster':
        return imagePro;
      case 'standard':
      case 'storyboard':
      case 'character':
      case 'wardrobe':
      case 'board':
      case 'storyboard_board':
        return imageStandard;
      default:
        return imageDraft;
    }
  }

  static String videoForName(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'cinema':
        return videoCinema;
      case 'pro':
        return videoPro;
      default:
        return videoDraft;
    }
  }

  static List<CatalogModel> showcaseFree() => [
        for (final id in [textFree, textFreeFast, imageDraft, videoDraft])
          if (AiModelCatalog.byId(id) != null) AiModelCatalog.byId(id)!,
      ];

  static List<CatalogModel> showcasePaid() => [
        for (final id in [
          textMid,
          textHigh,
          textFlagship,
          imageStandard,
          imagePro,
          videoPro,
          videoCinema,
        ])
          if (AiModelCatalog.byId(id) != null) AiModelCatalog.byId(id)!,
      ];
}
