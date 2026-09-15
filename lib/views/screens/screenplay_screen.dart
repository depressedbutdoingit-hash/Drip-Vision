import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../widgets/cinematic_button.dart';
import 'story_planner_screen.dart';
import 'storyboard_screen.dart';
import 'generator_screen.dart';
import '../../core/providers.dart';

/// SCREENPLAY
/// Renders the real StoryPlan the AI Director already produced —
/// industry slug lines, action, character cues and dialogue — instead of
/// generic scene cards. Reads storyPlanProvider directly, so anything
/// planned in Story Planner shows here with zero duplicate data entry.
class ScreenplayScreen extends ConsumerWidget {
  const ScreenplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(storyPlanProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('SCREENPLAY', style: TextStyle(fontSize: 12, letterSpacing: 3)),
        actions: [
          if (plan != null)
            IconButton(
              icon: const Icon(Icons.grid_view_outlined, size: 20),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryboardScreen())),
              tooltip: 'Storyboard',
            ),
        ],
      ),
      body: SafeArea(
        child: plan == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Plan a story in Story Planner first — the screenplay writes itself from there.', textAlign: TextAlign.center, style: TextStyle(color: DripTheme.muted, height: 1.5)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(plan.title.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 2)),
                          const SizedBox(height: 6),
                          Text(plan.logline, textAlign: TextAlign.center, style: const TextStyle(color: DripTheme.muted, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    ...plan.scenes.map((s) => _ScreenplayScene(scene: s)),
                    const SizedBox(height: 20),
                    CinematicButton(
                      label: 'GENERATE STORYBOARD',
                      icon: Icons.grid_view_outlined,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryboardScreen())),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ScreenplayScene extends ConsumerWidget {
  final PlannedScene scene;
  const _ScreenplayScene({required this.scene});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scene.heading.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .5, fontFamily: 'monospace')),
          const SizedBox(height: 10),
          Text(scene.description, style: const TextStyle(height: 1.7, fontFamily: 'monospace', color: DripTheme.warmWhite)),
          if (scene.dialogue.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...scene.dialogue.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Column(
                        children: [
                          Text(e.key.toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, color: DripTheme.cosmicTeal)),
                          const SizedBox(height: 4),
                          Text(e.value, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text('SCENE ${scene.sceneNumber.toString().padLeft(2, '0')} · ${scene.mood.toUpperCase()}', style: const TextStyle(fontSize: 9.5, letterSpacing: 1.6, color: DripTheme.muted)),
              const Spacer(),
              GestureDetector(
                onTap: () => _generateVideo(context, ref),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.movie_creation_outlined, size: 14, color: DripTheme.aquaGlow),
                    SizedBox(width: 5),
                    Text('GENERATE VIDEO', style: TextStyle(fontSize: 10, letterSpacing: 1, color: DripTheme.aquaGlow, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 16), child: Divider(color: Colors.white10, height: 1)),
        ],
      ),
    );
  }

  void _generateVideo(BuildContext context, WidgetRef ref) {
    // Wires the planned scene straight into the real generator — the
    // description + shot list become the prompt, so "Generate Video"
    // isn't decorative.
    ref.read(pendingScenePromptProvider.notifier).state =
        '${scene.description} ${scene.shots.isNotEmpty ? 'Shots: ${scene.shots.join(', ')}.' : ''}';
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DripVisionStudioScreen()));
  }
}
