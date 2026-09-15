import '../../core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/character.dart' as live;
import '../../models/character_dna.dart';
import '../../models/scene.dart';
import '../../services/ai_generation_service.dart';
import '../../services/continuity_service.dart';
import '../../services/token_service.dart';
import 'story_planner_screen.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/galaxy_background.dart';

final productionQueueProvider = StateNotifierProvider.family<ProductionQueueNotifier, ProductionQueueState, StoryPlan>(
  (ref, plan) => ProductionQueueNotifier(
    plan: plan,
    generationService: ref.read(aiGenerationServiceProvider),
    continuityService: ref.read(continuityServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
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
      faceReferenceUrls: const [],
      activeOutfitId: '',
      closet: const [],
    );

class ProductionQueueNotifier extends StateNotifier<ProductionQueueState> {
  final StoryPlan plan;
  final AIGenerationService _generation;
  final ContinuityService _continuity;
  final TokenService _tokens;

  ProductionQueueNotifier({
    required this.plan,
    required AIGenerationService generationService,
    required ContinuityService continuityService,
    required TokenService tokenService,
  })  : _generation = generationService,
        _continuity = continuityService,
        _tokens = tokenService,
        super(ProductionQueueState());

  Future<void> startProduction(String projectId) async {
    state = state.copyWith(isGenerating: true, currentStatus: 'Checking continuity...');

    for (int i = 0; i < plan.scenes.length; i++) {
      state = state.copyWith(currentSceneIndex: i);

      final scenePlan = plan.scenes[i];

      // ContinuityService itself never reads SceneNode.character — only
      // characterIds/characterOutfits — but the model requires a non-null
      // Character. Building a real one from this scene's actual planned
      // character (via the shared CharacterDNA -> Character bridge)
      // instead of a fake/empty placeholder.
      final primaryDNA = plan.characters.isEmpty
          ? null
          : plan.characters.firstWhere(
              (c) => scenePlan.characterIds.contains(c.id),
              orElse: () => plan.characters.first,
            );
      final sceneCharacter = primaryDNA != null ? live.Character.fromDNA(primaryDNA) : _placeholderCharacter();

      final issues = await _continuity.checkContinuity(
        projectId: projectId,
        proposedScene: SceneNode(
          id: 'scene_$i',
          prompt: scenePlan.description,
          character: sceneCharacter,
          locationId: scenePlan.locationId,
          lighting: scenePlan.lighting,
          characterIds: scenePlan.characterIds,
          characterOutfits: const {},
        ),
        characters: plan.characters,
        previousSceneId: i > 0 ? 'scene_${i-1}' : null,
      );

      var fixedScene = SceneNode(
        id: 'scene_$i',
        prompt: scenePlan.description,
        character: sceneCharacter,
        locationId: scenePlan.locationId,
        lighting: scenePlan.lighting,
        characterIds: scenePlan.characterIds,
        characterOutfits: const {},
      );

      if (issues.any((i) => i.autoFixable)) {
        state = state.copyWith(currentStatus: 'Fixing continuity...');
        fixedScene = await _continuity.autoFix(
          scene: fixedScene,
          issues: issues,
          projectId: projectId,
        );
      }

      final hasTokens = await _tokens.deduct(15);
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
              wasAutoFixed: issues.any((i) => i.autoFixable),
            ),
          ],
        );

        await _continuity.commitScene(
          projectId: projectId,
          scene: fixedScene,
          characters: plan.characters,
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
      ref.read(productionQueueProvider(widget.plan).notifier)
          .startProduction('project_${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productionQueueProvider(widget.plan));

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 60, intensity: 0.2),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRODUCTION',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 4,
                                color: DripTheme.cosmicTeal.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.plan.title.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.plan.scenes.isEmpty
                        ? 0
                        : (state.currentSceneIndex + (state.isGenerating ? 0 : 1)) / widget.plan.scenes.length,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(DripTheme.cosmicTeal),
                      minHeight: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (state.currentStatus != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      state.currentStatus!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: DripTheme.cosmicTeal.withOpacity(0.8),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: widget.plan.scenes.length,
                    itemBuilder: (context, index) {
                      final scene = widget.plan.scenes[index];
                      final isCompleted = index < state.completedScenes.length;
                      final isCurrent = index == state.currentSceneIndex && state.isGenerating;
                      final generated = isCompleted ? state.completedScenes[index] : null;

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
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                      ? DripTheme.cosmicTeal.withOpacity(0.2)
                                      : isCurrent
                                        ? DripTheme.cosmicTeal.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: isCompleted
                                      ? Icon(Icons.check, size: 16, color: DripTheme.cosmicTeal)
                                      : isCurrent
                                        ? SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: DripTheme.cosmicTeal,
                                            ),
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white30,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    scene.heading,
                                    style: TextStyle(
                                      color: isCompleted || isCurrent ? Colors.white : DripColors.white40,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (generated?.wasAutoFixed ?? false)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'FIXED',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (generated?.videoUrl != null) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: VideoPlayerWidget(
                                    url: generated!.videoUrl!,
                                    autoPlay: index == state.currentSceneIndex - 1,
                                    showControls: true,
                                  ),
                                ),
                              ),
                            ],
                            if (generated?.issues.isNotEmpty ?? false) ...[
                              const SizedBox(height: 8),
                              ...generated!.issues.map((issue) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      issue.autoFixable ? Icons.auto_fix_high : Icons.warning_amber,
                                      size: 14,
                                      color: issue.autoFixable ? Colors.amber : Colors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        issue.message,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: DripColors.white40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                if (state.isComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          DripTheme.voidBlack.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('WATCH FILM'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DripTheme.cosmicTeal,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
