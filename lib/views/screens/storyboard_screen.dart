import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../widgets/cinematic_button.dart';
import 'story_planner_screen.dart';
import 'generator_screen.dart';
import 'studio_screen.dart';

/// STORYBOARD
/// A tappable grid of the same real PlannedScenes from storyPlanProvider.
/// Regenerate calls OpenRouter for real (through openRouterProvider's
/// cinematic-rewrite endpoint, same cost tracking as every other AI call)
/// rather than faking a rewrite locally.
class StoryboardScreen extends ConsumerStatefulWidget {
  const StoryboardScreen({super.key});

  @override
  ConsumerState<StoryboardScreen> createState() => _StoryboardScreenState();
}

class _StoryboardScreenState extends ConsumerState<StoryboardScreen> {
  int? _regeneratingScene;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(storyPlanProvider);
    final locked = ref.watch(lockedScenesProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('STORYBOARD', style: TextStyle(fontSize: 12, letterSpacing: 3))),
      body: SafeArea(
        child: plan == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Plan a story in Story Planner first — the storyboard builds itself from there.', textAlign: TextAlign.center, style: TextStyle(color: DripTheme.muted, height: 1.5)),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .82, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: plan.scenes.length,
                itemBuilder: (c, i) {
                  final scene = plan.scenes[i];
                  final isLocked = locked.contains(scene.sceneNumber);
                  final isRegenerating = _regeneratingScene == scene.sceneNumber;
                  return GestureDetector(
                    onTap: () => _openActions(context, scene),
                    child: Container(
                      decoration: BoxDecoration(
                        color: DripTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isLocked ? DripTheme.cosmicTeal.withOpacity(.5) : Colors.white.withOpacity(.07)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('SHOT ${scene.sceneNumber.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 9.5, letterSpacing: 1.4, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              if (isLocked) const Icon(Icons.lock_outline, size: 13, color: DripTheme.aquaGlow),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: isRegenerating
                                ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)))
                                : Text(scene.description, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, height: 1.4, color: DripTheme.chrome)),
                          ),
                          const SizedBox(height: 6),
                          Text(scene.heading, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: DripTheme.muted)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _openActions(BuildContext context, PlannedScene scene) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DripTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SHOT ${scene.sceneNumber.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, letterSpacing: 2, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(scene.description, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 18),
            CinematicButton(
              label: 'TURN INTO VIDEO',
              icon: Icons.movie_creation_outlined,
              onPressed: () {
                ref.read(pendingScenePromptProvider.notifier).state = '${scene.description} ${scene.shots.isNotEmpty ? 'Shots: ${scene.shots.join(', ')}.' : ''}';
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DripVisionStudioScreen()));
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: CinematicButton(
                  label: 'CHANGE CAMERA',
                  icon: Icons.videocam_outlined,
                  primary: false,
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudioScreen()));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CinematicButton(
                  label: 'REGENERATE',
                  icon: Icons.refresh_rounded,
                  primary: false,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _regenerate(scene);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 10),
            CinematicButton(
              label: ref.read(lockedScenesProvider).contains(scene.sceneNumber) ? 'UNLOCK COMPOSITION' : 'LOCK COMPOSITION',
              icon: ref.read(lockedScenesProvider).contains(scene.sceneNumber) ? Icons.lock_open_outlined : Icons.lock_outline,
              primary: false,
              onPressed: () {
                final locked = {...ref.read(lockedScenesProvider)};
                locked.contains(scene.sceneNumber) ? locked.remove(scene.sceneNumber) : locked.add(scene.sceneNumber);
                ref.read(lockedScenesProvider.notifier).state = locked;
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _regenerate(PlannedScene scene) async {
    if (ref.read(lockedScenesProvider).contains(scene.sceneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This shot is locked — unlock composition first.')));
      return;
    }
    setState(() => _regeneratingScene = scene.sceneNumber);
    try {
      final result = await ref.read(openRouterProvider).enhancePrompt(prompt: scene.description, modelSlug: 'anthropic/claude-3.5-sonnet');
      final tokenService = ref.read(tokenServiceProvider);
      final hasFunds = await tokenService.deduct(result.cost.tokenCost);
      if (!hasFunds) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough Drips to regenerate this shot.')));
        return;
      }
      final plan = ref.read(storyPlanProvider);
      if (plan == null) return;
      final updatedScenes = plan.scenes.map((s) => s.sceneNumber == scene.sceneNumber ? s.copyWith(description: result.text.trim()) : s).toList();
      ref.read(storyPlanProvider.notifier).state = plan.copyWith(scenes: updatedScenes);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Regenerate failed: $e')));
    } finally {
      if (mounted) setState(() => _regeneratingScene = null);
    }
  }
}
