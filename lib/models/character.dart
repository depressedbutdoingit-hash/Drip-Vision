import 'character_dna.dart' as dna;

class Outfit {
  final String id;
  final String name;
  final String description;
  final String? outfitImageUrl;

  Outfit({
    required this.id,
    required this.name,
    required this.description,
    this.outfitImageUrl,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        outfitImageUrl: json['outfitImageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'outfitImageUrl': outfitImageUrl,
      };
}

class Character {
  final String id;
  final String name;
  final List<String> faceReferenceUrls;
  final String activeOutfitId;
  final List<Outfit> closet;
  final String defaultStylePrompt;
  final bool continuityLock;

  Character({
    required this.id,
    required this.name,
    required this.faceReferenceUrls,
    required this.activeOutfitId,
    required this.closet,
    this.defaultStylePrompt = '',
    this.continuityLock = true,
  });

  /// The single, shared bridge from the richer CharacterDNA model (used by
  /// Character Creation and Story Planner) into the live Character this
  /// app actually generates, saves continuity for, and renders wardrobe
  /// from. Carries over the real face reference, closet and continuity
  /// lock instead of leaving them empty — used anywhere a CharacterDNA
  /// needs to become a real Character, so that conversion logic exists
  /// in exactly one place.
  factory Character.fromDNA(dna.CharacterDNA source) {
    final stylePrompt = [
      source.physical.gender,
      source.physical.ageRange,
      source.physical.bodyType,
      '${source.visualStyle.artDirection} style',
      if (source.physical.distinguishingFeatures.isNotEmpty) source.physical.distinguishingFeatures,
    ].where((s) => s.isNotEmpty).join(', ');

    return Character(
      id: source.id,
      name: source.name,
      faceReferenceUrls: source.faceReferenceUrl != null ? [source.faceReferenceUrl!] : const [],
      activeOutfitId: source.defaultOutfitId,
      closet: source.closet
          .map((o) => Outfit(
                id: o.id,
                name: o.name,
                description: o.description,
                outfitImageUrl: o.referenceImageUrl,
              ))
          .toList(),
      defaultStylePrompt: stylePrompt,
      continuityLock: source.continuityLock,
    );
  }

  /// Falls back to a plain default when there's no wardrobe yet, rather
  /// than crashing — a freshly created character with no outfit added
  /// is a normal, real state, not an error.
  Outfit get activeOutfit => closet.isEmpty
      ? Outfit(id: '', name: 'Default', description: 'their everyday clothing')
      : closet.firstWhere(
          (o) => o.id == activeOutfitId,
          orElse: () => closet.first,
        );

  Character copyWith({
    String? id,
    String? name,
    List<String>? faceReferenceUrls,
    String? activeOutfitId,
    List<Outfit>? closet,
    String? defaultStylePrompt,
    bool? continuityLock,
  }) => Character(
        id: id ?? this.id,
        name: name ?? this.name,
        faceReferenceUrls: faceReferenceUrls ?? this.faceReferenceUrls,
        activeOutfitId: activeOutfitId ?? this.activeOutfitId,
        closet: closet ?? this.closet,
        defaultStylePrompt: defaultStylePrompt ?? this.defaultStylePrompt,
        continuityLock: continuityLock ?? this.continuityLock,
      );

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'],
        name: json['name'],
        faceReferenceUrls: List<String>.from(json['faceReferenceUrls']),
        activeOutfitId: json['activeOutfitId'],
        defaultStylePrompt: json['defaultStylePrompt'] ?? '',
        closet: (json['closet'] as List).map((o) => Outfit.fromJson(o)).toList(),
        continuityLock: json['continuityLock'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'faceReferenceUrls': faceReferenceUrls,
        'activeOutfitId': activeOutfitId,
        'defaultStylePrompt': defaultStylePrompt,
        'closet': closet.map((o) => o.toJson()).toList(),
        'continuityLock': continuityLock,
      };
}
