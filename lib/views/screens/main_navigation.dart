import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/app_providers.dart';
import 'generator_screen.dart';
import 'story_planner_screen.dart';
import 'explore_drip_screen.dart';
import 'music_studio_screen.dart';
import 'studio_screen.dart';
import 'library_screen.dart';
import 'edit_bay_screen.dart';
import 'settings_screen.dart';
import '../widgets/system_banner.dart';
import '../widgets/studio_drawer.dart';
import '../widgets/drip_logo.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(navIndexProvider).clamp(0, 4).toInt();
    final profile = ref.watch(userProfileProvider).value;
    final tokens = profile?.tokenBalance ?? 0;

    final screens = <Widget>[
      DripVisionStudioScreen(), // 0 STUDIO
      StoryPlannerScreen(),     // 1 STORY
      ExploreDripScreen(),      // 2 EXPLORE
      MusicStudioScreen(),      // 3 MUSIC
      LibraryScreen(),          // 4 MY DRIPS
    ];

    // Explore is full-bleed cinematic feed.
    final hideChrome = i == 2;

    return SystemBannerHost(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: DripTheme.voidBlack,
        drawer: const StudioDrawer(),
        body: Column(
          children: [
            if (!hideChrome)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: openDrawer,
                        icon: const Icon(Icons.menu, size: 22, color: DripTheme.chrome),
                      ),
                      const DripLogo(compact: true, size: 30),
                      const Spacer(),
                      // Quick Edit Bay
                      IconButton(
                        tooltip: 'Edit Bay',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditBayScreen()),
                        ),
                        icon: const Icon(Icons.content_cut, size: 20, color: DripTheme.chrome),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: DripTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DripTheme.hairlineStrong),
                        ),
                        child: Text(
                          '$tokens TOK',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: DripTheme.warmWhite,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.settings_outlined,
                            size: 20, color: DripTheme.chrome),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(i),
                  child: screens[i],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: DripTheme.deepBlack,
            border: Border(top: BorderSide(color: DripTheme.hairline, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 58,
              child: Row(
                children: [
                  _nav(ref, 0, Icons.movie_creation_outlined, 'STUDIO', i),
                  _nav(ref, 1, Icons.menu_book_outlined, 'STORY', i),
                  _nav(ref, 2, Icons.explore_outlined, 'EXPLORE', i),
                  _nav(ref, 3, Icons.music_note_outlined, 'MUSIC', i),
                  _nav(ref, 4, Icons.folder_outlined, 'MY DRIPS', i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nav(WidgetRef ref, int index, IconData icon, String label, int current) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(navIndexProvider.notifier).state = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? DripTheme.cosmicTeal : DripTheme.faint,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 0.6,
                color: selected ? DripTheme.cosmicTeal : DripTheme.faint,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
