import '../models/character_dna.dart';
import '../models/continuity_score.dart';
import '../models/scene.dart';

class ContinuityCheckerService {
  /// Compares a scene against a CharacterDNA profile and returns a ContinuityScore.
  ContinuityScore checkScene({
    required SceneNode scene,
    required CharacterDNA characterDna,
    List<String>? expectedProps,
  }) {
    final issues = <String>[];
    double character = 1.0;
    double wardrobe = 1.0;
    double props = 1.0;
    double environment = 1.0;
    double timeline = 1.0;

    // Character DNA hash check
    if (characterDna.dnaHash != null &&
        scene.characterOutfits.containsKey(characterDna.id)) {
      // Placeholder: in production compare against stored hash on scene
      // For now, assume match unless noted otherwise
    } else if (characterDna.dnaHash == null) {
      character = 0.8;
      issues.add('Character DNA has no hash — identity drift risk');
    }

    // Wardrobe consistency
    final activeOutfit = scene.characterOutfits[characterDna.id];
    if (activeOutfit != null &&
        activeOutfit != characterDna.defaultOutfitId &&
        characterDna.defaultOutfitId.isNotEmpty) {
      wardrobe = 0.6;
      issues.add('Wardrobe changed from default outfit');
    }

    // Props
    if (expectedProps != null && expectedProps.isNotEmpty) {
      final present = scene.locationProps?.keys.toList() ?? [];
      final missing = expectedProps.where((p) => !present.contains(p)).toList();
      if (missing.isNotEmpty) {
        props = (1.0 - 0.2 * missing.length).clamp(0.4, 1.0);
        issues.add('Missing props: ${missing.join(', ')}');
      }
    }

    // Environment / lighting (basic)
    if (scene.lighting == null || scene.lighting!.isEmpty) {
      environment = 0.85;
      issues.add('No lighting notes recorded');
    }

    final overall = (character + wardrobe + props + environment + timeline) / 5;

    return ContinuityScore(
      character: character,
      wardrobe: wardrobe,
      props: props,
      environment: environment,
      timeline: timeline,
      overall: overall,
      issues: issues,
    );
  }

  /// Batch check across multiple scenes for the same character.
  List<ContinuityScore> checkSequence({
    required List<SceneNode> scenes,
    required CharacterDNA characterDna,
  }) {
    return scenes
        .map((s) => checkScene(scene: s, characterDna: characterDna))
        .toList();
  }
}
