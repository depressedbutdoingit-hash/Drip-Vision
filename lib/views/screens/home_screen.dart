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
import 'main_navigation.dart';

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
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: MainNavigation.openDrawer,
                      icon: const Icon(
                        Icons.menu,
                        size: 22,
                        color: DripTheme.chrome,
                      ),
                    ),
                    const Expanded(
                      child: Text('DRIPVISION', style: DripTheme.brandMark),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      icon: const Icon(
                        Icons.person_outline,
                        size: 22,
                        color: DripTheme.chrome,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, DIRECTOR.', style: DripTheme.overline),
                    const SizedBox(height: 14),
                    const Text(
                      'An AI filmmaking studio\nthat remembers your\nentire universe.',
                      style: DripTheme.display,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      scenes.isEmpty
                          ? 'Start with a story. Lock characters. Finish in the Edit Bay.'
                          : '${scenes.length} scene${scenes.length == 1 ? '' : 's'} on the active timeline.',
                      style: DripTheme.body,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                child: Column(
                  children: [
                    CinematicButton(
                      label: 'STORY → FILM',
                      icon: Icons.auto_stories_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoryPlannerScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CinematicButton(
                            label: 'EDIT BAY',
                            icon: Icons.movie_filter_outlined,
                            primary: false,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditBayScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CinematicButton(
                            label: 'CUT',
                            icon: Icons.view_timeline_outlined,
                            primary: false,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TimelineScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PIPELINE', style: DripTheme.technical),
                    const SizedBox(height: 20),
                    _Step(
                      index: '01',
                      title: 'Story',
                      subtitle: 'Plan the narrative',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoryPlannerScreen(),
                        ),
                      ),
                    ),
                    _Step(
                      index: '02',
                      title: 'Characters',
                      subtitle: 'Lock face and wardrobe DNA',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CharacterLabScreen(),
                        ),
                      ),
                    ),
                    _Step(
                      index: '03',
                      title: 'Studio',
                      subtitle: 'Direct the shot',
                      onTap: () =>
                          ref.read(navIndexProvider.notifier).state = 3,
                    ),
                    _Step(
                      index: '04',
                      title: 'Edit Bay',
                      subtitle: 'Cut, grade, finish',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditBayScreen(),
                        ),
                      ),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            if (scenes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
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
                              MaterialPageRoute(
                                builder: (_) => const TimelineScreen(),
                              ),
                            ),
                            child: const Text(
                              'OPEN',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.6,
                                color: DripTheme.cosmicTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...scenes.take(4).map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CinematicCard(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: DripTheme.surfaceLight,
                                        borderRadius: BorderRadius.circular(
                                          DripTheme.radiusSm,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: s.generatedLastFrameUrl != null
                                          ? Image.network(
                                              s.generatedLastFrameUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.movie_outlined,
                                                size: 18,
                                                color: DripTheme.muted,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.movie_outlined,
                                              size: 18,
                                              color: DripTheme.muted,
                                            ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'SCENE ${(s.sequenceIndex + 1).toString().padLeft(2, '0')}',
                                            style: DripTheme.technical,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            s.prompt.isEmpty
                                                ? s.character.name
                                                : s.prompt,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: DripTheme.warmWhite,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 56)),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _Step({
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
      borderRadius: BorderRadius.circular(DripTheme.radiusSm),
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Text(
                    index,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: DripTheme.faint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      width: 1,
                      height: 28,
                      color: DripTheme.hairline,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: DripTheme.title),
                    const SizedBox(height: 3),
                    Text(subtitle, style: DripTheme.meta),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: DripTheme.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
