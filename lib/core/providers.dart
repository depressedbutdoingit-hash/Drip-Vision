
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../models/character.dart';
import '../models/film_bible.dart';
import '../models/scene.dart';
import '../models/style_dna.dart';
import '../models/universe.dart';
import '../models/user_profile.dart';
import '../services/ai_director_service.dart';
import '../services/ai_generation_service.dart';
import '../services/continuity_service.dart';
import '../services/media_action_service.dart';
import '../services/openrouter_service.dart';
import '../services/style_dna_service.dart';
import '../services/suno_service.dart';
import '../services/token_service.dart';
import '../services/video_stitching_service.dart';

// ---------------------------------------------------------------------------
// Continuity health
// ---------------------------------------------------------------------------

class ContinuityHealth {
  final double score;
  final String message;
  final Color color;

  ContinuityHealth({
    required this.score,
    required this.message,
    required this.color,
  });

  ContinuityHealth fix() {
    return ContinuityHealth(
      score: 96,
      message: 'Continuity locked.',
      color: const Color(0xFF00D4AA),
    );
  }
}

// ---------------------------------------------------------------------------
// Core providers
// ---------------------------------------------------------------------------

final continuityEngineProvider = Provider<ContinuityEngine>(
  (ref) => ContinuityEngine(),
);

final universeProvider = StateProvider<Universe>(
  (ref) => Universe(
    healthScore: 94,
    characters: [
      Character(
        id: 'isabella',
        name: 'Isabella',
        avatarUrl: '',
        role: 'Lead',
        wardrobeDNA: ['jacket'],
        dna: const CharacterDNA(
          face: 0.8,
          body: 0.7,
          wardrobe: 0.6,
          voice: 0.7,
          style: 0.8,
        ),
      ),
    ],
  ),
);

final continuityHealthProvider = StateProvider<ContinuityHealth>(
  (ref) => ContinuityHealth(
    score: 88,
    message: 'OK',
    color: const Color(0xFFFFB020),
  ),
);

final navIndexProvider = StateProvider<int>((ref) => 0);

final userProfileProvider = StateProvider<AsyncValue<UserProfile>>(
  (ref) => AsyncValue.data(
    UserProfile(
      uid: 'local',
      tokenBalance: 100,
      subscriptionTier: 'pro',
      lastFreeClaimDate: DateTime.now(),
    ),
  ),
);

// ---------------------------------------------------------------------------
// Character providers
// ---------------------------------------------------------------------------

class CharacterListNotifier extends StateNotifier<List<Character>> {
  CharacterListNotifier() : super([]);

  void updateCharacter(Character updated) {
    state = [
      for (final character in state)
        if (character.id == updated.id) updated else character,
    ];
  }

  void addCharacter(Character character) {
    state = [...state, character];
  }

  void removeCharacter(String id) {
    state = state.where((character) => character.id != id).toList();
  }
}

final characterListProvider =
    StateNotifierProvider<CharacterListNotifier, List<Character>>(
  (ref) => CharacterListNotifier(),
);

final activeCharacterProvider = StateProvider<Character?>((ref) => null);

// ---------------------------------------------------------------------------
// Scene providers
// ---------------------------------------------------------------------------

class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);

  void updateScene(SceneNode updated) {
    state = [
      for (final scene in state)
        if (scene.id == updated.id) updated else scene,
    ];
  }

  void removeScene(String id) {
    state = state.where((scene) => scene.id != id).toList();
  }

  void duplicateScene(String id) {
    final index = state.indexWhere((scene) => scene.id == id);

    if (index == -1) return;

    // This requires SceneNode.copyWith() to support the existing model.
    // A fresh ID should be assigned if the model supports an ID parameter.
    final original = state[index];
    state = [...state, original.copyWith()];
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex > state.length) {
      return;
    }

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final scenes = [...state];
    final scene = scenes.removeAt(oldIndex);
    scenes.insert(newIndex, scene);
    state = scenes;
  }

  void addScene(SceneNode scene) {
    state = [...state, scene];
  }
}

final sceneListProvider =
    StateNotifierProvider<SceneListNotifier, List<SceneNode>>(
  (ref) => SceneListNotifier(),
);

final lockedScenesProvider =
    StateNotifierProvider<SceneListNotifier, List<SceneNode>>(
  (ref) => SceneListNotifier(),
);

final pendingScenePromptProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
// Style DNA providers
// ---------------------------------------------------------------------------

class StyleListNotifier extends StateNotifier<List<StyleDna>> {
  StyleListNotifier() : super([]);

  void addStyle(StyleDna style) {
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

    if (index == -1) return;

    final original = state[index];

    final copy = StyleDna(
      id: '${original.id}_copy_${DateTime.now().microsecondsSinceEpoch}',
      name: '${original.name} (copy)',
      tags: original.tags,
      lens: original.lens,
      colorPalette: original.colorPalette,
      lighting: original.lighting,
      grain: original.grain,
      contrast: original.contrast,
      sourceImageUrl: original.sourceImageUrl,
      createdAt: DateTime.now(),
    );

    state = [...state, copy];
  }
}

final styleListProvider =
    StateNotifierProvider<StyleListNotifier, List<StyleDna>>(
  (ref) => StyleListNotifier(),
);

final activeStyleProvider = StateProvider<StyleDna?>((ref) => null);

// ---------------------------------------------------------------------------
// Film Bible
// ---------------------------------------------------------------------------

final filmBibleProvider = StateProvider<FilmBible>(
  (ref) => const FilmBible(),
);

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

final mediaActionProvider = Provider<MediaActionService>(
  (ref) => MediaActionService(),
);

final styleDnaServiceProvider = Provider<StyleDnaService>(
  (ref) => StyleDnaService(Env.openRouterKey),
);

final sunoServiceProvider = Provider<SunoService>(
  (ref) => SunoService(),
);

final aiDirectorServiceProvider = Provider<AiDirectorService>(
  (ref) => AiDirectorService(),
);

final tokenServiceProvider = Provider<TokenService>(
  (ref) => TokenService(),
);

final openRouterProvider = Provider<OpenRouterService>(
  (ref) => OpenRouterService(),
);

final videoStitchProvider = Provider<VideoStitchingService>(
  (ref) => VideoStitchingService(),
);

final aiGenerationServiceProvider = Provider<AiGenerationService>(
  (ref) => AiGenerationService(),
);

final continuityServiceProvider = Provider<ContinuityEngine>(
  (ref) => ContinuityEngine(),
);

// ---------------------------------------------------------------------------
// Music player state
// ---------------------------------------------------------------------------

final musicPlayerProvider = StateProvider<String?>((ref) => null);
