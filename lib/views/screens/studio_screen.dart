import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../core/director_settings.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/director_chip.dart';
import 'generator_screen.dart';

/// DIRECTOR MODE
/// The user shapes a shot visually — shot size, camera angle, lens,
/// movement, lighting, time, weather, mood, performance and color —
/// and DripVision translates it into the language the generation
/// services actually consume. No prompt-engineering required.
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
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STUDIO', style: TextStyle(fontSize: 11, letterSpacing: 3, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              const Text('DIRECTOR MODE', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              const Text('Shape the shot. DripVision translates the intent.', style: TextStyle(color: DripTheme.muted)),
              const SizedBox(height: 24),

              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DirectorControlRow(label: 'SHOT', value: settings.shot, options: DirectorSettings.shots, onSelect: (v) => notifier.state = settings.copyWith(shot: v)),
                    DirectorControlRow(label: 'CAMERA', value: settings.camera, options: DirectorSettings.cameras, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(camera: v)),
                    DirectorControlRow(label: 'LENS', value: settings.lens, options: DirectorSettings.lenses, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(lens: v)),
                    DirectorControlRow(label: 'MOVEMENT', value: settings.movement, options: DirectorSettings.movements, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(movement: v)),
                    DirectorControlRow(label: 'LIGHTING', value: settings.lighting, options: DirectorSettings.lightings, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(lighting: v)),
                    DirectorControlRow(label: 'TIME', value: settings.time, options: DirectorSettings.times, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(time: v)),
                    DirectorControlRow(label: 'WEATHER', value: settings.weather, options: DirectorSettings.weathers, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(weather: v)),
                    DirectorControlRow(label: 'MOOD', value: settings.mood, options: DirectorSettings.moods, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(mood: v)),
                    DirectorControlRow(label: 'PERFORMANCE', value: settings.performance, options: DirectorSettings.performances, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(performance: v)),
                    DirectorControlRow(label: 'COLOR', value: settings.color, options: DirectorSettings.colors, onSelect: (v) => notifier.state = ref.read(directorSettingsProvider).copyWith(color: v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DIRECTOR'S BRIEF", style: TextStyle(fontSize: 10, letterSpacing: 2.3, color: DripTheme.cosmicTeal)),
                    const SizedBox(height: 10),
                    Text(settings.toSummary(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      'Character identity, location and continuity remain untouched — Director Mode only shapes the camera and the light.',
                      style: TextStyle(color: DripTheme.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: CinematicButton(
                      label: 'GENERATE SHOT',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DripVisionStudioScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CinematicButton(
                      label: 'RESET',
                      icon: Icons.refresh_rounded,
                      primary: false,
                      onPressed: () => notifier.state = const DirectorSettings(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Text('CUTTING ROOM', style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: DripTheme.cosmicTeal)),
              const SizedBox(height: 10),
              Text('${scenes.length.toString().padLeft(2, '0')} SHOTS IN CURRENT CUT', style: const TextStyle(color: DripTheme.muted)),
              const SizedBox(height: 10),
              ...scenes.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CinematicCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Text('SHOT ${(e.key + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: DripTheme.nebulaCyan)),
                            const SizedBox(width: 15),
                            Expanded(child: Text(e.value.prompt, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                            const Icon(Icons.chevron_right, color: Colors.white24),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
