import 'character.dart';

class Universe {
  final double healthScore;
  final List<Character> characters;

  Universe({required this.healthScore, required this.characters});

  factory Universe.fromJson(Map<String, dynamic> json) => Universe(
        healthScore: (json['healthScore'] as num?)?.toDouble() ?? 100,
        characters: (json['characters'] as List? ?? []).map((c) => Character.fromJson(c)).toList(),
      );
}