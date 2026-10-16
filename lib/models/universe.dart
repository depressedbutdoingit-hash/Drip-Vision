class Universe {
  final double healthScore;
  final List<Character> characters;

  Universe({required this.healthScore, required this.characters});

  factory Universe.fromJson(Map<String, dynamic> json) {
    return Universe(
      healthScore: json['healthScore'] as double,
      characters: (json['characters'] as List).map((c) => Character.fromJson(c)).toList(),
    );
  }
}

class Character {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> wardrobeDNA;

  Character({required this.id, required this.name, required this.avatarUrl, required this.wardrobeDNA});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      wardrobeDNA: List<String>.from(json['wardrobe']),
    );
  }
}