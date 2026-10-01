import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../services/god_mode_service.dart';
import '../screens/edit_bay_screen.dart';
import '../screens/god_mode/god_mode_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/story_planner_screen.dart';
import '../screens/timeline_screen.dart';
import '../screens/character_lab_screen.dart';
import '../screens/export_screen.dart';

/// Left studio menu — quiet, expensive, production-oriented.
class StudioDrawer extends ConsumerWidget {
  const StudioDrawer({super.key});

  void _goTab(BuildContext context, WidgetRef ref, int index) {
    Navigator.pop(context);
    ref.read(navIndexProvider.notifier).state = index;
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Director';
    final scenes = ref.watch(sceneListProvider);

    return Drawer(
      backgroundColor: DripTheme.deepBlack,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DRIPVISION', style: DripTheme.brandMark),
                  const SizedBox(height: 8),
                  const Text('STUDIO MENU', style: DripTheme.technical),
                  const SizedBox(height: 16),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DripTheme.meta,
                  ),
                  if (scenes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${scenes.length} scene${scenes.length == 1 ? '' : 's'} in cut',
                      style: const TextStyle(
                        fontSize: 11,
                        color: DripTheme.faint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: DripTheme.hairline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _section('NAVIGATE'),
                  _item(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _goTab(context, ref, 0),
                  ),
                  _item(
                    icon: Icons.add_box_outlined,
                    label: 'Create',
                    onTap: () => _goTab(context, ref, 1),
                  ),
                  _item(
                    icon: Icons.folder_open_outlined,
                    label: 'Library',
                    onTap: () => _goTab(context, ref, 2),
                  ),
                  _item(
                    icon: Icons.tune_outlined,
                    label: 'Studio',
                    onTap: () => _goTab(context, ref, 3),
                  ),
                  _item(
                    icon: Icons.explore_outlined,
                    label: 'Explore',
                    onTap: () => _goTab(context, ref, 4),
                  ),
                  const SizedBox(height: 8),
                  _section('PRODUCTION'),
                  _item(
                    icon: Icons.auto_stories_outlined,
                    label: 'Story → Film',
                    onTap: () => _push(context, const StoryPlannerScreen()),
                  ),
                  _item(
                    icon: Icons.person_outline,
                    label: 'Characters',
                    onTap: () => _push(context, const CharacterLabScreen()),
                  ),
                  _item(
                    icon: Icons.movie_filter_outlined,
                    label: 'Edit Bay',
                    onTap: () => _push(context, const EditBayScreen()),
                  ),
                  _item(
                    icon: Icons.view_timeline_outlined,
                    label: "Director's Cut",
                    onTap: () => _push(context, const TimelineScreen()),
                  ),
                  _item(
                    icon: Icons.ios_share_outlined,
                    label: 'Export',
                    onTap: () => _push(context, const ExportScreen()),
                  ),
                  const SizedBox(height: 8),
                  _section('ACCOUNT'),
                  _item(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  // Only visible to admins — not every user
                  FutureBuilder<bool>(
                    future: GodModeService.isAuthorizedAdmin(),
                    builder: (context, snap) {
                      if (snap.data != true) {
                        return const SizedBox.shrink();
                      }
                      return _item(
                        icon: Icons.security,
                        label: 'God Mode',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GodModeScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: DripTheme.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              child: Text(
                'An AI filmmaking studio that\nremembers your entire universe.',
                style: DripTheme.meta.copyWith(height: 1.45, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
      child: Text(title, style: DripTheme.technical),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, size: 20, color: DripTheme.chrome),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: DripTheme.warmWhite,
          letterSpacing: 0.2,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}
