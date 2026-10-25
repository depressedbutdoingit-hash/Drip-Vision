import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/universe.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/style_dna.dart';
import '../models/user_profile.dart';
import '../services/continuity_service.dart';
import '../services/media_action_service.dart';

class ContinuityHealth {
  final double score;
  final String message;
  final Color color;
  ContinuityHealth({required this.score, required this.message, required this.color});
  ContinuityHealth fix() => ContinuityHealth(score: 96, message: 'Continuity locked.', color: const Color(0xFF00D4AA));
}

final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());

final universeProvider = StateProvider<Universe>((ref) => Universe(
  healthScore: 94,
  characters: [
    Character(id: 'isabella', name: 'Isabella', avatarUrl: '', role: 'Lead', wardrobeDNA: ['jacket'], dna: const CharacterDNA(face: 0.8, body: 0.7, wardrobe: 0.6, voice: 0.7, style: 0.8)),
  ],
));

final continuityHealthProvider = StateProvider<ContinuityHealth>((ref) => ContinuityHealth(score: 88, message: 'OK', color: const Color(0xFFFFB020)));

final navIndexProvider = StateProvider<int>((ref) => 0);

final userProfileProvider = StateProvider<AsyncValue<UserProfile>>((ref) => AsyncValue.data(UserProfile(uid: 'local', tokenBalance: 100, subscriptionTier: 'pro', lastFreeClaimDate: DateTime.now())));

class CharacterListNotifier extends StateNotifier<List<Character>> {
  CharacterListNotifier() : super([]);
  void updateCharacter(Character updated) => state = [for (final c in state) if (c.id == updated.id) updated else c];
  void addCharacter(Character c) => state = [...state, c];
  void removeCharacter(String id) => state = state.where((c) => c.id != id).toList();
}
final characterListProvider = StateNotifierProvider<CharacterListNotifier, List<Character>>((ref) => CharacterListNotifier());

final activeCharacterProvider = StateProvider<Character?>((ref) => null);

class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);
  void updateScene(SceneNode updated) => state = [for (final s in state) if (s.id == updated.id) updated else s];
  void removeScene(String id) => state = state.where((s) => s.id != id).toList();
  void duplicateScene(String id) { final o = state.cast<SceneNode?>().firstWhere((s) => s?.id == id, orElse: () => null); if (o != null) state = [...state, o.copyWith()]; }
  void reorder(int oldIndex, int newIndex) { if (newIndex > oldIndex) newIndex -= 1; final list = [...state]; final item = list.removeAt(oldIndex); list.insert(newIndex, item); state = list; }
  void addScene(SceneNode s) => state = [...state, s];
}
final sceneListProvider = StateNotifierProvider<SceneListNotifier, List<SceneNode>>((ref) => SceneListNotifier());

class StyleListNotifier extends StateNotifier<List<StyleDna>> {
  StyleListNotifier() : super([]);
  void addStyle(StyleDna s) => state = [...state, s];
  void updateStyle(StyleDna updated) => state = [for (final s in state) if (s.id == updated.id) updated else s];
  void removeStyle(String id) => state = state.where((s) => s.id != id).toList();
  void duplicateStyle(String id) {
    final o = state.cast<StyleDna?>().firstWhere((s) => s?.id == id, orElse: () => null);
    if (o == null) return;
    state = [...state, StyleDna(id: '\( {o.id}_copy', name: ' \){o.name} (copy)', tags: o.tags, lens: o.lens, colorPalette: o.colorPalette, lighting: o.lighting, grain: o.grain, contrast: o.contrast, sourceImageUrl: o.sourceImageUrl, createdAt: DateTime.now())];
  }
}
final styleListProvider = StateNotifierProvider<StyleListNotifier, List<StyleDna>>((ref) => StyleListNotifier());

final mediaActionProvider = Provider<MediaActionService>((ref) => MediaActionService());

final videoStitchProvider = Provider((ref) => null);
final aiGenerationServiceProvider = Provider((ref) => null);
final continuityServiceProvider = Provider((ref) => null);
