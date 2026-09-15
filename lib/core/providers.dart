import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character.dart';
import '../models/scene.dart';
import '../models/user_profile.dart';
import '../services/openrouter_service.dart';
import '../services/drip_engine_service.dart';
import '../services/media_action_service.dart';
import '../services/whisper_service.dart';
import '../services/audio_generation_service.dart';
import '../services/lip_sync_service.dart';
import '../services/purchase_service.dart';
import '../services/generation_guard.dart';
import '../services/prompt_enhancer_service.dart';
import '../services/video_stitching_service.dart';
import '../services/watermark_export_service.dart';
import '../services/ai_queue_service.dart';
import '../services/auth_service.dart';
import '../services/continuity_service.dart';
import '../services/ai_director_service.dart';
import '../services/suno_service.dart';
import '../services/token_service.dart';
import '../services/cost_tracking_service.dart';
import '../services/voice_lock_service.dart';
import '../services/poster_generator_service.dart';
import '../services/drip_score_service.dart';
import '../services/location_bible_service.dart';
import '../services/smart_prompt_service.dart';
import '../services/season_pass_service.dart';
import '../services/drip_chain_service.dart';
import '../services/style_dna_service.dart';
import '../models/style_dna.dart';
import 'env.dart';

// Services
final openRouterProvider = Provider((ref) => OpenRouterService());
final dripEngineProvider = Provider((ref) => DripEngineService());
final mediaActionProvider = Provider((ref) => MediaActionService());
final whisperProvider = Provider((ref) => WhisperService());
final audioGenProvider = Provider((ref) => AudioGenerationService());
final lipSyncProvider = Provider((ref) => LipSyncService());
final purchaseServiceProvider = Provider((ref) => PurchaseService());
final generationGuardProvider = Provider((ref) => GenerationGuard());
final promptEnhancerProvider = Provider((ref) => PromptEnhancerService());
final videoStitchProvider = Provider((ref) => VideoStitchingService());
final aiQueueProvider = Provider((ref) => AIQueueService());

// New feature services
final authServiceProvider = Provider((ref) => AuthService(FirebaseAuth.instance));
final authStateProvider = StreamProvider((ref) =>
  ref.watch(authServiceProvider).authStateChanges
);
final continuityServiceProvider = Provider((ref) =>
  ContinuityService(FirebaseFirestore.instance)
);
final aiDirectorServiceProvider = Provider((ref) =>
  AIDirectorService(Env.openRouterKey)
);
final sunoServiceProvider = Provider((ref) =>
  SunoService(Env.sunoApiKey)
);
final costTrackingProvider = Provider((ref) => CostTrackingService());

// Standout feature services
final voiceLockServiceProvider = Provider((ref) => VoiceLockService());
final posterGeneratorProvider = Provider((ref) => PosterGeneratorService(Env.openRouterKey));
final styleDnaServiceProvider = Provider((ref) => StyleDnaService(Env.openRouterKey));
final dripScoreServiceProvider = Provider((ref) => DripScoreService(FirebaseFirestore.instance));
final locationBibleProvider = Provider((ref) => LocationBibleService(FirebaseFirestore.instance));
final smartPromptProvider = Provider((ref) => SmartPromptService(Env.openRouterKey));
final seasonPassProvider = Provider((ref) => SeasonPassService(FirebaseFirestore.instance));
final dripChainProvider = Provider((ref) => DripChainService(FirebaseFirestore.instance));

// State
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return UserProfileNotifier();
});

final sceneListProvider = StateNotifierProvider<SceneListNotifier, List<SceneNode>>((ref) {
  return SceneListNotifier();
});

final activeCharacterProvider = StateProvider<Character?>((ref) => null);

/// One-shot bridge: when Screenplay/Storyboard "Generate Video" sets this,
/// the generator screen picks it up on open and clears it, so a planned
/// scene's description actually becomes the prompt instead of being
/// re-typed by hand.
final pendingScenePromptProvider = StateProvider<String?>((ref) => null);

/// Scene numbers a user has locked composition on, in Storyboard Mode.
final lockedScenesProvider = StateProvider<Set<int>>((ref) => {});

final characterListProvider = StateNotifierProvider<CharacterListNotifier, List<Character>>((ref) {
  return CharacterListNotifier();
});

class CharacterListNotifier extends StateNotifier<List<Character>> {
  CharacterListNotifier() : super([]);

  void addCharacter(Character character) => state = [...state, character];
  void removeCharacter(String id) => state = state.where((c) => c.id != id).toList();
  void updateCharacter(Character updated) {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }
}

final styleListProvider = StateNotifierProvider<StyleListNotifier, List<StyleDna>>((ref) {
  return StyleListNotifier();
});

/// The Style DNA currently applied to the active project — folded into
/// the generation prompt by the generator screen when set.
final activeStyleProvider = StateProvider<StyleDna?>((ref) => null);

class StyleListNotifier extends StateNotifier<List<StyleDna>> {
  StyleListNotifier() : super([]);

  void addStyle(StyleDna style) => state = [...state, style];
  void removeStyle(String id) => state = state.where((s) => s.id != id).toList();
  void updateStyle(StyleDna updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  void duplicateStyle(String id) {
    final source = state.firstWhere((s) => s.id == id);
    final copy = source.copyWith(id: 'style_${DateTime.now().millisecondsSinceEpoch}', name: '${source.name} Copy');
    state = [...state, copy];
  }
}

final generationProgressProvider = StateProvider<double>((ref) => 0.0);
final isGeneratingProvider = StateProvider<bool>((ref) => false);

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await PurchaseService.fetchUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> deductTokens(int cost) async {
    state.whenData((profile) async {
      final newBalance = profile.tokenBalance - cost;
      await PurchaseService.updateTokenBalance(newBalance);
      state = AsyncValue.data(profile.copyWith(tokenBalance: newBalance));
    });
  }
}

class SceneListNotifier extends StateNotifier<List<SceneNode>> {
  SceneListNotifier() : super([]);

  void addScene(SceneNode scene) => state = [...state, scene];
  void removeScene(String id) => state = state.where((s) => s.id != id).toList();
  void updateScene(SceneNode updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  /// Real drag-reorder for the Director's Cut timeline — mutates order only,
  /// sequenceIndex is recomputed so continuity/export logic downstream still
  /// sees a consistent cut.
  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = [for (var i = 0; i < list.length; i++) list[i].copyWith(sequenceIndex: i)];
  }

  void duplicateScene(String id) {
    final source = state.firstWhere((s) => s.id == id);
    final copy = source.copyWith(
      id: 'scene_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    final index = state.indexWhere((s) => s.id == id);
    final list = [...state]..insert(index + 1, copy);
    state = [for (var i = 0; i < list.length; i++) list[i].copyWith(sequenceIndex: i)];
  }

  void clear() => state = [];
}
