import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../widgets/drip_button.dart';
import 'story_planner_screen.dart';
import 'character_lab_screen.dart';
import 'character_creation_screen.dart';
import 'directors_bible_screen.dart';
import 'continuity_health_screen.dart';
import 'storyboard_screen.dart';
import 'studio_screen.dart';
import 'edit_bay_screen.dart';
import 'export_screen.dart';
import 'screenplay_screen.dart';
import '../../core/app_providers.dart';

class _Step {
  final String id;
  final String title;
  final String subtitle;
  final bool Function(WidgetRef ref) done;
  final void Function(BuildContext context, WidgetRef ref) open;

  const _Step({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.open,
  });
}

/// STORY → FILM — production pipeline, not a prompt box.
class StoryPipelineScreen extends ConsumerWidget {
  const StoryPipelineScreen({super.key});

  List<_Step> get _steps => [
        _Step(
          id: 'premise',
          title: '1 · PREMISE',
          subtitle: 'Logline and world rules in the Director’s Bible',
          done: (ref) => ref.watch(filmBibleProvider).logline.trim().isNotEmpty,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const DirectorsBibleScreen()),
          ),
        ),
        _Step(
          id: 'cast',
          title: '2 · CAST',
          subtitle: 'Lock character DNA and wardrobe',
          done: (ref) => ref.watch(characterListProvider).isNotEmpty,
          open: (c, r) {
            final empty = r.read(characterListProvider).isEmpty;
            Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => empty
                    ? const CharacterCreationScreen()
                    : const CharacterLabScreen(),
              ),
            );
          },
        ),
        _Step(
          id: 'bible',
          title: '3 · UNIVERSE',
          subtitle: 'Genre, era, mood, props, visual laws',
          done: (ref) {
            final b = ref.watch(filmBibleProvider);
            return b.title.trim().isNotEmpty && b.genre.trim().isNotEmpty;
          },
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const DirectorsBibleScreen()),
          ),
        ),
        _Step(
          id: 'screenplay',
          title: '4 · SCREENPLAY',
          subtitle: 'Write or refine the script',
          done: (ref) => false,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const ScreenplayScreen()),
          ),
        ),
        _Step(
          id: 'plan',
          title: '5 · DIRECTOR PLAN',
          subtitle: 'Story → scene breakdown (AI Director)',
          done: (ref) => ref.watch(sceneListProvider).isNotEmpty,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const StoryPlannerScreen()),
          ),
        ),
        _Step(
          id: 'storyboard',
          title: '6 · STORYBOARD',
          subtitle: 'Visual beat board for the cut',
          done: (ref) => false,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const StoryboardScreen()),
          ),
        ),
        _Step(
          id: 'shots',
          title: '7 · GENERATE SHOTS',
          subtitle: 'Director Mode — shape and render',
          done: (ref) => ref
              .watch(sceneListProvider)
              .any((s) => s.outputVideoUrl != null),
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const StudioScreen()),
          ),
        ),
        _Step(
          id: 'continuity',
          title: '8 · CONTINUITY CHECK',
          subtitle: 'Health panel — wardrobe made visible',
          done: (ref) {
            final chars = ref.watch(characterListProvider);
            final scenes = ref.watch(sceneListProvider);
            if (chars.isEmpty) return false;
            // "done" when user has at least reviewed with some cast+scenes
            return scenes.isNotEmpty;
          },
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const ContinuityHealthScreen()),
          ),
        ),
        _Step(
          id: 'edit',
          title: '9 · EDIT BAY',
          subtitle: 'Cut, grade, assemble the film',
          done: (ref) => false,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const EditBayScreen()),
          ),
        ),
        _Step(
          id: 'export',
          title: '10 · EXPORT',
          subtitle: 'Master, vertical, or square delivery',
          done: (ref) => false,
          open: (c, r) => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const ExportScreen()),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = _steps;
    final doneCount = steps.where((s) => s.done(ref)).length;
    final bible = ref.watch(filmBibleProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('STORY → FILM', style: DripTheme.brandMark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            bible.title.isEmpty ? 'New production' : bible.title,
            style: DripTheme.display.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            '$doneCount / ${steps.length} stages · You direct. DripVision remembers.',
            style: DripTheme.meta,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: doneCount / steps.length,
              minHeight: 2,
              backgroundColor: DripTheme.surfaceLight,
              color: DripTheme.cosmicTeal,
            ),
          ),
          const SizedBox(height: 28),
          ...steps.map((s) {
            final done = s.done(ref);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: DripTheme.surface,
                borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                  onTap: () => s.open(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                      border: Border.all(color: DripTheme.hairline),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle_outline
                              : Icons.circle_outlined,
                          size: 18,
                          color: done ? DripTheme.cosmicTeal : DripTheme.muted,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: DripTheme.warmWhite,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(s.subtitle, style: DripTheme.meta),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: DripTheme.faint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          DripButton(
            width: double.infinity,
            height: 52,
            onPressed: () {
              // Jump to first incomplete step
              for (final s in steps) {
                if (!s.done(ref)) {
                  s.open(context, ref);
                  return;
                }
              }
              steps.last.open(context, ref);
            },
            child: const Text('CONTINUE PRODUCTION'),
          ),
        ],
      ),
    );
  }
}
