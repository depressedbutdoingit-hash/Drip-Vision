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
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      wardrobeDNA: List<String>.from(json['wardrobe']),
      healthScore: json['healthScore'] ?? 100,
    );
  }
}