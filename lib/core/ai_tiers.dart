/// DripVision subscription → AI routing + generation catalog + credit costs.
///
/// Philosophy: one production stack for *phone footage* and *AI shots*.
/// Continuity is the product. Models are swappable infrastructure.
/// Full free/mid/high menus: see [AiModelCatalog].
import 'ai_model_catalog.dart';

class AiActionCost {
  final int tokens;
  final double usdRetail;
  final double? usdCogs;

  const AiActionCost({
    required this.tokens,
    required this.usdRetail,
    this.usdCogs,
  });

  double? get marginUsd =>
      usdCogs == null ? null : usdRetail - usdCogs!;

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'usdRetail': usdRetail,
        if (usdCogs != null) 'usdCogs': usdCogs,
        if (marginUsd != null) 'marginUsd': marginUsd,
      };
}

/// Image generation quality ladder.
enum ImageGenTier {
  draft,
  standard,
  pro,
  board,
}

/// Video generation quality ladder.
enum VideoGenTier {
  draft,
  pro,
  cinema,
}

class AiTiers {
  AiTiers._();

  // ── Subscription ids ───────────────────────────────────────────────
  static const free = 'free';
  static const starter = 'starter';
  static const pro = 'pro';
  static const studio = 'studio';

  static const double tokenUsdRetail = 0.02;

  static double tokensToUsd(int tokens) => tokens * tokenUsdRetail;

  static AiActionCost costOf(int tokens, {double? usdCogs}) => AiActionCost(
        tokens: tokens,
        usdRetail: tokensToUsd(tokens),
        usdCogs: usdCogs,
      );

  // ── Text / Director models ─────────────────────────────────────────
  static const freeDirector = 'nvidia/nemotron-3-ultra-550b-a55b:free';
  static const freeFast = 'nvidia/nemotron-3.5-lightning:free';
  static const freeRouter = 'openrouter/free';
  static const starterDirector = 'anthropic/claude-haiku-5.5';
  static const proDirector = 'anthropic/claude-sonnet-5.5';
  static const studioDirector = 'anthropic/claude-opus-5.5';

  static String textModelFor(String? subscriptionTier,
      {bool premiumBoost = false}) {
    final t = (subscriptionTier ?? free).toLowerCase().trim();
    if (premiumBoost && (t == pro || t == studio)) return studioDirector;
    switch (t) {
      case starter:
        return starterDirector;
      case pro:
        return proDirector;
      case studio:
        return studioDirector;
      default:
        return freeDirector;
    }
  }

  static int directorPlanTokens(String? tier) {
    switch ((tier ?? free).toLowerCase()) {
      case starter:
        return 8;
      case pro:
        return 5;
      case studio:
        return 3;
      default:
        return 12;
    }
  }

  static AiActionCost directorPlanCost(String? tier) {
    final tokens = directorPlanTokens(tier);
    final t = (tier ?? free).toLowerCase();
    final cogs = switch (t) {
      free => 0.0,
      starter => 0.002,
      pro => 0.025,
      studio => 0.05,
      _ => 0.0,
    };
    return costOf(tokens, usdCogs: cogs);
  }

  static int lightTextTokens(String? tier) => 2;

  static AiActionCost lightTextCost(String? tier) =>
      costOf(lightTextTokens(tier), usdCogs: 0.001);

  // ── IMAGE GENERATION CATALOG ───────────────────────────────────────
  // draft → FLUX schnell-class | standard → FLUX.2 Pro | pro → Max / GPT Image high

  static const imageDraftTokens = 3;
  static const imageStandardTokens = 8;
  static const imageProTokens = 15;
  static const imageStoryboardBoardTokens = 28;

  /// OpenRouter / fal-style model ids by image tier (swap without UI changes).
  static String imageModelId(ImageGenTier tier) {
    switch (tier) {
      case ImageGenTier.draft:
        return 'black-forest-labs/flux-schnell';
      case ImageGenTier.standard:
        return 'black-forest-labs/flux-2-pro';
      case ImageGenTier.pro:
        return 'black-forest-labs/flux-2-max';
      case ImageGenTier.board:
        return 'black-forest-labs/flux-2-pro';
    }
  }

  static double imageCogsUsd(ImageGenTier tier) {
    switch (tier) {
      case ImageGenTier.draft:
        return 0.01;
      case ImageGenTier.standard:
        return 0.04;
      case ImageGenTier.pro:
        return 0.10;
      case ImageGenTier.board:
        return 0.16;
    }
  }

  static int imageTokensFor(ImageGenTier tier) {
    switch (tier) {
      case ImageGenTier.draft:
        return imageDraftTokens;
      case ImageGenTier.standard:
        return imageStandardTokens;
      case ImageGenTier.pro:
        return imageProTokens;
      case ImageGenTier.board:
        return imageStoryboardBoardTokens;
    }
  }

  static AiActionCost imageCostFor(ImageGenTier tier) =>
      costOf(imageTokensFor(tier), usdCogs: imageCogsUsd(tier));

  /// String API kept for existing call sites.
  static int imageTokens(String quality) =>
      imageTokensFor(_parseImageTier(quality));

  static AiActionCost imageCost(String quality) =>
      imageCostFor(_parseImageTier(quality));

  static ImageGenTier _parseImageTier(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'pro':
      case 'cinema':
      case 'poster':
        return ImageGenTier.pro;
      case 'standard':
      case 'storyboard':
      case 'character':
      case 'wardrobe':
        return ImageGenTier.standard;
      case 'board':
      case 'storyboard_board':
        return ImageGenTier.board;
      default:
        return ImageGenTier.draft;
    }
  }

  static bool imageQualityAllowed(String? subscriptionTier, String quality) {
    return imageTierAllowed(subscriptionTier, _parseImageTier(quality));
  }

  static bool imageTierAllowed(String? subscriptionTier, ImageGenTier tier) {
    final t = (subscriptionTier ?? free).toLowerCase().trim();
    switch (tier) {
      case ImageGenTier.draft:
        return true;
      case ImageGenTier.standard:
      case ImageGenTier.board:
        return t == starter || t == pro || t == studio;
      case ImageGenTier.pro:
        return t == pro || t == studio;
    }
  }

  // ── VIDEO GENERATION CATALOG ───────────────────────────────────────
  // draft → Wan / Veo Lite | pro → Kling / Runway | cinema → Veo Standard / flagship

  static const videoDraft5sTokens = 40;
  static const videoPro5sTokens = 90;
  static const videoCinema5sTokens = 160;
  static const videoExtraSecondDraft = 8;
  static const videoExtraSecondPro = 18;
  static const videoExtraSecondCinema = 32;

  /// Primary OpenRouter video model per tier (DripEngine uses these).
  static String videoModelId(VideoGenTier tier) {
    switch (tier) {
      case VideoGenTier.draft:
        return 'alibaba/wan-2.7'; // fast, continuity-friendly I2V
      case VideoGenTier.pro:
        return 'kwaivgi/kling-v3.0-std';
      case VideoGenTier.cinema:
        return 'google/veo-3.1'; // flagship when available on key
    }
  }

  /// Fallback chain if primary is down / rate-limited.
  static List<String> videoModelFallbacks(VideoGenTier tier) {
    switch (tier) {
      case VideoGenTier.draft:
        return const [
          'alibaba/wan-2.7',
          'google/veo-3.1-lite',
          'bytedance/seedance-2.0',
        ];
      case VideoGenTier.pro:
        return const [
          'kwaivgi/kling-v3.0-std',
          'runway/gen-4.5',
          'alibaba/wan-2.7',
        ];
      case VideoGenTier.cinema:
        return const [
          'google/veo-3.1',
          'kwaivgi/kling-v3.0-pro',
          'runway/gen-4.5',
        ];
    }
  }

  static double videoCogsPerSecond(VideoGenTier tier) {
    switch (tier) {
      case VideoGenTier.draft:
        return 0.07;
      case VideoGenTier.pro:
        return 0.12;
      case VideoGenTier.cinema:
        return 0.25;
    }
  }

  static int videoTokensFor({
    required int durationSeconds,
    required VideoGenTier tier,
  }) {
    final secs = durationSeconds.clamp(1, 30);
    final base5 = switch (tier) {
      VideoGenTier.cinema => videoCinema5sTokens,
      VideoGenTier.pro => videoPro5sTokens,
      VideoGenTier.draft => videoDraft5sTokens,
    };
    final extra = switch (tier) {
      VideoGenTier.cinema => videoExtraSecondCinema,
      VideoGenTier.pro => videoExtraSecondPro,
      VideoGenTier.draft => videoExtraSecondDraft,
    };
    if (secs <= 5) return base5;
    return base5 + (secs - 5) * extra;
  }

  static AiActionCost videoCostFor({
    required int durationSeconds,
    required VideoGenTier tier,
  }) {
    final secs = durationSeconds.clamp(1, 30);
    return costOf(
      videoTokensFor(durationSeconds: secs, tier: tier),
      usdCogs: videoCogsPerSecond(tier) * secs,
    );
  }

  static VideoGenTier _parseVideoTier(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'cinema':
        return VideoGenTier.cinema;
      case 'pro':
        return VideoGenTier.pro;
      default:
        return VideoGenTier.draft;
    }
  }

  static int videoTokens({
    required int durationSeconds,
    required String quality,
  }) =>
      videoTokensFor(
        durationSeconds: durationSeconds,
        tier: _parseVideoTier(quality),
      );

  static AiActionCost videoCost({
    required int durationSeconds,
    required String quality,
  }) =>
      videoCostFor(
        durationSeconds: durationSeconds,
        tier: _parseVideoTier(quality),
      );

  static bool videoTierAllowed(String? subscriptionTier, VideoGenTier tier) {
    final t = (subscriptionTier ?? free).toLowerCase().trim();
    switch (tier) {
      case VideoGenTier.draft:
        return true;
      case VideoGenTier.pro:
        return t == starter || t == pro || t == studio;
      case VideoGenTier.cinema:
        return t == pro || t == studio;
    }
  }

  static bool videoQualityAllowed(String? subscriptionTier, String quality) =>
      videoTierAllowed(subscriptionTier, _parseVideoTier(quality));

  // ── Phone media (no AI COGS — local import / capture) ─────────────
  /// Importing phone video into Edit Bay is free (storage only).
  static const phoneImportTokens = 0;

  /// Optional: AI enhance of a phone clip (stabilize/grade assist) — standard text+light.
  static const phoneEnhanceTokens = 5;

  static AiActionCost phoneEnhanceCost() =>
      costOf(phoneEnhanceTokens, usdCogs: 0.01);

  // ── Labels & subscription prices ───────────────────────────────────
  static String tierLabel(String? tier) {
    switch ((tier ?? free).toLowerCase()) {
      case starter:
        return 'STARTER';
      case pro:
        return 'PRO';
      case studio:
        return 'STUDIO';
      default:
        return 'FREE';
    }
  }

  static String imageTierLabel(ImageGenTier t) {
    switch (t) {
      case ImageGenTier.draft:
        return 'DRAFT';
      case ImageGenTier.standard:
        return 'STANDARD';
      case ImageGenTier.pro:
        return 'PRO';
      case ImageGenTier.board:
        return 'BOARD';
    }
  }

  static String videoTierLabel(VideoGenTier t) {
    switch (t) {
      case VideoGenTier.draft:
        return 'DRAFT';
      case VideoGenTier.pro:
        return 'PRO';
      case VideoGenTier.cinema:
        return 'CINEMA';
    }
  }

  static const priceStarterUsd = 14.99;
  static const priceProUsd = 34.99;
  static const priceStudioUsd = 89.99;

  static const includedTokensFree = 30;
  static const includedTokensStarter = 400;
  static const includedTokensPro = 2000;
  static const includedTokensStudio = 8000;

  /// Catalog accessors — free + good models for pickers / fallbacks.
  static List<String> get freeTextModelIds =>
      AiModelCatalog.textFree.map((m) => m.id).toList();
  static List<String> get midTextModelIds =>
      AiModelCatalog.textMid.map((m) => m.id).toList();
  static List<String> get highTextModelIds =>
      AiModelCatalog.textHigh.map((m) => m.id).toList();
  static List<String> get freeImageModelIds =>
      AiModelCatalog.imageFree.map((m) => m.id).toList();
  static List<String> get midImageModelIds =>
      AiModelCatalog.imageMid.map((m) => m.id).toList();
  static List<String> get highImageModelIds =>
      AiModelCatalog.imageHigh.map((m) => m.id).toList();
  static List<String> get freeVideoModelIds =>
      AiModelCatalog.videoFree.map((m) => m.id).toList();
  static List<String> get midVideoModelIds =>
      AiModelCatalog.videoMid.map((m) => m.id).toList();
  static List<String> get highVideoModelIds =>
      AiModelCatalog.videoHigh.map((m) => m.id).toList();
}

