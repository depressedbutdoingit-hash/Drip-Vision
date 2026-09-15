import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character.dart';
import '../../models/character_dna.dart' as dna;
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_media_card.dart';
import '../widgets/section_header.dart';
import 'character_creation_screen.dart';
import 'custom_outfit_creator.dart';

/// CHARACTER LAB
/// Characters should feel like actors, not form entries. This screen is
/// the roster + a single actor's profile: identity, wardrobe, continuity
/// and the scenes they've actually appeared in — all pulled from the
/// live Character/scene data that generation itself uses, so nothing
/// shown here is decorative.
class CharacterLabScreen extends ConsumerStatefulWidget {
  final String? characterId;
  const CharacterLabScreen({super.key, this.characterId});

  @override
  ConsumerState<CharacterLabScreen> createState() => _CharacterLabScreenState();
}

class _CharacterLabScreenState extends ConsumerState<CharacterLabScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.characterId;
  }

  @override
  Widget build(BuildContext context) {
    final roster = ref.watch(characterListProvider);

    if (roster.isEmpty) {
      return Scaffold(
        backgroundColor: DripTheme.voidBlack,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('CHARACTERS', style: TextStyle(fontSize: 10, letterSpacing: 2.8, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  const Text('Every story needs someone worth remembering.', textAlign: TextAlign.center, style: TextStyle(fontSize: 19, height: 1.4, color: DripTheme.warmWhite)),
                  const SizedBox(height: 24),
                  CinematicButton(
                    label: 'CREATE CHARACTER',
                    icon: Icons.person_add_alt_1_outlined,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterCreationScreen())),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final selected = roster.firstWhere(
      (c) => c.id == _selectedId,
      orElse: () => roster.first,
    );

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back, color: DripTheme.chrome, size: 20)),
                    const Expanded(child: Text('CHARACTER LAB', style: TextStyle(fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w700, color: DripTheme.cosmicTeal))),
                  ],
                ),
              ),
            ),
            // ROSTER
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  scrollDirection: Axis.horizontal,
                  itemCount: roster.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (c, i) {
                    if (i == roster.length) {
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterCreationScreen())),
                        child: Container(
                          width: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(.12), style: BorderStyle.solid),
                          ),
                          child: const Icon(Icons.add, color: DripTheme.chrome),
                        ),
                      );
                    }
                    final ch = roster[i];
                    final isSel = ch.id == selected.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedId = ch.id),
                      child: Container(
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: DripTheme.surface,
                          border: Border.all(color: isSel ? DripTheme.cosmicTeal : Colors.white.withOpacity(.07), width: isSel ? 1.6 : 1),
                          boxShadow: isSel ? [BoxShadow(color: DripTheme.cosmicTeal.withOpacity(.22), blurRadius: 14)] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: isSel ? DripTheme.aquaGlow : DripTheme.chrome, size: 22),
                            const SizedBox(height: 6),
                            Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: isSel ? DripTheme.warmWhite : DripTheme.muted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
              sliver: SliverToBoxAdapter(child: _CharacterProfile(character: selected)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterProfile extends ConsumerWidget {
  final Character character;
  const _CharacterProfile({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider).where((s) => s.character.id == character.id).toList();

    // Profile-completeness signals derived from real data — not a claimed
    // ML measurement of face/hair match, just how filled-in this actor's
    // profile is, which is what actually affects generation quality.
    final identityScore = character.faceReferenceUrls.isNotEmpty ? 1.0 : 0.35;
    final wardrobeScore = (character.closet.length / 4).clamp(0.0, 1.0);
    final voiceScore = 0.0; // Voice DNA not recorded yet for this character.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: DripTheme.surfaceRaised,
                image: character.faceReferenceUrls.isNotEmpty
                    ? DecorationImage(
                        // Photos come from the device picker as local file
                        // paths, not uploaded URLs yet — render whichever
                        // this actually is instead of assuming a network
                        // image and failing silently.
                        image: character.faceReferenceUrls.first.startsWith('http')
                            ? NetworkImage(character.faceReferenceUrls.first) as ImageProvider
                            : FileImage(File(character.faceReferenceUrls.first)),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
                border: Border.all(color: Colors.white.withOpacity(.08)),
              ),
              child: character.faceReferenceUrls.isEmpty ? const Icon(Icons.person, color: DripTheme.muted, size: 34) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(character.name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('LEAD CHARACTER', style: TextStyle(fontSize: 9.5, letterSpacing: 2.4, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(character.continuityLock ? Icons.lock_outline : Icons.lock_open_outlined, size: 14, color: character.continuityLock ? DripTheme.aquaGlow : DripTheme.muted),
                      const SizedBox(width: 6),
                      Text(character.continuityLock ? 'CONTINUITY LOCK · ON' : 'CONTINUITY LOCK · OFF', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: character.continuityLock ? DripTheme.aquaGlow : DripTheme.muted)),
                      const Spacer(),
                      Switch(
                        value: character.continuityLock,
                        activeColor: DripTheme.cosmicTeal,
                        onChanged: (v) {
                          final updated = character.copyWith(continuityLock: v);
                          ref.read(characterListProvider.notifier).updateCharacter(updated);
                          if (ref.read(activeCharacterProvider)?.id == character.id) {
                            ref.read(activeCharacterProvider.notifier).state = updated;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // VISUAL DNA
        SectionHeader(eyebrow: 'VISUAL DNA', title: 'Profile strength'),
        CinematicCard(
          child: Column(
            children: [
              _ScoreRow(label: 'IDENTITY', value: identityScore, hint: character.faceReferenceUrls.isEmpty ? 'Add a face reference to lock identity' : '${character.faceReferenceUrls.length} reference(s) locked'),
              const SizedBox(height: 14),
              _ScoreRow(label: 'WARDROBE', value: wardrobeScore, hint: character.closet.isEmpty ? 'No looks saved yet' : '${character.closet.length} look(s) in closet'),
              const SizedBox(height: 14),
              _ScoreRow(label: 'VOICE', value: voiceScore, hint: 'Not recorded yet · Voice DNA'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (character.defaultStylePrompt.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CinematicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IDENTITY NOTES', style: TextStyle(fontSize: 9.5, letterSpacing: 2.2, color: DripTheme.muted)),
                  const SizedBox(height: 8),
                  Text(character.defaultStylePrompt, style: const TextStyle(height: 1.5, color: DripTheme.warmWhite)),
                ],
              ),
            ),
          ),

        const SizedBox(height: 26),

        // WARDROBE DEPARTMENT
        SectionHeader(
          eyebrow: 'WARDROBE DEPARTMENT',
          title: '${character.name}\'s closet',
          action: 'ADD OUTFIT',
          onAction: () => _openOutfitCreator(context, ref, character),
        ),
        if (character.closet.isEmpty)
          CinematicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No looks saved yet.', style: TextStyle(color: DripTheme.muted)),
                const SizedBox(height: 10),
                CinematicButton(label: 'ADD FIRST OUTFIT', icon: Icons.checkroom_outlined, primary: false, onPressed: () => _openOutfitCreator(context, ref, character)),
              ],
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: character.closet.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (c, i) {
                final o = character.closet[i];
                final isWorn = o.id == character.activeOutfitId;
                return SizedBox(
                  width: 130,
                  child: Stack(
                    children: [
                      CinematicMediaCard(title: o.name, meta: isWorn ? 'CURRENTLY WORN' : 'AVAILABLE', imageUrl: o.outfitImageUrl, width: 130, onTap: () => _wearOutfit(ref, character, o)),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 26),

        // SCENES
        SectionHeader(eyebrow: 'SCENES', title: '${scenes.length.toString().padLeft(2, '0')} appearances'),
        if (scenes.isEmpty)
          CinematicCard(child: const Text('This character hasn\'t appeared in a scene yet.', style: TextStyle(color: DripTheme.muted)))
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: scenes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (c, i) {
                final s = scenes[i];
                return CinematicMediaCard(title: 'SCENE ${(i + 1).toString().padLeft(2, '0')}', meta: s.cameraMotion ?? 'STATIC', imageUrl: s.generatedLastFrameUrl ?? s.inputLastFrameUrl, width: 190);
              },
            ),
          ),

        const SizedBox(height: 26),

        // RELATIONSHIPS — placeholder, this is its own future room.
        const SectionHeader(eyebrow: 'RELATIONSHIPS', title: 'Who they know'),
        CinematicCard(
          child: const Text(
            'The relationship graph is next on the roadmap — this is where connections between characters will live.',
            style: TextStyle(color: DripTheme.muted, height: 1.5),
          ),
        ),
      ],
    );
  }

  void _wearOutfit(WidgetRef ref, Character character, Outfit outfit) {
    final updated = character.copyWith(activeOutfitId: outfit.id);
    ref.read(characterListProvider.notifier).updateCharacter(updated);
    if (ref.read(activeCharacterProvider)?.id == character.id) {
      ref.read(activeCharacterProvider.notifier).state = updated;
    }
  }

  Future<void> _openOutfitCreator(BuildContext context, WidgetRef ref, Character character) async {
    // Reuses the existing Wardrobe Department flow (image reference, tags,
    // real Drip cost) instead of a second lightweight form — one outfit
    // creation path, one place it lands: this character's real closet.
    final result = await Navigator.push<dna.Outfit>(
      context,
      MaterialPageRoute(builder: (_) => CustomOutfitCreator(characterName: character.name)),
    );
    if (result == null) return;

    final outfit = Outfit(
      id: result.id,
      name: result.name,
      description: result.description,
      outfitImageUrl: result.referenceImageUrl,
    );
    final updated = character.copyWith(closet: [...character.closet, outfit]);
    ref.read(characterListProvider.notifier).updateCharacter(updated);
    if (ref.read(activeCharacterProvider)?.id == character.id) {
      ref.read(activeCharacterProvider.notifier).state = updated;
    }
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;
  final String hint;
  const _ScoreRow({required this.label, required this.value, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 2, color: DripTheme.muted, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DripTheme.aquaGlow)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(.06),
            valueColor: const AlwaysStoppedAnimation(DripTheme.cosmicTeal),
          ),
        ),
        const SizedBox(height: 5),
        Text(hint, style: const TextStyle(fontSize: 10.5, color: DripTheme.muted)),
      ],
    );
  }
}
