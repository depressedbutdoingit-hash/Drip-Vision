import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/style_dna.dart';
import '../models/scene.dart';
import '../models/character.dart';

class StyleListNotifier extends StateNotifier<List<StyleDna>> {
  StyleListNotifier() : super([]);
  void addStyle(StyleDna s) => state = [...state, s];
  void updateStyle(StyleDna s) => state = [for (final x in state) if (x.id == s.id) s else x];
  void removeStyle(String id) => state = state.where((x) => x.id != id).toList();
  void duplicateStyle(String id) {
    final o = state.where((x) => x.id == id).firstOrNull;
    if (o == null) return;
    state = [...state, o.copyWith(id: 'style_\( {DateTime.now().millisecondsSinceEpoch}', name: ' \){o.name} (copy)', createdAt: DateTime.now())];
  }
}
final styleListProvider = StateNotifierProvider<StyleListNotifier, List<StyleDna>>((ref) => StyleListNotifier());
final activeStyleProvider = StateProvider<StyleDna?>((ref) => null);

class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);
  void addScene(SceneNode s) => state = [...state, s];
  void updateScene(SceneNode s) => state = [for (final x in state) if (x.id == s.id) s else x];
  void removeScene(String id) => state = state.where((x) => x.id != id).toList();
  void duplicateScene(String id) {
    final o = state.where((x) => x.id == id).firstOrNull;
    if (o == null) return;
    state = [...state, o.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString(), sequenceIndex: state.length)];
  }
  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }
}
final sceneListProvider = StateNotifierProvider<SceneListNotifier, List<SceneNode>>((ref) => SceneListNotifier());

class CharacterListNotifier extends StateNotifier<List<Character>> {
  CharacterListNotifier() : super([]);
  void addCharacter(Character c) => state = [...state, c];
  void updateCharacter(Character c) => state = [for (final x in state) if (x.id == c.id) c else x];
  void removeCharacter(String id) => state = state.where((x) => x.id != id).toList();
}
final characterListProvider = StateNotifierProvider<CharacterListNotifier, List<Character>>((ref) => CharacterListNotifier());
final activeCharacterProvider = StateProvider<Character?>((ref) => null);
final userProfileProvider = StateProvider<dynamic>((ref) => null);
final navIndexProvider = StateProvider<int>((ref) => 0);
final universeProvider = StateProvider<dynamic>((ref) => null);
final filmBibleProvider = StateProvider<dynamic>((ref) => null);
final pendingScenePromptProvider = StateProvider<String>((ref) => '');
final musicPlayerProvider = StateProvider<dynamic>((ref) => null);
