import 'character_dna.dart'; // keeps Outfit + CharacterDNA as-is

/// The ONE app-level character model. Delete the old simple Character class.
class Character {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> faceReferenceUrls;
  final List<Outfit> closet;
  final String? activeOutfitId;
  final double healthScore;

  const Character({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.faceReferenceUrls = const [],
    this.closet = const [],
    this.activeOutfitId,
    this.healthScore = 100,
  });

  Outfit? get activeOutfit {
    for (final o in closet) {
      if (o.id == activeOutfitId) return o;
    }
    return closet.isEmpty ? null : closet.first;
  }

  List<String> get wardrobeDNA => closet.map((o) => o.name).toList();

  factory Character.fromDna(CharacterDNA d) => Character(
        id: d.id,
        name: d.name,
        avatarUrl: d.faceReferenceUrl ?? '',
        faceReferenceUrls:
            d.faceReferenceUrl == null ? const [] : [d.faceReferenceUrl!],
        closet: d.closet,
        activeOutfitId: d.defaultOutfitId,
      );

  Character copyWith({
    String? name,
    String? avatarUrl,
    List<String>? faceReferenceUrls,
    List<Outfit>? closet,
    String? activeOutfitId,
    double? healthScore,
  }) =>
      Character(
        id: id,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        faceReferenceUrls: faceReferenceUrls ?? this.faceReferenceUrls,
        closet: closet ?? this.closet,
        activeOutfitId: activeOutfitId ?? this.activeOutfitId,
        healthScore: healthScore ?? this.healthScore,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'faceReferenceUrls': faceReferenceUrls,
        'closet': closet.map((o) => o.toJson()).toList(),
        'activeOutfitId': activeOutfitId,
        'healthScore': healthScore,
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        faceReferenceUrls: List<String>.from(json['faceReferenceUrls'] ?? []),
        closet: (json['closet'] as List? ?? [])
            .map((o) => Outfit.fromJson(Map<String, dynamic>.from(o)))
            .toList(),
        activeOutfitId: json['activeOutfitId'] as String?,
        healthScore: (json['healthScore'] as num?)?.toDouble() ?? 100,
      );
}