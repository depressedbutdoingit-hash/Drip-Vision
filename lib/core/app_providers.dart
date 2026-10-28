import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/style_dna.dart';

final sceneListProvider = StateProvider<List<SceneNode>>((ref) => []);
final characterListProvider = StateProvider<List<Character>>((ref) => []);
final userProfileProvider = StateProvider<dynamic>((ref) => null);
final navIndexProvider = StateProvider<int>((ref) => 0);
final activeCharacterProvider = StateProvider<dynamic>((ref) => null);
final filmBibleProvider = StateProvider<dynamic>((ref) => null);
final pendingScenePromptProvider = StateProvider<String>((ref) => '');
final styleListProvider = StateProvider<List<StyleDna>>((ref) => []);
final activeStyleProvider = StateProvider<dynamic>((ref) => null);
final musicPlayerProvider = StateProvider<dynamic>((ref) => null);

/// Mutations live beside the list providers so every screen uses the same
/// state operations instead of trying to call methods that StateController
/// does not implement.
extension CharacterListMutations on StateController<List<Character>> {
  void updateCharacter(Character updated) {
    state = [
      for (final character in state)
        if (character.id == updated.id) updated else character,
    ];
  }

  void addCharacter(Character character) {
    if (state.any((existing) => existing.id == character.id)) {
      throw StateError('A character with id ${character.id} already exists.');
    }
    state = [...state, character];
  }

  void removeCharacter(String id) {
    state = state.where((character) => character.id != id).toList();
  }
}

extension SceneListMutations on StateController<List<SceneNode>> {
  void updateScene(SceneNode updated) {
    state = [
      for (final scene in state)
        if (scene.id == updated.id) updated else scene,
    ];
  }

  void removeScene(String id) {
    state = state.where((scene) => scene.id != id).toList();
    state = [
      for (var i = 0; i < state.length; i++)
        state[i].copyWith(sequenceIndex: i),
    ];
  }

  void duplicateScene(String id) {
    final index = state.indexWhere((scene) => scene.id == id);
    if (index < 0) return;
    final original = state[index];
    final duplicate = original.copyWith(
      id: '${original.id}_copy_${DateTime.now().microsecondsSinceEpoch}',
      sequenceIndex: index + 1,
    );
    final next = [...state]..insert(index + 1, duplicate);
    state = [
      for (var i = 0; i < next.length; i++)
        next[i].copyWith(sequenceIndex: i),
    ];
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= state.length) newIndex = state.length - 1;
    final next = [...state];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    state = [
      for (var i = 0; i < next.length; i++)
        next[i].copyWith(sequenceIndex: i),
    ];
  }
}

extension StyleListMutations on StateController<List<StyleDna>> {
  void addStyle(StyleDna style) {
    if (state.any((existing) => existing.id == style.id)) {
      throw StateError('A style with id ${style.id} already exists.');
    }
    state = [...state, style];
  }

  void updateStyle(StyleDna updated) {
    state = [
      for (final style in state)
        if (style.id == updated.id) updated else style,
    ];
  }

  void removeStyle(String id) {
    state = state.where((style) => style.id != id).toList();
  }

  void duplicateStyle(String id) {
    final index = state.indexWhere((style) => style.id == id);
    if (index < 0) return;
    final original = state[index];
    final duplicate = original.copyWith(
      id: '${original.id}_copy_${DateTime.now().microsecondsSinceEpoch}',
      name: '${original.name} Copy',
      createdAt: DateTime.now(),
    );
    final next = [...state]..insert(index + 1, duplicate);
    state = next;
  }
}
