import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'library_screen.dart';
import 'studio_screen.dart';
import 'explore_drip_screen.dart';
import 'settings_screen.dart';
import '../widgets/system_banner.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = ref.watch(navIndexProvider);
    final screens = [
      const HomeScreen(),
      const CreateScreen(),
      const LibraryScreen(),
      const StudioScreen(),
      const ExploreDripScreen(),
    ];

    // Home owns its own header; other tabs get a quiet brand bar.
    final showAppBar = i != 0;

    return SystemBannerHost(
      child: Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: showAppBar
          ? AppBar(
              title: const Text('DRIPVISION', style: DripTheme.brandMark),
              actions: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  icon: const Icon(Icons.person_outline, size: 21, color: DripTheme.chrome),
                ),
                const SizedBox(width: 4),
              ],
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(i),
          child: screens[i],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: DripTheme.deepBlack,
          border: Border(top: BorderSide(color: DripTheme.hairline)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nav(ref, 0, Icons.home_outlined, 'HOME', i),
                _nav(ref, 1, Icons.add_box_outlined, 'CREATE', i),
                _nav(ref, 2, Icons.folder_open_outlined, 'LIBRARY', i),
                _nav(ref, 3, Icons.tune_outlined, 'STUDIO', i),
                _nav(ref, 4, Icons.explore_outlined, 'EXPLORE', i),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(navIndexProvider.notifier).state = index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? DripTheme.cosmicTeal : DripTheme.muted,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.3,
                color: selected ? DripTheme.cosmicTeal : DripTheme.muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
