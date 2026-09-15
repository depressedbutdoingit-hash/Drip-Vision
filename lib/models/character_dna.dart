class CharacterDNA {
  final String id;
  final String name;
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

class PhysicalTraits {
  final String gender;
  final String ageRange;
  final String ethnicity;
  final String hairColor;
  final String hairStyle;
  final String bodyType;
  final String height;
  final String distinguishingFeatures;

  const PhysicalTraits({
    required this.gender,
    required this.ageRange,
    required this.ethnicity,
    required this.hairColor,
    required this.hairStyle,
    required this.bodyType,
    required this.height,
    required this.distinguishingFeatures,
  });

  factory PhysicalTraits.empty() => const PhysicalTraits(
        gender: '',
        ageRange: '',
        ethnicity: '',
        hairColor: '',
        hairStyle: '',
        bodyType: '',
        height: '',
        distinguishingFeatures: '',
      );

  PhysicalTraits copyWith({
    String? gender,
    String? ageRange,
    String? ethnicity,
    String? hairColor,
    String? hairStyle,
    String? bodyType,
    String? height,
    String? distinguishingFeatures,
  }) {
    return PhysicalTraits(
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      ethnicity: ethnicity ?? this.ethnicity,
      hairColor: hairColor ?? this.hairColor,
      hairStyle: hairStyle ?? this.hairStyle,
      bodyType: bodyType ?? this.bodyType,
      height: height ?? this.height,
      distinguishingFeatures: distinguishingFeatures ?? this.distinguishingFeatures,
    );
  }

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'ageRange': ageRange,
        'ethnicity': ethnicity,
        'hairColor': hairColor,
        'hairStyle': hairStyle,
        'bodyType': bodyType,
        'height': height,
        'distinguishingFeatures': distinguishingFeatures,
      };

  factory PhysicalTraits.fromJson(Map<String, dynamic> json) => PhysicalTraits(
        gender: json['gender'] ?? '',
        ageRange: json['ageRange'] ?? '',
        ethnicity: json['ethnicity'] ?? '',
        hairColor: json['hairColor'] ?? '',
        hairStyle: json['hairStyle'] ?? '',
        bodyType: json['bodyType'] ?? '',
        height: json['height'] ?? '',
        distinguishingFeatures: json['distinguishingFeatures'] ?? '',
      );
}

class VoiceProfile {
  final String? elevenLabsVoiceId;
  final String description;
  final String language;
  final String accent;
  final double stability;
  final double similarityBoost;

  const VoiceProfile({
    this.elevenLabsVoiceId,
    required this.description,
    required this.language,
    required this.accent,
    this.stability = 0.0,
    this.similarityBoost = 0.75,
  });

  factory VoiceProfile.empty() => const VoiceProfile(
        elevenLabsVoiceId: null,
        description: '',
        language: 'en',
        accent: '',
        stability: 0.0,
        similarityBoost: 0.75,
      );

  VoiceProfile copyWith({
    String? elevenLabsVoiceId,
    String? description,
    String? language,
    String? accent,
    double? stability,
    double? similarityBoost,
  }) {
    return VoiceProfile(
      elevenLabsVoiceId: elevenLabsVoiceId ?? this.elevenLabsVoiceId,
      description: description ?? this.description,
      language: language ?? this.language,
      accent: accent ?? this.accent,
      stability: stability ?? this.stability,
      similarityBoost: similarityBoost ?? this.similarityBoost,
    );
  }

  Map<String, dynamic> toJson() => {
        'elevenLabsVoiceId': elevenLabsVoiceId,
        'description': description,
        'language': language,
        'accent': accent,
        'stability': stability,
        'similarityBoost': similarityBoost,
      };

  factory VoiceProfile.fromJson(Map<String, dynamic> json) => VoiceProfile(
        elevenLabsVoiceId: json['elevenLabsVoiceId'],
        description: json['description'] ?? '',
        language: json['language'] ?? 'en',
        accent: json['accent'] ?? '',
        stability: (json['stability'] ?? 0.0).toDouble(),
        similarityBoost: (json['similarityBoost'] ?? 0.75).toDouble(),
      );
}

class PersonalityProfile {
  final String archetype;
  final String traits;
  final String mannerisms;
  final String speechPattern;

  const PersonalityProfile({
    required this.archetype,
    required this.traits,
    required this.mannerisms,
    required this.speechPattern,
  });

  factory PersonalityProfile.empty() => const PersonalityProfile(
        archetype: '',
        traits: '',
        mannerisms: '',
        speechPattern: '',
      );

  PersonalityProfile copyWith({
    String? archetype,
    String? traits,
    String? mannerisms,
    String? speechPattern,
  }) {
    return PersonalityProfile(
      archetype: archetype ?? this.archetype,
      traits: traits ?? this.traits,
      mannerisms: mannerisms ?? this.mannerisms,
      speechPattern: speechPattern ?? this.speechPattern,
    );
  }

  Map<String, dynamic> toJson() => {
        'archetype': archetype,
        'traits': traits,
        'mannerisms': mannerisms,
        'speechPattern': speechPattern,
      };

  factory PersonalityProfile.fromJson(Map<String, dynamic> json) =>
      PersonalityProfile(
        archetype: json['archetype'] ?? '',
        traits: json['traits'] ?? '',
        mannerisms: json['mannerisms'] ?? '',
        speechPattern: json['speechPattern'] ?? '',
      );
}

class Outfit {
  final String id;
  final String name;
  final String description;
  final String? referenceImageUrl;
  final List<String> tags;
  final bool isDefault;

  const Outfit({
    required this.id,
    required this.name,
    required this.description,
    this.referenceImageUrl,
    this.tags = const [],
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'referenceImageUrl': referenceImageUrl,
        'tags': tags,
        'isDefault': isDefault,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        referenceImageUrl: json['referenceImageUrl'],
        tags: List<String>.from(json['tags'] ?? []),
        isDefault: json['isDefault'] ?? false,
      );
}

class VisualStyle {
  final String artDirection;
  final String colorPalette;
  final String lightingPreference;

  const VisualStyle({
    required this.artDirection,
    required this.colorPalette,
    required this.lightingPreference,
  });

  factory VisualStyle.empty() => const VisualStyle(
        artDirection: 'photorealistic',
        colorPalette: '',
        lightingPreference: '',
      );

  VisualStyle copyWith({
    String? artDirection,
    String? colorPalette,
    String? lightingPreference,
  }) {
    return VisualStyle(
      artDirection: artDirection ?? this.artDirection,
      colorPalette: colorPalette ?? this.colorPalette,
      lightingPreference: lightingPreference ?? this.lightingPreference,
    );
  }

  Map<String, dynamic> toJson() => {
        'artDirection': artDirection,
        'colorPalette': colorPalette,
        'lightingPreference': lightingPreference,
      };

  factory VisualStyle.fromJson(Map<String, dynamic> json) => VisualStyle(
        artDirection: json['artDirection'] ?? 'photorealistic',
        colorPalette: json['colorPalette'] ?? '',
        lightingPreference: json['lightingPreference'] ?? '',
      );
}
