import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_dna.dart';
import '../models/scene.dart';
import 'app_providers.dart';

/// Currently selected scene for continuity checking and generation.
final activeSceneProvider = StateProvider<SceneNode?>((ref) => null);

/// Currently selected CharacterDNA for continuity checking.
final activeCharacterDnaProvider = StateProvider<CharacterDNA?>((ref) => null);

/// Auto-selects the first available scene and a matching DNA when possible.
final autoActiveProviders = Provider<void>((ref) {
  final scenes = ref.watch(sceneListProvider);
  final activeScene = ref.watch(activeSceneProvider);

  if (activeScene == null && scenes.isNotEmpty) {
    Future.microtask(() {
      ref.read(activeSceneProvider.notifier).state = scenes.first;
    });
  }
});
