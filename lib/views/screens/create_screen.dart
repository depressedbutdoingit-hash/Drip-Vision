import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character.dart' as live;
import '../../models/character_dna.dart' as dna;
import '../widgets/cinematic_card.dart';
import '../widgets/cinematic_button.dart';
import 'story_planner_screen.dart';
import 'character_creation_screen.dart';
import 'character_lab_screen.dart';
import 'custom_outfit_creator.dart';
import 'music_studio_screen.dart';
import 'style_dna_screen.dart';
import 'edit_bay_screen.dart';

class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CREATE', style: DripTheme.overline),
              const SizedBox(height: 10),
              const Text('What are we making?', style: DripTheme.display),
              const SizedBox(height: 10),
              const Text(
                'Choose a department. DripVision handles the technical language.',
                style: DripTheme.body,
              ),
              const SizedBox(height: 28),

              // Primary
              _Dept(
                title: 'FILM',
                subtitle: 'Story to cut — full production',
                icon: Icons.movie_creation_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoryPlannerScreen()),
                ),
              ),
              _Dept(
                title: 'SCENE',
                subtitle: 'Direct a single cinematic moment',
                icon: Icons.camera_alt_outlined,
                onTap: () => ref.read(navIndexProvider.notifier).state = 3,
              ),
              const SizedBox(height: 8),
              const Text('CAST & WORLD', style: DripTheme.technical),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Dept(
                      title: 'CHARACTER',
                      subtitle: 'Actor + continuity',
                      icon: Icons.person_outline,
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ref.read(characterListProvider).isEmpty
                              ? const CharacterCreationScreen()
                              : const CharacterLabScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dept(
                      title: 'OUTFIT',
                      subtitle: 'Wardrobe',
                      icon: Icons.checkroom_outlined,
                      compact: true,
                      onTap: () => _createOutfit(context, ref),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _Dept(
                      title: 'LOCATION',
                      subtitle: 'Coming soon',
                      icon: Icons.location_on_outlined,
                      compact: true,
                      onTap: null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dept(
                      title: 'STYLE',
                      subtitle: 'Style DNA',
                      icon: Icons.auto_awesome_outlined,
                      compact: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StyleDnaScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('AUDIO', style: DripTheme.technical),
              const SizedBox(height: 12),
              _Dept(
                title: 'MUSIC',
                subtitle: 'Score the scene',
                icon: Icons.music_note_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MusicStudioScreen()),
                ),
              ),
              const SizedBox(height: 20),
              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FINISHING', style: DripTheme.technical),
                    const SizedBox(height: 8),
                    const Text(
                      'Edit Bay',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cut, grade, and export your production.',
                      style: DripTheme.body,
                    ),
                    const SizedBox(height: 16),
                    CinematicButton(
                      label: 'OPEN EDIT BAY',
                      icon: Icons.movie_filter_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditBayScreen()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CinematicButton(
                      label: 'OPEN DIRECTOR',
                      icon: Icons.tune_outlined,
                      primary: false,
                      onPressed: () =>
                          ref.read(navIndexProvider.notifier).state = 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createOutfit(BuildContext context, WidgetRef ref) async {
    final character = ref.read(activeCharacterProvider);
    if (character == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a character first — outfits are designed for someone.'),
        ),
      );
      return;
    }
    final result = await Navigator.push<dna.Outfit>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomOutfitCreator(characterName: character.name),
      ),
    );
    if (result == null) return;

    final outfit = live.Outfit(
      id: result.id,
      name: result.name,
      description: result.description,
      outfitImageUrl: result.referenceImageUrl,
    );
    final updated = character.copyWith(closet: [...character.closet, outfit]);
    ref.read(characterListProvider.notifier).updateCharacter(updated);
    ref.read(activeCharacterProvider.notifier).state = updated;
  }
}

class _Dept extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;

  const _Dept({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CinematicCard(
        onTap: onTap,
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            Container(
              width: compact ? 36 : 44,
              height: compact ? 36 : 44,
              decoration: BoxDecoration(
                color: enabled
                    ? DripTheme.cosmicTeal.withOpacity(0.06)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: compact ? 18 : 20,
                color: enabled ? DripTheme.cosmicTeal : DripTheme.muted,
              ),
            ),
            SizedBox(width: compact ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      letterSpacing: compact ? 1.0 : 1.4,
                      fontWeight: FontWeight.w600,
                      color: enabled ? DripTheme.warmWhite : DripTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enabled ? subtitle : 'Coming soon',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DripTheme.meta.copyWith(fontSize: compact ? 11 : 12),
                  ),
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right, size: 16, color: DripTheme.muted),
          ],
        ),
      ),
    );
  }
}
