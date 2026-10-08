/// DripVision subscription → AI routing + credit costs.
///
/// Text models: OpenRouter IDs.
/// Image + video token costs are *customer* charges (app tokens), not raw API $.
class AiTiers {
  AiTiers._();

  // ── Subscription ids (match UserProfile.subscriptionTier) ──────────
  static const free = 'free';
  static const starter = 'starter';
  static const pro = 'pro';
  static const studio = 'studio';

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
  static String textModelFor(String? subscriptionTier, {bool premiumBoost = false}) {
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

  /// Prompt enhance / style DNA extract
  static int lightTextTokens(String? tier) => 2;

  // ── Image generation (customer-facing app tokens) ──────────────────
  // COGS reality (2026): draft ~$0.005–0.02, standard ~$0.03–0.06,
  // pro/cinematic ~$0.07–0.15 per image. Bill ~2.5–3× in app tokens
  // (1 token ≈ $0.02–0.03 retail on packs).

  /// Quick ref / test still (FLUX schnell-class)
  static const imageDraftTokens = 3;

  /// Storyboard, wardrobe, character still (FLUX.2 Pro-class)
  static const imageStandardTokens = 8;

  /// Poster / hero keyframe / high-res (FLUX Max / GPT Image high)
  static const imageProTokens = 15;

  /// Four-up storyboard board (4 × standard, slight pack discount)
  static const imageStoryboardBoardTokens = 28;

  /// draft | standard | pro
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
    // pro / cinema / poster
    return t == pro || t == studio;
  }

  // ── Video generation (customer-facing app tokens) ──────────────────
  // COGS reality (2026): ~$0.05–$0.15/s mid, ~$0.12–$0.40/s flagship.
  // 5s draft ≈ $0.25–$0.75 COGS → charge ~2.5–3× in product value.
  // We bill in *app tokens* (1 token ≈ $0.02–0.03 retail value on packs).

  /// Draft / standard 5s shot (mid model, 720p)
  static const videoDraft5sTokens = 40;

  /// Pro 5s shot (better model / 1080p)
  static const videoPro5sTokens = 90;

  /// Cinema 5s shot (flagship model)
  static const videoCinema5sTokens = 160;

  /// Tokens per extra second beyond 5s (draft scale)
  static const videoExtraSecondDraft = 8;
  static const videoExtraSecondPro = 18;
  static const videoExtraSecondCinema = 32;

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
