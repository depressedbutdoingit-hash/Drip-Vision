import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/character_dna.dart' hide Outfit;
import '../models/scene.dart';

// ---------------------------------------------------------------------------
// Part 1: ORIGINAL Firestore-based continuity checker (restored from the
// initial commit). Used by providers.dart, production queue, health analyzer.
// ---------------------------------------------------------------------------

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

    final projectDoc =
        await _firestore.collection('projects').doc(projectId).get();

    final locations =
        (projectDoc.data()?['locations'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, LocationMemory.fromJson(v)));

    final characterStates =
        (projectDoc.data()?['characterStates'] as Map<String, dynamic>? ?? {});

    if (proposedScene.locationId != null &&
        locations.containsKey(proposedScene.locationId)) {
      final mem = locations[proposedScene.locationId]!;
      if (proposedScene.lighting != null &&
          mem.lighting.isNotEmpty &&
          proposedScene.lighting != mem.lighting) {
        issues.add(ContinuityIssue(
          type: 'lighting',
          message:
              '${mem.name} was previously ${mem.lighting}, but this scene requests ${proposedScene.lighting}',
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
        final lastOutfit = char.closet.firstWhere(
            (o) => o.id == lastOutfitId,
            orElse: () => char.closet.first);
        final currentOutfit = char.closet.firstWhere(
            (o) => o.id == currentOutfitId,
            orElse: () => char.closet.first);
        issues.add(ContinuityIssue(
          type: 'wardrobe',
          message:
              '${char.name} was wearing "${lastOutfit.name}" in the last scene, but now wears "${currentOutfit.name}"',
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
          message:
              '${char.name} was present in the last scene but disappears without explanation',
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
          final projectDoc =
              await _firestore.collection('projects').doc(projectId).get();
          final locations =
              projectDoc.data()?['locations'] as Map<String, dynamic>?;
          if (locations != null && fixed.locationId != null) {
            final mem = LocationMemory.fromJson(locations[fixed.locationId]);
            fixed = fixed.copyWith(lighting: mem.lighting);
          }
          break;
        case 'wardrobe':
          final projectDoc =
              await _firestore.collection('projects').doc(projectId).get();
          final states =
              projectDoc.data()?['characterStates'] as Map<String, dynamic>?;
          if (states != null) {
            final newOutfits =
                Map<String, String>.from(fixed.characterOutfits);
            for (final entry in states.entries) {
              if (fixed.characterIds.contains(entry.key)) {
                final lastOutfit = (entry.value as Map)['outfitId'] as String?;
                if (lastOutfit != null &&
                    !fixed.characterOutfits.containsKey(entry.key)) {
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

// ---------------------------------------------------------------------------
// Part 2: lightweight vector "engine" used by the newer screens
// (director's bible, edit bay, generator). It nudges four numbers toward a
// target; it is not real MAML / meta-learning.
// ---------------------------------------------------------------------------

class ContinuityEngine {
  final Map<String, Character> _charCache = {};
  final List<double> _history = [];

  Future<Character> loadDNA(String id) async {
    final cached = _charCache[id];
    if (cached != null) return cached;

    final response =
        await http.get(Uri.parse('https://api.dripvision.com/dna/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load character $id (${response.statusCode})');
    }
    final char = Character.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
    _charCache[id] = char;
    return char;
  }

  Future<Vector> adapt(Vector current, Vector target, {int shots = 1}) async {
    final adapted = Vector(
      face: current.face + (target.face - current.face) * 0.15 * shots,
      wardrobe:
          current.wardrobe + (target.wardrobe - current.wardrobe) * 0.12 * shots,
      location:
          current.location + (target.location - current.location) * 0.08 * shots,
      voice: current.voice + (target.voice - current.voice) * 0.10 * shots,
    );

    final error = (current - adapted).magnitude;
    _history.add(error);
    if (_history.length > 100) _history.removeAt(0);

    return adapted;
  }

  Future<Vector> createPrototype(List<Vector> shots) async {
    if (shots.isEmpty) {
      throw ArgumentError('createPrototype needs at least one shot');
    }
    double avg(double Function(Vector) f) =>
        shots.map(f).reduce((a, b) => a + b) / shots.length;
    return Vector(
      face: avg((s) => s.face),
      wardrobe: avg((s) => s.wardrobe),
      location: shots.first.location,
      voice: shots.first.voice,
    );
  }

  double getHealthScore(String id) {
    if (!_charCache.containsKey(id)) return 0;
    final double historyAvg = _history.isEmpty
        ? 0.0
        : _history.reduce((a, b) => a + b) / _history.length;
    return 100 - (historyAvg * 80).clamp(0.0, 80.0).toDouble();
  }
}

class Vector {
  final double face;
  final double wardrobe;
  final double location;
  final double voice;

  const Vector({
    required this.face,
    required this.wardrobe,
    required this.location,
    required this.voice,
  });

  Vector operator -(Vector other) => Vector(
        face: face - other.face,
        wardrobe: wardrobe - other.wardrobe,
        location: location - other.location,
        voice: voice - other.voice,
      );

  double get magnitude =>
      (face.abs() + wardrobe.abs() + location.abs() + voice.abs()) / 4;

  factory Vector.fromJson(Map<String, dynamic> json) => Vector(
        face: (json['face'] as num).toDouble(),
        wardrobe: (json['wardrobe'] as num).toDouble(),
        location: (json['location'] as num).toDouble(),
        voice: (json['voice'] as num).toDouble(),
      );
}

final continuityEngineProvider =
    Provider<ContinuityEngine>((ref) => ContinuityEngine());