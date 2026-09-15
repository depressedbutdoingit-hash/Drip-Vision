import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_dna.dart';
import '../models/scene.dart';

class ContinuityIssue {
  final String type;
  final String message;
  final String? sceneId;
  final bool autoFixable;

  ContinuityIssue({
    required this.type,
    required this.message,
    this.sceneId,
    this.autoFixable = false,
  });
}

class LocationMemory {
  final String locationId;
  final String name;
  final String description;
  final Map<String, dynamic> props;
  final String timeOfDay;
  final String weather;
  final String lighting;
  final DateTime lastSeen;

  LocationMemory({
    required this.locationId,
    required this.name,
    required this.description,
    required this.props,
    required this.timeOfDay,
    required this.weather,
    required this.lighting,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'locationId': locationId,
    'name': name,
    'description': description,
    'props': props,
    'timeOfDay': timeOfDay,
    'weather': weather,
    'lighting': lighting,
    'lastSeen': Timestamp.fromDate(lastSeen),
  };

  factory LocationMemory.fromJson(Map<String, dynamic> json) => LocationMemory(
    locationId: json['locationId'],
    name: json['name'],
    description: json['description'],
    props: json['props'] ?? {},
    timeOfDay: json['timeOfDay'] ?? '',
    weather: json['weather'] ?? '',
    lighting: json['lighting'] ?? '',
    lastSeen: (json['lastSeen'] as Timestamp).toDate(),
  );
}

class ContinuityService {
  final FirebaseFirestore _firestore;

  ContinuityService(this._firestore);

  Future<List<ContinuityIssue>> checkContinuity({
    required String projectId,
    required SceneNode proposedScene,
    required List<CharacterDNA> characters,
    required String? previousSceneId,
  }) async {
    final issues = <ContinuityIssue>[];

    final projectDoc = await _firestore
        .collection('projects')
        .doc(projectId)
        .get();

    final locations = (projectDoc.data()?['locations'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, LocationMemory.fromJson(v)));

    final characterStates = (projectDoc.data()?['characterStates'] as Map<String, dynamic>? ?? {});

    if (proposedScene.locationId != null && locations.containsKey(proposedScene.locationId)) {
      final mem = locations[proposedScene.locationId]!;
      if (proposedScene.lighting != null &&
          mem.lighting.isNotEmpty &&
          proposedScene.lighting != mem.lighting) {
        issues.add(ContinuityIssue(
          type: 'lighting',
          message: '\${mem.name} was previously \${mem.lighting}, but this scene requests \${proposedScene.lighting}',
          sceneId: proposedScene.id,
          autoFixable: true,
        ));
      }
    }

    for (final char in characters) {
      if (!char.continuityLock) continue;

      final lastState = characterStates[char.id] as Map<String, dynamic>?;
      if (lastState == null) continue;

      final lastOutfitId = lastState['outfitId'] as String?;
      final currentOutfitId = proposedScene.characterOutfits[char.id];

      if (lastOutfitId != null &&
          currentOutfitId != null &&
          lastOutfitId != currentOutfitId) {
        final lastOutfit = char.closet.firstWhere((o) => o.id == lastOutfitId, orElse: () => char.closet.first);
        final currentOutfit = char.closet.firstWhere((o) => o.id == currentOutfitId, orElse: () => char.closet.first);

        issues.add(ContinuityIssue(
          type: 'wardrobe',
          message: '\${char.name} was wearing "\${lastOutfit.name}" in the last scene, but now wears "\${currentOutfit.name}"',
          sceneId: proposedScene.id,
          autoFixable: true,
        ));
      }
    }

    for (final char in characters) {
      final lastState = characterStates[char.id] as Map<String, dynamic>?;
      if (lastState == null) continue;

      final wasPresent = lastState['present'] == true;
      final isPresent = proposedScene.characterIds.contains(char.id);

      if (wasPresent && !isPresent && !proposedScene.isTransition) {
        issues.add(ContinuityIssue(
          type: 'character',
          message: '\${char.name} was present in the last scene but disappears without explanation',
          sceneId: proposedScene.id,
          autoFixable: false,
        ));
      }
    }

    return issues;
  }

  Future<SceneNode> autoFix({
    required SceneNode scene,
    required List<ContinuityIssue> issues,
    required String projectId,
  }) async {
    var fixed = scene;

    for (final issue in issues.where((i) => i.autoFixable)) {
      switch (issue.type) {
        case 'lighting':
          final projectDoc = await _firestore.collection('projects').doc(projectId).get();
          final locations = projectDoc.data()?['locations'] as Map<String, dynamic>?;
          if (locations != null && fixed.locationId != null) {
            final mem = LocationMemory.fromJson(locations[fixed.locationId]);
            fixed = fixed.copyWith(lighting: mem.lighting);
          }
          break;
        case 'wardrobe':
          final projectDoc = await _firestore.collection('projects').doc(projectId).get();
          final states = projectDoc.data()?['characterStates'] as Map<String, dynamic>?;
          if (states != null) {
            final newOutfits = Map<String, String>.from(fixed.characterOutfits);
            for (final entry in states.entries) {
              if (fixed.characterIds.contains(entry.key)) {
                final lastOutfit = (entry.value as Map)['outfitId'] as String?;
                if (lastOutfit != null && !fixed.characterOutfits.containsKey(entry.key)) {
                  newOutfits[entry.key] = lastOutfit;
                }
              }
            }
            fixed = fixed.copyWith(characterOutfits: newOutfits);
          }
          break;
      }
    }

    return fixed;
  }

  Future<void> commitScene({
    required String projectId,
    required SceneNode scene,
    required List<CharacterDNA> characters,
  }) async {
    final projectRef = _firestore.collection('projects').doc(projectId);

    if (scene.locationId != null) {
      await projectRef.set({
        'locations': {
          scene.locationId!: LocationMemory(
            locationId: scene.locationId!,
            name: scene.locationName ?? 'Unknown Location',
            description: scene.locationDescription ?? '',
            props: scene.locationProps ?? {},
            timeOfDay: scene.timeOfDay ?? '',
            weather: scene.weather ?? '',
            lighting: scene.lighting ?? '',
            lastSeen: DateTime.now(),
          ).toJson(),
        }
      }, SetOptions(merge: true));
    }

    final charStates = <String, dynamic>{};
    for (final char in characters) {
      charStates[char.id] = {
        'present': scene.characterIds.contains(char.id),
        'outfitId': scene.characterOutfits[char.id] ?? char.defaultOutfitId,
        'lastSeen': Timestamp.now(),
      };
    }

    await projectRef.set({
      'characterStates': charStates,
      'lastSceneId': scene.id,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
