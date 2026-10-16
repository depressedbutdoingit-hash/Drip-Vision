import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/director_settings.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/director_chip.dart';
import 'generator_screen.dart';
import 'edit_bay_screen.dart';
import 'timeline_screen.dart';
import 'continuity_health_screen.dart';
import 'directors_bible_screen.dart';
import 'story_pipeline_screen.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);
    final settings = ref.watch(directorSettingsProvider);
    final notifier = ref.read(directorSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STUDIO', style: DripTheme.overline),
              const SizedBox(height: 10),
              const Text('Director Mode', style: DripTheme.display),
              const SizedBox(height: 10),
              const Text(
                'Shape the shot. DripVision translates the intent.',
                style: DripTheme.body,
              ),
              const SizedBox(height: 22),

              // === NEW DRIP BUTTON (big teal one) ===
              Row(
                children: [
                  Expanded(
                    child: CinematicButton(
                      label: 'EDIT BAY',
                      icon: Icons.movie_filter_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditBayScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CinematicButton(
                      label: "CUT",
                      icon: Icons.view_timeline_outlined,
                      primary: false,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimelineScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ... (the rest is the same cinematic code you had)

              Row(
                children: [
                  const Expanded(
                    child: Text('CUTTING ROOM', style: DripTheme.technical),
                  ),
                  Text(
                    '${scenes.length.toString().padLeft(2, '0')} SHOTS',
                    style: DripTheme.meta,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (scenes.isEmpty)
                const Text(
                  'Generate a shot and it will land here.',
                  style: DripTheme.meta,
                )
              else
                ...scenes.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CinematicCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TimelineScreen(),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'SHOT ${(e.key + 1).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  color: DripTheme.cosmicTeal,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  e.value.prompt.isEmpty
                                      ? e.value.character.name
                                      : e.value.prompt,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: DripTheme.muted),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 12),
              CinematicButton(
                label: 'OPEN EDIT BAY',
                icon: Icons.movie_filter_outlined,
                primary: false,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditBayScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}