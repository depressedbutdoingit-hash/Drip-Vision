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

    final screens = <Widget>[
      const DripVisionStudioScreen(),
      const StoryPlannerScreen(),
      const ExploreDripScreen(),
      const MusicStudioScreen(),
      const LibraryScreen(),
    ];

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
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: openDrawer,
                        icon: const Icon(Icons.menu, size: 22, color: DripTheme.chrome),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Edit Bay',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditBayScreen()),
                        ),
                        icon: const Icon(Icons.content_cut, size: 20, color: DripTheme.chrome),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.settings_outlined, size: 20, color: DripTheme.chrome),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(i),
                  child: screens[i],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: DripTheme.deepBlack.withOpacity(0.95),
            border: const Border(top: BorderSide(color: DripTheme.hairline, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _nav(ref, 0, Icons.movie_creation_outlined, 'STUDIO', i),
                  _nav(ref, 1, Icons.menu_book_outlined, 'STORY', i),
                  _createButton(context),
                  _nav(ref, 3, Icons.music_note_outlined, 'MUSIC', i),
                  _nav(ref, 4, Icons.folder_outlined, 'VAULT', i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createButton(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GeneratorScreen()),
          ),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DripTheme.teal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DripTheme.teal.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.black, size: 26),
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
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.8,
                color: selected ? DripTheme.cosmicTeal : DripTheme.faint,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
