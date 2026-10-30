import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/style_dna.dart';
import '../models/scene.dart';
import '../models/character.dart';

// Style list with methods screens expect
class StyleListNotifier extends StateNotifier<List<StyleDna>> {
  StyleListNotifier() : super([]);

  void addStyle(StyleDna style) {
    state = [...state, style];
  }

  void updateStyle(StyleDna style) {
    state = [
      for (final s in state)
        if (s.id == style.id) style else s
    ];
  }

  void removeStyle(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void duplicateStyle(String id) {
    final original = state.where((s) => s.id == id).firstOrNull;
    if (original == null) return;
    final copy = original.copyWith(
      id: 'style_${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (copy)',
      createdAt: DateTime.now(),
    );
    state = [...state, copy];
  }
}

final styleListProvider = StateNotifierProvider<StyleListNotifier, List<StyleDna>>((ref) {
  return StyleListNotifier();
});

final activeStyleProvider = StateProvider<StyleDna?>((ref) => null);

// Scene list with methods screens expect
class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);

  void addScene(SceneNode scene) {
    state = [...state, scene];
  }

  void updateScene(SceneNode scene) {
    state = [
      for (final s in state)
        if (s.id == scene.id) scene else s
    ];
  }

  void removeScene(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void duplicateScene(String id) {
    final original = state.where((s) => s.id == id).firstOrNull;
    if (original == null) return;
    final copy = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sequenceIndex: state.length,
    );
    state = [...state, copy];
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }
}

final sceneListProvider = StateNotifierProvider<SceneListNotifier, List<SceneNode>>((ref) {
  return SceneListNotifier();
});

// Character list
class CharacterListNotifier extends StateNotifier<List<Character>> {
  CharacterListNotifier() : super([]);

  void addCharacter(Character c) => state = [...state, c];
  void updateCharacter(Character c) {
    state = [for (final x in state) if (x.id == c.id) c else x];
  }
  void removeCharacter(String id) => state = state.where((c) => c.id != id).toList();
}

final characterListProvider = StateNotifierProvider<CharacterListNotifier, List<Character>>((ref) {
  return CharacterListNotifier();
});

final activeCharacterProvider = StateProvider<Character?>((ref) => null);
final userProfileProvider = StateProvider<dynamic>((ref) => null);
final navIndexProvider = StateProvider<int>((ref) => 0);
final universeProvider = StateProvider<dynamic>((ref) => null);
final filmBibleProvider = StateProvider<dynamic>((ref) => null);
final pendingScenePromptProvider = StateProvider<String>((ref) => '');
final musicPlayerProvider = StateProvider<dynamic>((ref) => null);
