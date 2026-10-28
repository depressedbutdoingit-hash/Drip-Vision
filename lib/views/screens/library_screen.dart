import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/app_providers.dart';
import '../widgets/cinematic_card.dart';
import 'character_lab_screen.dart';
import 'character_creation_screen.dart';
import 'drip_chains_screen.dart';
import 'export_screen.dart';
import 'timeline_screen.dart';
import 'edit_bay_screen.dart';
import 'paywall_screen.dart';
import 'style_dna_screen.dart';
import 'music_studio_screen.dart';

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
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Drips', style: DripTheme.display),
                        SizedBox(height: 6),
                        Text(
                          'Your scenes, characters, and scores.',
                          style: DripTheme.meta,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Music studio',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MusicStudioScreen()),
                    ),
                    icon: const Icon(Icons.music_note_outlined, color: DripTheme.chrome),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text('CAST', style: DripTheme.technical),
              const SizedBox(height: 12),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: characters.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    if (index == characters.length) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CharacterCreationScreen(),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: DripTheme.hairlineStrong),
                                color: DripTheme.surface,
                              ),
                              child: const Icon(Icons.add, color: DripTheme.chrome),
                            ),
                            const SizedBox(height: 6),
                            const Text('New', style: TextStyle(color: DripTheme.muted, fontSize: 11)),
                          ],
                        ),
                      );
                    }
                    final c = characters[index];
                    final av = c.faceReferenceUrls.isNotEmpty ? c.faceReferenceUrls.first : null;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: DripTheme.surfaceRaised,
                          backgroundImage: av != null ? NetworkImage(av) : null,
                          child: av == null
                              ? const Icon(Icons.person, color: DripTheme.chrome)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: DripTheme.cosmicTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (scenes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No scenes yet. Generate from Studio or run a production.',
                    style: DripTheme.meta,
                    textAlign: TextAlign.center,
                  ),
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
