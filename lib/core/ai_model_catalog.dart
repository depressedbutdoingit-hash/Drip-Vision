/// Full model roster for DripVision — free + mid + high.
/// Routing policy lives in [AiTiers]; this file is the menu.
///
/// IDs are OpenRouter-style unless noted. List churns; verify on openrouter.ai
/// before production pins. Prefer [AiTiers.textModelFor] / imageModelId /
/// videoModelId for defaults; use this catalog for pickers and fallbacks.

enum ModelModality { text, image, video }

enum ModelBand { free, mid, high }

class CatalogModel {
  final String id;
  final String label;
  final ModelModality modality;
  final ModelBand band;
  final String notes;

  const CatalogModel({
    required this.id,
    required this.label,
    required this.modality,
    required this.band,
    this.notes = '',
  });
}

class AiModelCatalog {
  AiModelCatalog._();

  // ═══════════════════════════════════════════════════════════════════
  // TEXT — Director, Style DNA, prompt enhance, screenplay
  // ═══════════════════════════════════════════════════════════════════

  static const List<CatalogModel> textFree = [
    CatalogModel(
      id: 'nvidia/nemotron-3-ultra-550b-a55b:free',
      label: 'Nemotron 3 Ultra',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Best free reasoning / film planning',
    ),
    CatalogModel(
      id: 'nvidia/nemotron-3-super-120b-a12b:free',
      label: 'Nemotron 3 Super',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Strong multi-step, 262K context',
    ),
    CatalogModel(
      id: 'nvidia/nemotron-3.5-lightning:free',
      label: 'Nemotron 3.5 Lightning',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Fast high-volume tests',
    ),
    CatalogModel(
      id: 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free',
      label: 'Nemotron 3 Nano Omni',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Multimodal text+image+video+audio in',
    ),
    CatalogModel(
      id: 'google/gemma-4-31b-it:free',
      label: 'Gemma 4 31B',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Vision + text, solid generalist',
    ),
    CatalogModel(
      id: 'google/gemma-4-26b-a4b-it:free',
      label: 'Gemma 4 26B',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Lighter Gemma 4',
    ),
    CatalogModel(
      id: 'thinkingmachines/inkling:free',
      label: 'Inkling',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: '~1M context, tools, multimodal',
    ),
    CatalogModel(
      id: 'thinkingmachines/inkling-small:free',
      label: 'Inkling Small',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Faster Inkling, long context',
    ),
    CatalogModel(
      id: 'qwen/qwen3.8-27b:free',
      label: 'Qwen 3.8 27B',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Text + image + video input',
    ),
    CatalogModel(
      id: 'cohere/north-mini-code:free',
      label: 'North Mini Code',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Coding agents — not for screenplay',
    ),
    CatalogModel(
      id: 'apodex/apodex-1.1-mini:free',
      label: 'Apodex 1.1 Mini',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Long-horizon research / reasoning',
    ),
    CatalogModel(
      id: 'inclusionai/ling-3.0-flash-sante:free',
      label: 'Ling 3.0 Flash Sante',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Fast general + medical skew',
    ),
    CatalogModel(
      id: 'liquid/lfm-2.5-2.6b:free',
      label: 'LFM 2.5 2.6B',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Tiny / fast extraction only',
    ),
    CatalogModel(
      id: 'dots-studio/dots-3-note-preview:free',
      label: 'Dots3-Note Preview',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Long context preview — may expire',
    ),
    CatalogModel(
      id: 'poolside/laguna-s-2.1:free',
      label: 'Laguna S 2.1',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Coding — free window may end',
    ),
    CatalogModel(
      id: 'poolside/laguna-xs-2.1:free',
      label: 'Laguna XS 2.1',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Smaller coding agent',
    ),
    CatalogModel(
      id: 'openrouter/free',
      label: 'OpenRouter Free Router',
      modality: ModelModality.text,
      band: ModelBand.free,
      notes: 'Auto-picks an available free model',
    ),
  ];

  static const List<CatalogModel> textMid = [
    CatalogModel(
      id: 'anthropic/claude-haiku-5.5',
      label: 'Claude Haiku 5.5',
      modality: ModelModality.text,
      band: ModelBand.mid,
      notes: 'Default Starter Director — cheap + structured',
    ),
    CatalogModel(
      id: 'google/gemini-3.8-flash',
      label: 'Gemini 3.8 Flash',
      modality: ModelModality.text,
      band: ModelBand.mid,
      notes: 'Fast Google mid-tier',
    ),
    CatalogModel(
      id: 'openai/gpt-6-luna',
      label: 'GPT-6 Luna',
      modality: ModelModality.text,
      band: ModelBand.mid,
      notes: 'OpenAI budget workhorse',
    ),
    CatalogModel(
      id: 'openai/gpt-4o-mini',
      label: 'GPT-4o mini',
      modality: ModelModality.text,
      band: ModelBand.mid,
      notes: 'Legacy cheap OpenAI',
    ),
    CatalogModel(
      id: 'deepseek/deepseek-v4.1-flash',
      label: 'DeepSeek V4.1 Flash',
      modality: ModelModality.text,
      band: ModelBand.mid,
      notes: 'Very cheap capable open model',
    ),
  ];

  static const List<CatalogModel> textHigh = [
    CatalogModel(
      id: 'anthropic/claude-sonnet-5.5',
      label: 'Claude Sonnet 5.5',
      modality: ModelModality.text,
      band: ModelBand.high,
      notes: 'Default Pro Director',
    ),
    CatalogModel(
      id: 'anthropic/claude-opus-5.5',
      label: 'Claude Opus 5.5',
      modality: ModelModality.text,
      band: ModelBand.high,
      notes: 'Studio / premium boost',
    ),
    CatalogModel(
      id: 'openai/gpt-6.1-sol',
      label: 'GPT-6.1 Sol',
      modality: ModelModality.text,
      band: ModelBand.high,
      notes: 'OpenAI strong generalist',
    ),
    CatalogModel(
      id: 'openai/gpt-6-astra',
      label: 'GPT-6 Astra',
      modality: ModelModality.text,
      band: ModelBand.high,
      notes: 'Frontier — expensive',
    ),
    CatalogModel(
      id: 'google/gemini-3.1-pro',
      label: 'Gemini 3.1 Pro',
      modality: ModelModality.text,
      band: ModelBand.high,
      notes: 'Google flagship class',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // IMAGE — character, wardrobe, storyboard, poster
  // ═══════════════════════════════════════════════════════════════════

  static const List<CatalogModel> imageFree = [
    CatalogModel(
      id: 'black-forest-labs/flux.2-klein',
      label: 'FLUX Schnell',
      modality: ModelModality.image,
      band: ModelBand.free,
      notes: 'Fast draft stills (often low-cost / free hosts)',
    ),
    CatalogModel(
      id: 'black-forest-labs/flux.2-klein',
      label: 'FLUX.2 Klein',
      modality: ModelModality.image,
      band: ModelBand.free,
      notes: 'Compact FLUX.2',
    ),
  ];

  static const List<CatalogModel> imageMid = [
    CatalogModel(
      id: 'black-forest-labs/flux.2-pro',
      label: 'FLUX.2 Pro',
      modality: ModelModality.image,
      band: ModelBand.mid,
      notes: 'Default standard — cinematic stills',
    ),
    CatalogModel(
      id: 'bytedance/seedream-5.0',
      label: 'Seedream 5.0',
      modality: ModelModality.image,
      band: ModelBand.mid,
      notes: 'Strong alternate mid',
    ),
    CatalogModel(
      id: 'openai/gpt-image-2',
      label: 'GPT Image 2',
      modality: ModelModality.image,
      band: ModelBand.mid,
      notes: 'OpenAI medium quality',
    ),
    CatalogModel(
      id: 'google/nano-banana-2',
      label: 'Nano Banana 2',
      modality: ModelModality.image,
      band: ModelBand.mid,
      notes: 'Gemini image family',
    ),
  ];

  static const List<CatalogModel> imageHigh = [
    CatalogModel(
      id: 'black-forest-labs/flux.2-max',
      label: 'FLUX.2 Max',
      modality: ModelModality.image,
      band: ModelBand.high,
      notes: 'Hero keyframes / posters',
    ),
    CatalogModel(
      id: 'openai/gpt-image-2-high',
      label: 'GPT Image 2 High',
      modality: ModelModality.image,
      band: ModelBand.high,
      notes: 'OpenAI high fidelity',
    ),
    CatalogModel(
      id: 'google/nano-banana-pro',
      label: 'Nano Banana Pro',
      modality: ModelModality.image,
      band: ModelBand.high,
      notes: 'Gemini pro image',
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // VIDEO — shots, I2V, continuity last-frame
  // ═══════════════════════════════════════════════════════════════════

  static const List<CatalogModel> videoFree = [
    // True $0 video is rare; these are "draft budget" IDs when hosted cheap/free.
    CatalogModel(
      id: 'alibaba/wan-2.7',
      label: 'Wan 2.7',
      modality: ModelModality.video,
      band: ModelBand.free,
      notes: 'Default draft — strong I2V continuity',
    ),
    CatalogModel(
      id: 'google/veo-3.1-lite',
      label: 'Veo 3.1 Lite',
      modality: ModelModality.video,
      band: ModelBand.free,
      notes: 'Google lite draft path',
    ),
    CatalogModel(
      id: 'bytedance/seedance-2.0',
      label: 'Seedance 2.0',
      modality: ModelModality.video,
      band: ModelBand.free,
      notes: 'Budget motion alternate',
    ),
  ];

  static const List<CatalogModel> videoMid = [
    CatalogModel(
      id: 'kwaivgi/kling-v3.0-std',
      label: 'Kling 3.0 Standard',
      modality: ModelModality.video,
      band: ModelBand.mid,
      notes: 'Default Pro video',
    ),
    CatalogModel(
      id: 'runway/gen-4-turbo',
      label: 'Runway Gen-4 Turbo',
      modality: ModelModality.video,
      band: ModelBand.mid,
      notes: 'Fast Runway',
    ),
    CatalogModel(
      id: 'runway/gen-4.5',
      label: 'Runway Gen-4.5',
      modality: ModelModality.video,
      band: ModelBand.mid,
      notes: 'Higher Runway quality',
    ),
    CatalogModel(
      id: 'google/veo-3.1-fast',
      label: 'Veo 3.1 Fast',
      modality: ModelModality.video,
      band: ModelBand.mid,
      notes: 'Google fast mid',
    ),
    CatalogModel(
      id: 'minimax/hailuo-3',
      label: 'Hailuo 3',
      modality: ModelModality.video,
      band: ModelBand.mid,
      notes: 'MiniMax motion',
    ),
  ];

  static const List<CatalogModel> videoHigh = [
    CatalogModel(
      id: 'google/veo-3.1',
      label: 'Veo 3.1',
      modality: ModelModality.video,
      band: ModelBand.high,
      notes: 'Default Cinema',
    ),
    CatalogModel(
      id: 'kwaivgi/kling-v3.0-pro',
      label: 'Kling 3.0 Pro',
      modality: ModelModality.video,
      band: ModelBand.high,
      notes: 'Kling flagship',
    ),
    CatalogModel(
      id: 'openai/sora-2',
      label: 'Sora 2',
      modality: ModelModality.video,
      band: ModelBand.high,
      notes: 'OpenAI video when available',
    ),
    CatalogModel(
      id: 'luma/ray-3.2',
      label: 'Luma Ray 3.2',
      modality: ModelModality.video,
      band: ModelBand.high,
      notes: 'Luma cinematic',
    ),
  ];

  // ── Aggregates ─────────────────────────────────────────────────────

  static List<CatalogModel> get allText =>
      [...textFree, ...textMid, ...textHigh];

  static List<CatalogModel> get allImage =>
      [...imageFree, ...imageMid, ...imageHigh];

  static List<CatalogModel> get allVideo =>
      [...videoFree, ...videoMid, ...videoHigh];

  static List<CatalogModel> get all =>
      [...allText, ...allImage, ...allVideo];

  static List<CatalogModel> textForBand(ModelBand band) {
    switch (band) {
      case ModelBand.free:
        return textFree;
      case ModelBand.mid:
        return textMid;
      case ModelBand.high:
        return textHigh;
    }
  }

  static List<CatalogModel> imageForBand(ModelBand band) {
    switch (band) {
      case ModelBand.free:
        return imageFree;
      case ModelBand.mid:
        return imageMid;
      case ModelBand.high:
        return imageHigh;
    }
  }

  static List<CatalogModel> videoForBand(ModelBand band) {
    switch (band) {
      case ModelBand.free:
        return videoFree;
      case ModelBand.mid:
        return videoMid;
      case ModelBand.high:
        return videoHigh;
    }
  }

  /// Models a subscription tier may use (policy aligned with AiTiers).
  static List<CatalogModel> availableForSubscription(String? tier) {
    final t = (tier ?? 'free').toLowerCase().trim();
    switch (t) {
      case 'studio':
      case 'pro':
        return all;
      case 'starter':
        return [
          ...textFree,
          ...textMid,
          ...imageFree,
          ...imageMid,
          ...videoFree,
          ...videoMid,
        ];
      default:
        return [...textFree, ...imageFree, ...videoFree];
    }
  }

  static CatalogModel? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }
}
