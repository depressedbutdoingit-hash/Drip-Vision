import '../../core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/character.dart' as live;
import '../../models/character_dna.dart';
import '../../models/scene.dart';
import '../../services/ai_generation_service.dart';
import '../../services/continuity_service.dart' as continuity;
import '../../services/continuity_health_analyzer.dart';
import '../../services/token_service.dart';
import 'story_planner_screen.dart';
import '../widgets/video_player_widget.dart';

final productionQueueProvider = StateNotifierProvider.family<ProductionQueueNotifier, ProductionQueueState, StoryPlan>(
  (ref, plan) => ProductionQueueNotifier(
    plan: plan,
    generationService: ref.read(aiGenerationServiceProvider),
  ),
);

class ProductionQueueState {
  final int currentSceneIndex;
  final List<GeneratedScene> completedScenes;
  final bool isGenerating;
  final String? currentStatus;
  final String? error;
  final bool isComplete;

  ProductionQueueState({
    this.currentSceneIndex = 0,
    this.completedScenes = const [],
    this.isGenerating = false,
    this.currentStatus,
    this.error,
    this.isComplete = false,
  });

  ProductionQueueState copyWith({
    int? currentSceneIndex,
    List<GeneratedScene>? completedScenes,
    bool? isGenerating,
    String? currentStatus,
    String? error,
    bool? isComplete,
  }) {
    return ProductionQueueState(
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      completedScenes: completedScenes ?? this.completedScenes,
      isGenerating: isGenerating ?? this.isGenerating,
      currentStatus: currentStatus,
      error: error,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class GeneratedScene {
  final PlannedScene plan;
  final String? videoUrl;
  final List<ContinuityIssue> issues;
  final bool wasAutoFixed;

  GeneratedScene({
    required this.plan,
    this.videoUrl,
    this.issues = const [],
    this.wasAutoFixed = false,
  });
}

/// The genuine empty case — a planned scene with no characters attached
/// at all. Not fabricated identity data; it's a real, honestly-empty
/// Character for the rare case StoryPlan.characters is empty.
live.Character _placeholderCharacter() => live.Character(
      id: 'unassigned',
      name: 'Unassigned',
      avatarUrl: '',
      wardrobeDNA: const [],
      dna: continuity.CharacterDNA.empty(),
      faceReferenceUrls: const [],
      activeOutfitId: '',
      closet: const [],
    );

live.Character _toLiveCharacter(CharacterDNA dna) => live.Character(
      id: dna.id,
      name: dna.name,
      avatarUrl: dna.faceReferenceUrl ?? '',
      wardrobeDNA: dna.closet.map((outfit) => outfit.name).toList(),
      dna: continuity.CharacterDNA(
        id: dna.id,
        face: dna.faceReferenceUrl == null ? 0.5 : 1.0,
        body: 0.5,
        wardrobe: dna.closet.isEmpty ? 0.5 : 1.0,
        voice: 0.5,
        style: 0.5,
        locked: dna.continuityLock,
      ),
      faceReferenceUrls: [
        if (dna.faceReferenceUrl != null && dna.faceReferenceUrl!.isNotEmpty)
          dna.faceReferenceUrl!,
      ],
      activeOutfitId: dna.defaultOutfitId,
      closet: dna.closet,
      continuityLock: dna.continuityLock,
    );

class ProductionQueueNotifier extends StateNotifier<ProductionQueueState> {
  final StoryPlan plan;
  final AIGenerationService _generation;

  ProductionQueueNotifier({
    required this.plan,
    required AIGenerationService generationService,
  })  : _generation = generationService,
        super(ProductionQueueState());

  Future<void> startProduction(String projectId) async {
    state = state.copyWith(isGenerating: true, currentStatus: 'Checking continuity...');

    for (int i = 0; i < plan.scenes.length; i++) {
      state = state.copyWith(currentSceneIndex: i);

      final scenePlan = plan.scenes[i];

      // Convert the selected story-plan character into the live scene model.
      final primaryDNA = plan.characters.isEmpty
          ? null
          : plan.characters.firstWhere(
              (c) => scenePlan.characterIds.contains(c.id),
              orElse: () => plan.characters.first,
            );
      final sceneCharacter = primaryDNA != null
          ? _toLiveCharacter(primaryDNA)
          : _placeholderCharacter();

      final fixedScene = SceneNode(
        id: 'scene_$i',
        sequenceIndex: i,
        prompt: scenePlan.description,
        character: sceneCharacter,
        locationId: scenePlan.locationId,
        lighting: scenePlan.lighting,
        characterIds: scenePlan.characterIds,
        characterOutfits: const {},
      );
      final report = ContinuityHealthAnalyzer().analyze(
        characters: plan.characters.map(_toLiveCharacter).toList(),
        scenes: [fixedScene],
      );
      final issues = report.issues;

      final hasTokens = await TokenService.deduct(15);
      if (!hasTokens) {
        state = state.copyWith(
          isGenerating: false,
          error: 'Not enough tokens. Upgrade or top up to continue.',
        );
        return;
      }

      state = state.copyWith(currentStatus: 'Generating scene ${i + 1} of ${plan.scenes.length}...');

      try {
        final videoUrl = await _generation.generateVideo(
          prompt: _buildEnhancedPrompt(scenePlan, plan.characters),
          cameraMotion: scenePlan.shots.first,
        );

        state = state.copyWith(
          completedScenes: [
            ...state.completedScenes,
            GeneratedScene(
              plan: scenePlan,
              videoUrl: videoUrl,
              issues: issues,
              wasAutoFixed: false,
            ),
          ],
        );

      } catch (e) {
        state = state.copyWith(
          isGenerating: false,
          error: 'Scene ${i + 1} failed: $e',
        );
        return;
      }
    }

    state = state.copyWith(
      isGenerating: false,
      isComplete: true,
      currentStatus: 'Production complete!',
    );
  }

  String _buildEnhancedPrompt(PlannedScene scene, List<CharacterDNA> characters) {
    final charDescriptions = characters
        .where((c) => scene.characterIds.contains(c.id))
        .map((c) {
          // PlannedScene has no per-scene outfit map (that's a SceneNode
          // field) — the real data here is wardrobeNote from the story
          // plan, falling back to the character's own default outfit.
          final outfitName = c.closet.isEmpty
              ? null
              : c.closet.firstWhere((o) => o.id == c.defaultOutfitId, orElse: () => c.closet.first).name;
          final wardrobe = scene.wardrobeNote.isNotEmpty ? scene.wardrobeNote : outfitName;
          return '${c.name}: ${c.physical.ageRange}, ${c.physical.distinguishingFeatures}'
              '${wardrobe != null && wardrobe.isNotEmpty ? ', wearing $wardrobe' : ''}';
        })
        .join('. ');

    return '''
${scene.description}
Location: ${scene.heading}
Mood: ${scene.mood}
Lighting: ${scene.lighting}
Characters: $charDescriptions
Camera: ${scene.shots.join(', ')}
''';
  }
}

class ProductionQueueScreen extends ConsumerStatefulWidget {
  final StoryPlan plan;

  const ProductionQueueScreen({super.key, required this.plan});

  @override
  ConsumerState<ProductionQueueScreen> createState() => _ProductionQueueScreenState();
}

class _ProductionQueueScreenState extends ConsumerState<ProductionQueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productionQueueProvider(widget.plan).notifier)
          .startProduction('project_${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productionQueueProvider(widget.plan));

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PRODUCTION QUEUE',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DripTheme.warmWhite,
          ),
        ),
      ),
      body: Column(
        children: [
          if (state.currentStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                state.currentStatus!,
                style: const TextStyle(color: DripTheme.chrome, fontSize: 12),
              ),
            ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                state.error!,
                style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: widget.plan.scenes.length,
              itemBuilder: (context, index) {
                final scene = widget.plan.scenes[index];
                final isCompleted = index < state.completedScenes.length;
                final isCurrent =
                    index == state.currentSceneIndex && state.isGenerating;
                final generated =
                    isCompleted ? state.completedScenes[index] : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? DripTheme.cosmicTeal.withOpacity(0.05)
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? DripTheme.cosmicTeal.withOpacity(0.3)
                          : isCompleted
                              ? DripTheme.cosmicTeal.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SCENE ${scene.sceneNumber}',
                            style: const TextStyle(
                              letterSpacing: 1.5,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DripTheme.warmWhite,
                            ),
                          ),
                          const Spacer(),
                          if (isCompleted)
                            const Icon(Icons.check_circle,
                                size: 16, color: DripTheme.cosmicTeal),
                          if (isCurrent)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DripTheme.cosmicTeal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scene.heading,
                        style: const TextStyle(
                          color: DripTheme.chrome,
                          fontSize: 12,
                        ),
                      ),
                      if (generated?.videoUrl != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          generated!.videoUrl!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DripTheme.aquaGlow,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          if (state.isComplete)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DripTheme.cosmicTeal,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('DONE'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
