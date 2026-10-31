import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/app_providers.dart';
import '../widgets/studio_empty.dart';
import '../../models/character.dart';
import '../../models/character_dna.dart' as dna;
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_media_card.dart';
import '../widgets/section_header.dart';
import 'character_creation_screen.dart';
import 'custom_outfit_creator.dart';

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
                            border: Border.all(color: Colors.white.withOpacity(.12)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(character.name.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(character.role, style: const TextStyle(color: DripTheme.muted)),
        const SizedBox(height: 16),
        Text('Hair: ${character.hairColor}', style: const TextStyle(color: DripTheme.warmWhite)),
        Text('Eyes: ${character.eyeColor}', style: const TextStyle(color: DripTheme.warmWhite)),
        Text('Voice: ${character.voiceDescription}', style: const TextStyle(color: DripTheme.warmWhite)),
      ],
    );
  }
}
