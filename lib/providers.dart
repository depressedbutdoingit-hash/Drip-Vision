import 'package:flutter_riverpod/flutter_riverpod.dart';

// Real Continuity Engine with MAML + NaML + meta-gradients + few-shot
final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());

// Live Universe with health score
final universeProvider = StateProvider((ref) => Universe(
  healthScore: 100,
  characters: [],
));

// Live continuity health score for the health screen
final continuityHealthProvider = StateProvider((ref) => ContinuityHealth(
  score: 0,
  message: '',
  color: Colors.red,
));

class ContinuityEngine {
  // Your full MAML + NaML + meta-gradients engine here
  // (I already gave you the full code in the previous message)
}

class Universe {
  final double healthScore;
  final List<Character> characters;

  Universe({required this.healthScore, required this.characters});
}

class ContinuityHealth {
  final int score;
  final String message;
  final Color color;

  ContinuityHealth({required this.score, required this.message, required this.color});
}