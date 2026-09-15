import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_media_card.dart';
import '../widgets/section_header.dart';
import 'character_lab_screen.dart';
import 'drip_chains_screen.dart';
import 'export_screen.dart';
import 'paywall_screen.dart';
import 'style_dna_screen.dart';
import 'timeline_screen.dart';

/// LIBRARY — everything DripVision remembers, in one place.
/// Previously this screen pointed at three screens that either didn't
/// exist under that name or required arguments it never passed
/// (ProductFolder, a bare CharacterClosetScreen, PaywallScreen) — none
/// of it would have compiled. Rebuilt to point at real, working screens
/// and to show your actual cut instead of a dead "My Creations" grid.
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
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LIBRARY', style: TextStyle(fontSize: 11, letterSpacing: 3, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('YOUR UNIVERSE', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Every character, place, prop and cut — remembered.', style: TextStyle(color: DripTheme.muted)),
              const SizedBox(height: 26),

              SectionHeader(eyebrow: 'CURRENT CUT', title: '${scenes.length.toString().padLeft(2, '0')} scenes', action: scenes.isEmpty ? null : 'OPEN TIMELINE', onAction: scenes.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen()))),
              scenes.isEmpty
                  ? const CinematicCard(child: Text('Your next film starts here. Generate a scene to begin your cut.', style: TextStyle(color: DripTheme.muted, height: 1.5)))
                  : SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: scenes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (c, i) {
                          final s = scenes[i];
                          return CinematicMediaCard(
                            title: 'SCENE ${(i + 1).toString().padLeft(2, '0')}',
                            meta: '${s.cameraMotion ?? 'STATIC'}  •  ${s.character.name}',
                            imageUrl: s.generatedLastFrameUrl ?? s.inputLastFrameUrl,
                            width: 190,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen())),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 26),

              SectionHeader(eyebrow: 'DRIP MEMORY™', title: 'Characters', action: 'OPEN LAB', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterLabScreen()))),
              characters.isEmpty
                  ? const CinematicCard(child: Text('Every story needs someone worth remembering.', style: TextStyle(color: DripTheme.muted, height: 1.5)))
                  : SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: characters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (c, i) {
                          final ch = characters[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterLabScreen(characterId: ch.id))),
                            child: Container(
                              width: 64,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: DripTheme.surface, border: Border.all(color: Colors.white.withOpacity(.07))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.person, color: DripTheme.chrome, size: 22),
                                  const SizedBox(height: 6),
                                  Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: DripTheme.muted)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 26),

              const SectionHeader(eyebrow: 'DEPARTMENTS', title: 'Locations, Props & Sound'),
              _item(context, 'STYLE DNA™', 'Saved visual languages, ready to apply.', Icons.auto_awesome_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleDnaScreen()))),
              _item(context, 'LOCATION BIBLE', 'Where does your story happen?', Icons.location_on_outlined, null),
              _item(context, 'PROP VAULT', 'Recurring objects, locked for continuity.', Icons.inventory_2_outlined, null),
              _item(context, 'DRIP CHAINS', 'Collaborative films — start or extend one.', Icons.link, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DripChainsScreen()))),
              _item(context, 'SOUND DEPARTMENT', 'Music, ambience and SFX per scene', Icons.graphic_eq_outlined, scenes.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen()))),
              _item(context, 'EXPORT', 'Full cut or trailer — 16:9, 9:16 or 1:1.', Icons.ios_share, scenes.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()))),
              const SizedBox(height: 14),
              _item(context, 'DRIPVISION PRO', 'Private studio • advanced memory • 4K export', Icons.workspace_premium_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DripPaywallScreen()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext c, String title, String sub, IconData icon, VoidCallback? tap) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CinematicCard(
          onTap: tap,
          child: Row(
            children: [
              Icon(icon, color: DripTheme.nebulaCyan, size: 25),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title, style: const TextStyle(fontSize: 13, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
                      if (tap == null) ...[
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(5)), child: const Text('SOON', style: TextStyle(fontSize: 8, letterSpacing: 1, color: DripTheme.muted))),
                      ],
                    ]),
                    const SizedBox(height: 5),
                    Text(sub, style: const TextStyle(fontSize: 12, color: DripTheme.muted)),
                  ],
                ),
              ),
              if (tap != null) const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      );
}
