import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../widgets/cinematic_card.dart';
import 'character_lab_screen.dart';
import 'character_creation_screen.dart';
import 'drip_chains_screen.dart';
import 'export_screen.dart';
import 'timeline_screen.dart';
import 'edit_bay_screen.dart';
import 'paywall_screen.dart';
import 'style_dna_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);
    final characters = ref.watch(characterListProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LIBRARY', style: DripTheme.overline),
              const SizedBox(height: 10),
              const Text('Your universe', style: DripTheme.display),
              const SizedBox(height: 10),
              Text(
                '${scenes.length} scenes · ${characters.length} characters',
                style: DripTheme.body,
              ),
              const SizedBox(height: 28),

              const Text('PRODUCTION', style: DripTheme.technical),
              const SizedBox(height: 12),
              _LibItem(
                title: 'ACTIVE CUT',
                subtitle: scenes.isEmpty
                    ? 'No scenes yet'
                    : '${scenes.length} scene${scenes.length == 1 ? '' : 's'} on the timeline',
                icon: Icons.view_timeline_outlined,
                onTap: scenes.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TimelineScreen()),
                        ),
              ),
              _LibItem(
                title: 'EDIT BAY',
                subtitle: 'Cut, grade, export',
                icon: Icons.movie_filter_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditBayScreen()),
                ),
              ),
              _LibItem(
                title: 'EXPORT',
                subtitle: 'Full cut or trailer · 16:9 / 9:16 / 1:1',
                icon: Icons.ios_share_outlined,
                onTap: scenes.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ExportScreen()),
                        ),
              ),

              const SizedBox(height: 20),
              const Text('CAST & STYLE', style: DripTheme.technical),
              const SizedBox(height: 12),
              _LibItem(
                title: 'CHARACTERS',
                subtitle: characters.isEmpty
                    ? 'No actors locked yet'
                    : '${characters.length} with continuity',
                icon: Icons.person_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => characters.isEmpty
                        ? const CharacterCreationScreen()
                        : const CharacterLabScreen(),
                  ),
                ),
              ),
              _LibItem(
                title: 'STYLE DNA',
                subtitle: 'Reusable visual language',
                icon: Icons.auto_awesome_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StyleDnaScreen()),
                ),
              ),
              _LibItem(
                title: 'PROP VAULT',
                subtitle: 'Recurring objects for continuity',
                icon: Icons.inventory_2_outlined,
                onTap: null,
              ),

              const SizedBox(height: 20),
              const Text('COLLABORATION', style: DripTheme.technical),
              const SizedBox(height: 12),
              _LibItem(
                title: 'DRIP CHAINS',
                subtitle: 'Collaborative films — start or extend',
                icon: Icons.link,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DripChainsScreen()),
                ),
              ),

              const SizedBox(height: 20),
              const Text('STUDIO', style: DripTheme.technical),
              const SizedBox(height: 12),
              _LibItem(
                title: 'DRIPVISION PRO',
                subtitle: 'Private studio · advanced memory · 4K',
                icon: Icons.workspace_premium_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DripPaywallScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _LibItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CinematicCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: enabled ? DripTheme.cosmicTeal : DripTheme.muted,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                          color: enabled ? DripTheme.warmWhite : DripTheme.muted,
                        ),
                      ),
                      if (!enabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('SOON', style: DripTheme.technical),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: DripTheme.meta),
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right, size: 18, color: DripTheme.muted),
          ],
        ),
      ),
    );
  }
}
