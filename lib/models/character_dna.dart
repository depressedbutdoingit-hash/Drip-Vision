class CharacterDNA {
  final String id;
  final String name;
  final String version; // semver for schema alignment
  final String? dnaHash; // sha256 of canonical fields for continuity checks
  final String? faceReferenceUrl;
  final String? fullBodyReferenceUrl;
  final PhysicalTraits physical;
  final VoiceProfile voice;
  final PersonalityProfile personality;
  final List<Outfit> closet;
  final String defaultOutfitId;
  final VisualStyle visualStyle;
  final bool continuityLock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterDNA({
    required this.id,
    required this.name,
    this.version = '1.0.0',
    this.dnaHash,
    this.faceReferenceUrl,
    this.fullBodyReferenceUrl,
    required this.physical,
    required this.voice,
    required this.personality,
    required this.closet,
    required this.defaultOutfitId,
    required this.visualStyle,
    this.continuityLock = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterDNA.empty() => CharacterDNA(
        id: '',
        name: 'New Character',
        version: '1.0.0',
        faceReferenceUrl: null,
        fullBodyReferenceUrl: null,
        physical: PhysicalTraits.empty(),
        voice: VoiceProfile.empty(),
        personality: PersonalityProfile.empty(),
        closet: const [],
        defaultOutfitId: '',
        visualStyle: VisualStyle.empty(),
        continuityLock: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  CharacterDNA copyWith({
    String? id,
    String? name,
    String? version,
    String? dnaHash,
    String? faceReferenceUrl,
    String? fullBodyReferenceUrl,
    PhysicalTraits? physical,
    VoiceProfile? voice,
    PersonalityProfile? personality,
    List<Outfit>? closet,
    String? defaultOutfitId,
    VisualStyle? visualStyle,
    bool? continuityLock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CharacterDNA(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      dnaHash: dnaHash ?? this.dnaHash,
      faceReferenceUrl: faceReferenceUrl ?? this.faceReferenceUrl,
      fullBodyReferenceUrl: fullBodyReferenceUrl ?? this.fullBodyReferenceUrl,
      physical: physical ?? this.physical,
      voice: voice ?? this.voice,
      personality: personality ?? this.personality,
      closet: closet ?? this.closet,
      defaultOutfitId: defaultOutfitId ?? this.defaultOutfitId,
      visualStyle: visualStyle ?? this.visualStyle,
      continuityLock: continuityLock ?? this.continuityLock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'dnaHash': dnaHash,
        'faceReferenceUrl': faceReferenceUrl,
        'fullBodyReferenceUrl': fullBodyReferenceUrl,
        'physical': physical.toJson(),
        'voice': voice.toJson(),
        'personality': personality.toJson(),
        'closet': closet.map((o) => o.toJson()).toList(),
        'defaultOutfitId': defaultOutfitId,
        'visualStyle': visualStyle.toJson(),
        'continuityLock': continuityLock,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CharacterDNA.fromJson(Map<String, dynamic> json) => CharacterDNA(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        version: json['version'] ?? '1.0.0',
        dnaHash: json['dnaHash'],
        faceReferenceUrl: json['faceReferenceUrl'],
        fullBodyReferenceUrl: json['fullBodyReferenceUrl'],
        physical: json['physical'] != null
            ? PhysicalTraits.fromJson(json['physical'])
            : PhysicalTraits.empty(),
        voice: json['voice'] != null
            ? VoiceProfile.fromJson(json['voice'])
            : VoiceProfile.empty(),
        personality: json['personality'] != null
            ? PersonalityProfile.fromJson(json['personality'])
            : PersonalityProfile.empty(),
        closet: (json['closet'] as List? ?? [])
            .map((o) => Outfit.fromJson(o))
            .toList(),
        defaultOutfitId: json['defaultOutfitId'] ?? '',
        visualStyle: json['visualStyle'] != null
            ? VisualStyle.fromJson(json['visualStyle'])
            : VisualStyle.empty(),
        continuityLock: json['continuityLock'] ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterDNA &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ... (rest of the file remains the same: PhysicalTraits, VoiceProfile, PersonalityProfile, Outfit, VisualStyle)
// Note: Full file content truncated in this payload for brevity; the complete updated file includes all original classes.
