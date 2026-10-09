import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_tiers.dart';
import 'product_models.dart';

/// User-selected generation quality + optional model overrides.
/// Empty override → ProductModels defaults via AiTiers.

final videoQualityProvider =
    StateProvider<VideoGenTier>((ref) => VideoGenTier.draft);

final imageQualityProvider =
    StateProvider<ImageGenTier>((ref) => ImageGenTier.standard);

/// Optional full model id overrides (null = use product default for quality).
final videoModelOverrideProvider = StateProvider<String?>((ref) => null);
final imageModelOverrideProvider = StateProvider<String?>((ref) => null);
final textModelOverrideProvider = StateProvider<String?>((ref) => null);

String resolveVideoModel(WidgetRef ref) {
  final override = ref.read(videoModelOverrideProvider);
  if (override != null && override.isNotEmpty) return override;
  return AiTiers.videoModelId(ref.read(videoQualityProvider));
}

String resolveImageModel(WidgetRef ref) {
  final override = ref.read(imageModelOverrideProvider);
  if (override != null && override.isNotEmpty) return override;
  return AiTiers.imageModelId(ref.read(imageQualityProvider));
}

String resolveTextModel(WidgetRef ref, String? subscriptionTier) {
  final override = ref.read(textModelOverrideProvider);
  if (override != null && override.isNotEmpty) return override;
  return AiTiers.textModelFor(subscriptionTier);
}

/// Labels for UI chips.
String videoQualityChip(VideoGenTier t) {
  switch (t) {
    case VideoGenTier.draft:
      return 'DRAFT · ${ProductModels.videoDraft.split('/').last}';
    case VideoGenTier.pro:
      return 'PRO · ${ProductModels.videoPro.split('/').last}';
    case VideoGenTier.cinema:
      return 'CINEMA · ${ProductModels.videoCinema.split('/').last}';
  }
}
