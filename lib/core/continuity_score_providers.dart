import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_dna.dart';
import '../models/continuity_score.dart';
import '../models/scene.dart';
import '../services/continuity_checker_service.dart';
import 'app_providers.dart';
import 'active_providers.dart';

/// Service provider for the continuity checker.
final continuityCheckerServiceProvider =
    Provider<ContinuityCheckerService>((ref) => ContinuityCheckerService());

/// Computes ContinuityScore for a specific scene + character DNA.
/// Recomputes whenever the scene list changes.
final sceneContinuityScoreProvider =
    Provider.family<ContinuityScore, ({String sceneId, CharacterDNA dna})>(
        (ref, args) {
  final scenes = ref.watch(sceneListProvider);
  final scene = scenes.where((s) => s.id == args.sceneId).firstOrNull;
  if (scene == null) {
    return ContinuityScore.empty();
  }

  final checker = ref.watch(continuityCheckerServiceProvider);
  return checker.checkScene(scene: scene, characterDna: args.dna);
});

/// Real-time ContinuityScore for the currently active scene and CharacterDNA.
/// Automatically recomputes when:
/// - active scene changes
/// - active CharacterDNA changes
/// - the underlying scene data in sceneListProvider is updated
final activeSceneContinuityProvider = Provider<ContinuityScore>((ref) {
  final scene = ref.watch(activeSceneProvider);
  final dna = ref.watch(activeCharacterDnaProvider);
  final scenes = ref.watch(sceneListProvider); // real-time trigger

  if (scene == null || dna == null) {
    return ContinuityScore.empty();
  }

  // Always pull the latest version of the scene from the list
  final latestScene = scenes.where((s) => s.id == scene.id).firstOrNull ?? scene;

  final checker = ref.watch(continuityCheckerServiceProvider);
  return checker.checkScene(scene: latestScene, characterDna: dna);
});
