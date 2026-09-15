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
}
