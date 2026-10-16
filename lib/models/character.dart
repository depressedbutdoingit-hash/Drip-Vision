class Character {
  final String id;
  final String name;
  final Vector dna;
  final List<String> wardrobeDNA;
  final double healthScore;

  Character({required this.id, required this.name, required this.dna, required this.wardrobeDNA, this.healthScore = 100});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      dna: Vector.fromJson(json['dna']),
      wardrobeDNA: List<String>.from(json['wardrobe']),
    );
  }
}

class Vector {
  final double face;
  final double wardrobe;
  final double location;
  final double voice;

  Vector({required this.face, required this.wardrobe, required this.location, required this.voice});

  Vector operator -(Vector other) => Vector(
        face: face - other.face,
        wardrobe: wardrobe - other.wardrobe,
        location: location - other.location,
        voice: voice - other.voice,
      );

  double get magnitude => (face.abs() + wardrobe.abs() + location.abs() + voice.abs()) / 4;

  factory Vector.fromJson(Map<String, dynamic> json) {
    return Vector(
      face: json['face'] as double,
      wardrobe: json['wardrobe'] as double,
      location: json['location'] as double,
      voice: json['voice'] as double,
    );
  }
}