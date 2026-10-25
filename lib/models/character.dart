import '../services/continuity_service.dart';
import 'character_dna.dart' show Outfit;

class Character {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;
  final int age;
  final String height;
  final String build;
  final String eyeColor;
  final String hairColor;
  final String voiceDescription;
  final List<String> wardrobeDNA;
  final CharacterDNA dna;
  final double healthScore;
  final bool locked;
  final List<String> faceReferenceUrls;
  final Outfit? activeOutfit;
  final String? activeOutfitId;
  final String defaultStylePrompt;
  final bool continuityLock;
  final List<Outfit> closet;

  Character({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.role = 'Supporting',
    this.age = 28,
    this.height = "5'8\"",
    this.build = 'Athletic',
    this.eyeColor = 'Hazel',
    this.hairColor = 'Dark Brown',
    this.voiceDescription = 'Confident',
    required this.wardrobeDNA,
    required this.dna,
    this.healthScore = 92,
    this.locked = true,
    this.faceReferenceUrls = const [],
    this.activeOutfit,
    this.activeOutfitId,
    this.defaultStylePrompt = '',
    this.continuityLock = true,
    this.closet = const [],
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String? ?? '',
        role: json['role'] as String? ?? 'Supporting',
        age: json['age'] as int? ?? 28,
        height: json['height'] as String? ?? "5'8\"",
        build: json['build'] as String? ?? 'Athletic',
        eyeColor: json['eyeColor'] as String? ?? 'Hazel',
        hairColor: json['hairColor'] as String? ?? 'Dark Brown',
        voiceDescription: json['voiceDescription'] as String? ?? 'Confident',
        wardrobeDNA: List<String>.from(json['wardrobe'] ?? []),
        dna: CharacterDNA.fromJson(json['dna'] ?? {}),
        healthScore: (json['healthScore'] as num?)?.toDouble() ?? 92,
        locked: json['locked'] as bool? ?? true,
        faceReferenceUrls: List<String>.from(json['faceReferenceUrls'] ?? []),
        activeOutfitId: json['activeOutfitId'] as String?,
        defaultStylePrompt: json['defaultStylePrompt'] as String? ?? '',
        continuityLock: json['continuityLock'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'avatarUrl': avatarUrl, 'role': role, 'age': age,
        'height': height, 'build': build, 'eyeColor': eyeColor, 'hairColor': hairColor,
        'voiceDescription': voiceDescription, 'wardrobe': wardrobeDNA, 'dna': dna.toJson(),
        'healthScore': healthScore, 'locked': locked, 'faceReferenceUrls': faceReferenceUrls,
        'activeOutfitId': activeOutfitId, 'defaultStylePrompt': defaultStylePrompt,
        'continuityLock': continuityLock,
      };

  Character copyWith({
    String? name, String? avatarUrl, List<String>? wardrobeDNA, CharacterDNA? dna,
    double? healthScore, bool? locked, List<String>? faceReferenceUrls, Outfit? activeOutfit,
    String? activeOutfitId, String? defaultStylePrompt, bool? continuityLock, List<Outfit>? closet,
  }) => Character(
        id: id, name: name ?? this.name, avatarUrl: avatarUrl ?? this.avatarUrl, role: role,
        age: age, height: height, build: build, eyeColor: eyeColor, hairColor: hairColor,
        voiceDescription: voiceDescription, wardrobeDNA: wardrobeDNA ?? this.wardrobeDNA,
        dna: dna ?? this.dna, healthScore: healthScore ?? this.healthScore, locked: locked ?? this.locked,
        faceReferenceUrls: faceReferenceUrls ?? this.faceReferenceUrls,
        activeOutfit: activeOutfit ?? this.activeOutfit, activeOutfitId: activeOutfitId ?? this.activeOutfitId,
        defaultStylePrompt: defaultStylePrompt ?? this.defaultStylePrompt,
        continuityLock: continuityLock ?? this.continuityLock, closet: closet ?? this.closet,
      );
}
