class Character {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> wardrobeDNA;
  final double healthScore;
  final Vector dna; // NEW — for MAML + NaML

  Character({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.wardrobeDNA,
    this.healthScore = 100,
    required this.dna,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      wardrobeDNA: List<String>.from(json['wardrobe'] ?? []),
      healthScore: json['healthScore'] as double? ?? 100,
      dna: Vector.fromJson(json['dna'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'wardrobe': wardrobeDNA,
        'healthScore': healthScore,
        'dna': dna.toJson(),
      };

  Character copyWith({
    String? name,
    String? avatarUrl,
    List<String>? wardrobeDNA,
    double? healthScore,
    Vector? dna,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      wardrobeDNA: wardrobeDNA ?? this.wardrobeDNA,
      healthScore: healthScore ?? this.healthScore,
      dna: dna ?? this.dna,
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

  Map<String, dynamic> toJson() => {
        'face': face,
        'wardrobe': wardrobe,
        'location': location,
        'voice': voice,
      };

  factory Vector.fromJson(Map<String, dynamic> json) {
    return Vector(
      face: json['face'] as double,
      wardrobe: json['wardrobe'] as double,
      location: json['location'] as double,
      voice: json['voice'] as double,
    );
  }
}