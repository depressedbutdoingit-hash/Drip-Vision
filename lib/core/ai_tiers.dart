/// DripVision subscription → AI routing + credit costs.
///
/// Text models: OpenRouter IDs.
/// Image + video token costs are *customer* charges (app tokens), not raw API $.
/// [AiActionCost] pairs tokens with USD (retail + optional COGS) for UI and logging.
class AiActionCost {
  /// App tokens charged to the user.
  final int tokens;

  /// Customer-facing retail value (tokens × [AiTiers.tokenUsdRetail]).
  final double usdRetail;

  /// Approximate provider COGS in USD (what you pay upstream). Null if unknown/free.
  final double? usdCogs;

  const AiActionCost({
    required this.tokens,
    required this.usdRetail,
    this.usdCogs,
  });

  /// Gross margin if both retail and COGS are known.
  double? get marginUsd =>
      usdCogs == null ? null : usdRetail - usdCogs!;

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'usdRetail': usdRetail,
        if (usdCogs != null) 'usdCogs': usdCogs,
        if (marginUsd != null) 'marginUsd': marginUsd,
      };
}

class AiTiers {
  AiTiers._();

  // ── Subscription ids (match UserProfile.subscriptionTier) ──────────
  static const free = 'free';
  static const starter = 'starter';
  static const pro = 'pro';
  static const studio = 'studio';

  /// Retail value of one app token (token packs / paywall math).
  static const double tokenUsdRetail = 0.02;

  static double tokensToUsd(int tokens) => tokens * tokenUsdRetail;

  static AiActionCost costOf(int tokens, {double? usdCogs}) => AiActionCost(
        tokens: tokens,
        usdRetail: tokensToUsd(tokens),
        usdCogs: usdCogs,
      );

  // ── Text / Director models ─────────────────────────────────────────
  /// Free tier — $0, rate-limited on OpenRouter
  static const freeDirector = 'nvidia/nemotron-3-ultra-550b-a55b:free';
  static const freeFast = 'nvidia/nemotron-3.5-lightning:free';
  static const freeRouter = 'openrouter/free';

  /// Starter — cheap reliable mid
  static const starterDirector = 'anthropic/claude-haiku-5.5';

  /// Pro — strong creative planning
  static const proDirector = 'anthropic/claude-sonnet-5.5';

  /// Studio / premium boost
  static const studioDirector = 'anthropic/claude-opus-5.5';

  /// Resolve OpenRouter model for Director / Style DNA / prompt enhance.
  static String textModelFor(String? subscriptionTier,
      {bool premiumBoost = false}) {
    final t = (subscriptionTier ?? free).toLowerCase().trim();
    if (premiumBoost && (t == pro || t == studio)) {
      return studioDirector;
    }
    switch (t) {
      case starter:
        return starterDirector;
      case pro:
        return proDirector;
      case studio:
        return studioDirector;
      case free:
      default:
        return freeDirector;
    }
  }

  // ── App-token prices for AI actions ────────────────────────────────
  /// Director story plan (one full breakdown)
  static int directorPlanTokens(String? tier) {
    switch ((tier ?? free).toLowerCase()) {
      case starter:
        return 8;
      case pro:
        return 5;
      case studio:
        return 3;
      default:
        return 12; // free — higher so free users burn quota carefully
    }
  }

  static AiActionCost directorPlanCost(String? tier) {
    final tokens = directorPlanTokens(tier);
    // Haiku/Sonnet plan ≈ $0.001–0.03; free model = $0
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

  /// Prompt enhance / style DNA extract
  static int lightTextTokens(String? tier) => 2;

  static AiActionCost lightTextCost(String? tier) =>
      costOf(lightTextTokens(tier), usdCogs: 0.001);

  // ── Image generation (customer-facing app tokens) ──────────────────
  // COGS reality (2026): draft ~$0.005–0.02, standard ~$0.03–0.06,
  // pro/cinematic ~$0.07–0.15 per image.

  static const imageDraftTokens = 3;
  static const imageStandardTokens = 8;
  static const imageProTokens = 15;
  static const imageStoryboardBoardTokens = 28;

  /// Approximate provider COGS by image quality.
  static double imageCogsUsd(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'pro':
      case 'cinema':
      case 'poster':
        return 0.10;
      case 'standard':
      case 'storyboard':
      case 'character':
      case 'wardrobe':
        return 0.04;
      case 'board':
      case 'storyboard_board':
        return 0.16; // ~4 × standard
      case 'draft':
      default:
        return 0.01;
    }
  }

  static int imageTokens(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'pro':
      case 'cinema':
      case 'poster':
        return imageProTokens;
      case 'standard':
      case 'storyboard':
      case 'character':
      case 'wardrobe':
        return imageStandardTokens;
      case 'board':
      case 'storyboard_board':
        return imageStoryboardBoardTokens;
      case 'draft':
      default:
        return imageDraftTokens;
    }
  }

  static AiActionCost imageCost(String quality) {
    final q = quality.toLowerCase().trim();
    return costOf(imageTokens(q), usdCogs: imageCogsUsd(q));
  }

  /// Free = draft only; starter+ = standard; pro/studio = pro.
  static bool imageQualityAllowed(String? subscriptionTier, String quality) {
    final t = (subscriptionTier ?? free).toLowerCase().trim();
    final q = quality.toLowerCase().trim();
    if (q == 'draft' || q.isEmpty) return true;
    if (q == 'standard' ||
        q == 'storyboard' ||
        q == 'character' ||
        q == 'wardrobe' ||
        q == 'board' ||
        q == 'storyboard_board') {
      return t == starter || t == pro || t == studio;
    }
    return t == pro || t == studio;
  }

  // ── Video generation (customer-facing app tokens) ──────────────────
  // COGS reality (2026): ~$0.05–$0.15/s mid, ~$0.12–$0.40/s flagship.

  static const videoDraft5sTokens = 40;
  static const videoPro5sTokens = 90;
  static const videoCinema5sTokens = 160;

  static const videoExtraSecondDraft = 8;
  static const videoExtraSecondPro = 18;
  static const videoExtraSecondCinema = 32;

  /// Approximate COGS per second by quality.
  static double videoCogsPerSecond(String quality) {
    switch (quality.toLowerCase().trim()) {
      case 'cinema':
        return 0.25;
      case 'pro':
        return 0.12;
      case 'draft':
      default:
        return 0.07;
    }
  }

  static int videoTokens({
    required int durationSeconds,
    required String quality, // draft | pro | cinema
  }) {
    final secs = durationSeconds.clamp(1, 30);
    final base5 = switch (quality) {
      'cinema' => videoCinema5sTokens,
      'pro' => videoPro5sTokens,
      _ => videoDraft5sTokens,
    };
    final extra = switch (quality) {
      'cinema' => videoExtraSecondCinema,
      'pro' => videoExtraSecondPro,
      _ => videoExtraSecondDraft,
    };
    if (secs <= 5) return base5;
    return base5 + (secs - 5) * extra;
  }

  static AiActionCost videoCost({
    required int durationSeconds,
    required String quality,
  }) {
    final secs = durationSeconds.clamp(1, 30);
    final tokens = videoTokens(durationSeconds: secs, quality: quality);
    final cogs = videoCogsPerSecond(quality) * secs;
    return costOf(tokens, usdCogs: cogs);
  }

  /// Human labels for paywall / UI
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

  /// Monthly list prices (USD) — product policy
  static const priceStarterUsd = 14.99;
  static const priceProUsd = 34.99;
  static const priceStudioUsd = 89.99;

  static const includedTokensFree = 30;
  static const includedTokensStarter = 400;
  static const includedTokensPro = 2000;
  static const includedTokensStudio = 8000;
}
