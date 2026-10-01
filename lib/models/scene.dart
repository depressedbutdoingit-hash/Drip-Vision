import 'character.dart';

class SceneNode {
  final String id;
  final int sequenceIndex;
  final String prompt;
  final String enhancedPrompt;
  final Character character;
  final String? inputLastFrameUrl;
  final String? outputVideoUrl;
  final String? generatedLastFrameUrl;
  final String? cameraMotion;
  final DateTime createdAt;

  // New continuity fields
  final String? locationId;
  final String? locationName;
  final String? locationDescription;
  final Map<String, dynamic>? locationProps;
  final String? timeOfDay;
  final String? weather;
  final String? lighting;
  final List<String> characterIds;
  final Map<String, String> characterOutfits;
  final bool isTransition;

  // SOUND DEPARTMENT
  final String? musicTrackUrl;
  final String? musicTitle;
  final String? ambienceNotes;
  final String? ambienceTrackUrl;
  final List<String> sfxCues;

  SceneNode({
    required this.id,
    this.sequenceIndex = 0,
    required this.prompt,
    this.enhancedPrompt = '',
    required this.character,
    this.inputLastFrameUrl,
    this.outputVideoUrl,
    this.generatedLastFrameUrl,
    this.cameraMotion,
    DateTime? createdAt,
    this.locationId,
    this.locationName,
    this.locationDescription,
    this.locationProps,
    this.timeOfDay,
    this.weather,
    this.lighting,
    this.characterIds = const [],
    this.characterOutfits = const {},
    this.isTransition = false,
    this.musicTrackUrl,
    this.musicTitle,
    this.ambienceNotes,
    this.ambienceTrackUrl,
    this.sfxCues = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  SceneNode copyWith({
    String? id,
    int? sequenceIndex,
    String? prompt,
    String? enhancedPrompt,
    Character? character,
    String? inputLastFrameUrl,
    String? outputVideoUrl,
    String? generatedLastFrameUrl,
    String? cameraMotion,
    DateTime? createdAt,
    String? locationId,
    String? locationName,
    String? locationDescription,
    Map<String, dynamic>? locationProps,
    String? timeOfDay,
    String? weather,
    String? lighting,
    List<String>? characterIds,
    Map<String, String>? characterOutfits,
    bool? isTransition,
    String? musicTrackUrl,
    String? musicTitle,
    String? ambienceNotes,
    String? ambienceTrackUrl,
    List<String>? sfxCues,
  }) {
    return SceneNode(
      id: id ?? this.id,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      prompt: prompt ?? this.prompt,
      enhancedPrompt: enhancedPrompt ?? this.enhancedPrompt,
      character: character ?? this.character,
      inputLastFrameUrl: inputLastFrameUrl ?? this.inputLastFrameUrl,
      outputVideoUrl: outputVideoUrl ?? this.outputVideoUrl,
      generatedLastFrameUrl: generatedLastFrameUrl ?? this.generatedLastFrameUrl,
      cameraMotion: cameraMotion ?? this.cameraMotion,
      createdAt: createdAt ?? this.createdAt,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationDescription: locationDescription ?? this.locationDescription,
      locationProps: locationProps ?? this.locationProps,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weather: weather ?? this.weather,
      lighting: lighting ?? this.lighting,
      characterIds: characterIds ?? this.characterIds,
      characterOutfits: characterOutfits ?? this.characterOutfits,
      isTransition: isTransition ?? this.isTransition,
      musicTrackUrl: musicTrackUrl ?? this.musicTrackUrl,
      musicTitle: musicTitle ?? this.musicTitle,
      ambienceNotes: ambienceNotes ?? this.ambienceNotes,
      ambienceTrackUrl: ambienceTrackUrl ?? this.ambienceTrackUrl,
      sfxCues: sfxCues ?? this.sfxCues,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sequenceIndex': sequenceIndex,
        'prompt': prompt,
        'enhancedPrompt': enhancedPrompt,
        'character': character.toJson(),
        'inputLastFrameUrl': inputLastFrameUrl,
        'outputVideoUrl': outputVideoUrl,
        'generatedLastFrameUrl': generatedLastFrameUrl,
        'cameraMotion': cameraMotion,
        'createdAt': createdAt.toIso8601String(),
        'locationId': locationId,
        'locationName': locationName,
        'locationDescription': locationDescription,
        'locationProps': locationProps,
        'timeOfDay': timeOfDay,
        'weather': weather,
        'lighting': lighting,
        'characterIds': characterIds,
        'characterOutfits': characterOutfits,
        'isTransition': isTransition,
        'musicTrackUrl': musicTrackUrl,
        'musicTitle': musicTitle,
        'ambienceNotes': ambienceNotes,
        'ambienceTrackUrl': ambienceTrackUrl,
        'sfxCues': sfxCues,
      };

  factory SceneNode.fromMap(Map<String, dynamic> m) => SceneNode(
        id: m['id'] as String? ?? '',
        sequenceIndex: (m['sequenceIndex'] as num?)?.toInt() ?? 0,
        prompt: m['prompt'] as String? ?? '',
        enhancedPrompt: m['enhancedPrompt'] as String? ?? '',
        character: m['character'] is Map
            ? Character.fromJson(Map<String, dynamic>.from(m['character'] as Map))
            : Character(
                id: 'unknown',
                name: 'Unknown',
                faceReferenceUrls: const [],
                activeOutfitId: '',
                closet: const [],
              ),
        inputLastFrameUrl: m['inputLastFrameUrl'] as String?,
        outputVideoUrl: m['outputVideoUrl'] as String?,
        generatedLastFrameUrl: m['generatedLastFrameUrl'] as String?,
        cameraMotion: m['cameraMotion'] as String?,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        locationId: m['locationId'] as String?,
        locationName: m['locationName'] as String?,
        locationDescription: m['locationDescription'] as String?,
        locationProps: m['locationProps'] is Map
            ? Map<String, dynamic>.from(m['locationProps'] as Map)
            : null,
        timeOfDay: m['timeOfDay'] as String?,
        weather: m['weather'] as String?,
        lighting: m['lighting'] as String?,
        characterIds: (m['characterIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        characterOutfits: m['characterOutfits'] is Map
            ? Map<String, String>.from(
                (m['characterOutfits'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
            : const {},
        isTransition: m['isTransition'] as bool? ?? false,
        musicTrackUrl: m['musicTrackUrl'] as String?,
        musicTitle: m['musicTitle'] as String?,
        ambienceNotes: m['ambienceNotes'] as String?,
        ambienceTrackUrl: m['ambienceTrackUrl'] as String?,
        sfxCues: (m['sfxCues'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}
