import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DIRECTOR MODE — a single source of truth for the cinematography
/// choices a user makes before generating a shot. This is deliberately
/// plain data: no prompt-engineering jargon lives here, only the visual
/// vocabulary a filmmaker would recognize. `toDescriptor()` is what turns
/// it into language the generation services can use.
class DirectorSettings {
  final String shot;
  final String camera;
  final String lens;
  final String movement;
  final String lighting;
  final String time;
  final String weather;
  final String mood;
  final String performance;
  final String color;

  const DirectorSettings({
    this.shot = 'Wide',
    this.camera = 'Eye Level',
    this.lens = '50mm',
    this.movement = 'Static',
    this.lighting = 'Natural',
    this.time = 'Day',
    this.weather = 'Clear',
    this.mood = 'Tense',
    this.performance = 'Grounded',
    this.color = 'Neutral',
  });

  static const List<String> shots = [
    'Extreme Wide', 'Wide', 'Medium', 'Close', 'Extreme Close', 'Over Shoulder', 'POV',
  ];
  static const List<String> cameras = [
    'Eye Level', 'Low Angle', 'High Angle', 'Dutch Tilt', "Bird's Eye", 'Worm\'s Eye',
  ];
  static const List<String> lenses = ['24mm', '35mm', '50mm', '85mm', '135mm'];
  static const List<String> movements = [
    'Static', 'Push In', 'Pull Out', 'Dolly', 'Tracking', 'Orbit', 'Crane', 'Handheld',
  ];
  static const List<String> lightings = [
    'Natural', 'Golden Hour', 'Moonlight', 'Neon', 'Hard', 'Soft', 'Practical', 'Low Key',
  ];
  static const List<String> times = [
    'Dawn', 'Day', 'Golden Hour', 'Dusk', 'Night', 'Late Night',
  ];
  static const List<String> weathers = [
    'Clear', 'Overcast', 'Rain', 'Storm', 'Fog', 'Snow', 'Heat Haze',
  ];
  static const List<String> moods = [
    'Tense', 'Tender', 'Dreamlike', 'Menacing', 'Joyful', 'Melancholic', 'Euphoric',
  ];
  static const List<String> performances = [
    'Grounded', 'Restrained', 'Explosive', 'Vulnerable', 'Commanding', 'Playful',
  ];
  static const List<String> colors = [
    'Neutral', 'Muted Amber', 'Cyan Teal', 'Desaturated', 'High Contrast', 'Pastel', 'Monochrome',
  ];

  DirectorSettings copyWith({
    String? shot,
    String? camera,
    String? lens,
    String? movement,
    String? lighting,
    String? time,
    String? weather,
    String? mood,
    String? performance,
    String? color,
  }) {
    return DirectorSettings(
      shot: shot ?? this.shot,
      camera: camera ?? this.camera,
      lens: lens ?? this.lens,
      movement: movement ?? this.movement,
      lighting: lighting ?? this.lighting,
      time: time ?? this.time,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
      performance: performance ?? this.performance,
      color: color ?? this.color,
    );
  }

  /// A short human sentence for display in the UI — what the user reads.
  String toSummary() =>
      '$shot shot · $lens · $movement · $lighting · $time · $mood';

  /// The descriptor handed to the generation services. Kept as plain,
  /// concrete visual language so it slots cleanly in front of the raw
  /// prompt before the prompt-enhancer service runs.
  String toDescriptor() =>
      '$shot shot, $camera angle, shot on a $lens lens, camera movement: '
      '$movement. Lighting: $lighting, $time, $weather weather. '
      'Performance: $performance, mood: $mood. Color grade: $color.';

  /// Free-text camera motion label stored on the SceneNode for continuity
  /// (kept separate since dripEngine already has its own cameraMotion field).
  String get cameraMotionLabel => movement;
}

final directorSettingsProvider =
    StateProvider<DirectorSettings>((ref) => const DirectorSettings());
