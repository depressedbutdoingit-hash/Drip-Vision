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

/// DIRECTOR MODE — shape the shot; generation services consume the brief.
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
              Row(
                children: [
                  Expanded(
                    child: CinematicButton(
                      label: 'CONTINUITY',
                      icon: Icons.monitor_heart_outlined,
                      primary: false,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ContinuityHealthScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CinematicButton(
                      label: 'BIBLE',
                      icon: Icons.menu_book_outlined,
                      primary: false,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DirectorsBibleScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CinematicButton(
                label: 'STORY → FILM PIPELINE',
                icon: Icons.auto_stories_outlined,
                primary: false,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StoryPipelineScreen()),
                ),
              ),
              const SizedBox(height: 28),

              const Text('CAMERA', style: DripTheme.technical),
              const SizedBox(height: 12),
              CinematicCard(
                child: Column(
                  children: [
                    DirectorControlRow(
                      label: 'SHOT',
                      value: settings.shot,
                      options: DirectorSettings.shots,
                      onSelect: (v) =>
                          notifier.state = settings.copyWith(shot: v),
                    ),
                    DirectorControlRow(
                      label: 'CAMERA',
                      value: settings.camera,
                      options: DirectorSettings.cameras,
                      onSelect: (v) => notifier.state =
                          ref.read(directorSettingsProvider).copyWith(camera: v),
                    ),
                    DirectorControlRow(
                      label: 'LENS',
                      value: settings.lens,
                      options: DirectorSettings.lenses,
                      onSelect: (v) => notifier.state =
                          ref.read(directorSettingsProvider).copyWith(lens: v),
                    ),
                    DirectorControlRow(
                      label: 'MOVEMENT',
                      value: settings.movement,
                      options: DirectorSettings.movements,
                      onSelect: (v) => notifier.state = ref
                          .read(directorSettingsProvider)
                          .copyWith(movement: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('LIGHT & WORLD', style: DripTheme.technical),
              const SizedBox(height: 12),
              CinematicCard(
                child: Column(
                  children: [
                    DirectorControlRow(
                      label: 'LIGHTING',
                      value: settings.lighting,
                      options: DirectorSettings.lightings,
                      onSelect: (v) => notifier.state = ref
                          .read(directorSettingsProvider)
                          .copyWith(lighting: v),
                    ),
                    DirectorControlRow(
                      label: 'TIME',
                      value: settings.time,
                      options: DirectorSettings.times,
                      onSelect: (v) => notifier.state =
                          ref.read(directorSettingsProvider).copyWith(time: v),
                    ),
                    DirectorControlRow(
                      label: 'WEATHER',
                      value: settings.weather,
                      options: DirectorSettings.weathers,
                      onSelect: (v) => notifier.state = ref
                          .read(directorSettingsProvider)
                          .copyWith(weather: v),
                    ),
                    DirectorControlRow(
                      label: 'COLOR',
                      value: settings.color,
                      options: DirectorSettings.colors,
                      onSelect: (v) => notifier.state =
                          ref.read(directorSettingsProvider).copyWith(color: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('PERFORMANCE', style: DripTheme.technical),
              const SizedBox(height: 12),
              CinematicCard(
                child: Column(
                  children: [
                    DirectorControlRow(
                      label: 'MOOD',
                      value: settings.mood,
                      options: DirectorSettings.moods,
                      onSelect: (v) => notifier.state =
                          ref.read(directorSettingsProvider).copyWith(mood: v),
                    ),
                    DirectorControlRow(
                      label: 'PERFORMANCE',
                      value: settings.performance,
                      options: DirectorSettings.performances,
                      onSelect: (v) => notifier.state = ref
                          .read(directorSettingsProvider)
                          .copyWith(performance: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DIRECTOR'S BRIEF", style: DripTheme.technical),
                    const SizedBox(height: 10),
                    Text(
                      settings.toSummary(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Character identity and continuity stay locked — this only shapes camera and light.',
                      style: DripTheme.meta,
                    ),
                    const SizedBox(height: 16),
                    CinematicButton(
                      label: 'GENERATE SHOT',
                      icon: Icons.camera_alt_outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DripVisionStudioScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

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
