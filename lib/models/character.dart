class Character {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> wardrobeDNA;
  final double healthScore;

  Character({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.wardrobeDNA,
    this.healthScore = 100,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      wardrobeDNA: List<String>.from(json['wardrobe'] ?? []),
      healthScore: json['healthScore'] as double? ?? 100,
    );
  }
}