import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import 'character_lab_screen.dart';
import 'edit_bay_screen.dart';
import 'settings_screen.dart';
import 'story_planner_screen.dart';
import 'timeline_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'GOOD MORNING'
        : hour < 18
            ? 'GOOD AFTERNOON'
            : 'GOOD EVENING';

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('DRIPVISION', style: DripTheme.brandMark),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      icon: const Icon(Icons.person_outline, size: 22, color: DripTheme.chrome),
                    ),
                  ],
                ),
              ),
            ),

            // Hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, DIRECTOR.', style: DripTheme.overline),
                    const SizedBox(height: 10),
                    const Text(
                      'An AI filmmaking studio\nthat remembers your\nentire universe.',
                      style: DripTheme.display,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      scenes.isEmpty
                          ? 'Start with a story, lock characters, then cut in the Edit Bay.'
                          : '${scenes.length} scene${scenes.length == 1 ? '' : 's'} on the active timeline.',
                      style: DripTheme.body,
                    ),
                  ],
                ),
              ),
            ),

            // Primary actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  children: [
                    CinematicButton(
                      label: 'STORY   FILM',
                      icon: Icons.auto_stories_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoryPlannerScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CinematicButton(
                            label: 'EDIT BAY',
                            icon: Icons.movie_filter_outlined,
                            primary: false,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditBayScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CinematicButton(
                            label: "CUT",
                            icon: Icons.view_timeline_outlined,
                            primary: false,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TimelineScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pipeline
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRODUCTION PIPELINE', style: DripTheme.technical),
                    const SizedBox(height: 14),
                    _PipelineStep(
                      index: '01',
                      title: 'Story',
                      subtitle: 'Plan the narrative',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StoryPlannerScreen()),
                      ),
                    ),
                    _PipelineStep(
                      index: '02',
                      title: 'Characters',
                      subtitle: 'Lock face & wardrobe DNA',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CharacterLabScreen()),
                      ),
                    ),
                    _PipelineStep(
                      index: '03',
                      title: 'Studio',
                      subtitle: 'Direct the shot',
                      onTap: () => ref.read(navIndexProvider.notifier).state = 3,
                    ),
                    _PipelineStep(
                      index: '04',
                      title: 'Edit Bay',
                      subtitle: 'Cut, grade, finish',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditBayScreen()),
                      ),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Recent scenes
            if (scenes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('ACTIVE CUT', style: DripTheme.technical),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TimelineScreen()),
                            ),
                            child: const Text(
                              'OPEN',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.4,
                                color: DripTheme.cosmicTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...scenes.take(4).map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CinematicCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: DripTheme.surfaceLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: s.generatedLastFrameUrl != null
                                        ? Image.network(
                                            s.generatedLastFrameUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.movie, size: 18, color: DripTheme.muted),
                                          )
                                        : const Icon(Icons.movie, size: 18, color: DripTheme.muted),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SCENE ${(s.sequenceIndex + 1).toString().padLeft(2, '0')}',
                                          style: DripTheme.technical,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          s.prompt.isEmpty ? s.character.name : s.prompt,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, color: DripTheme.warmWhite),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _PipelineStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Text(index,
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: DripTheme.cosmicTeal,
                        fontWeight: FontWeight.w600,
                      )),
                  if (!isLast)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 1,
                      height: 28,
                      color: Colors.white.withOpacity(0.08),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: DripTheme.meta),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right, size: 18, color: DripTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
