import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scene.dart';

/// Location Bible — Visual wiki of all locations in a project.
/// 
/// Features:
/// - Auto-generates location concept art from descriptions
/// - Tracks location usage across scenes
/// - Warns about impossible travel between locations
/// - Shows a timeline of where the story takes place
class LocationBibleService {
  final FirebaseFirestore _firestore;

  LocationBibleService(this._firestore);

  /// Get all locations for a project with usage stats.
  Future<List<LocationEntry>> getProjectLocations(String projectId) async {
    final projectDoc = await _firestore.collection('projects').doc(projectId).get();
    final locations = projectDoc.data()?['locations'] as Map<String, dynamic>? ?? {};

    final scenesSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('scenes')
        .get();

    final locationUsage = <String, int>{};
    for (final scene in scenesSnapshot.docs) {
      final locId = scene.data()['locationId'] as String?;
      if (locId != null) {
        locationUsage[locId] = (locationUsage[locId] ?? 0) + 1;
      }
    }

    return locations.entries.map((entry) {
      final data = entry.value as Map<String, dynamic>;
      return LocationEntry(
        id: entry.key,
        name: data['name'] ?? 'Unknown',
        description: data['description'] ?? '',
        timeOfDay: data['timeOfDay'] ?? '',
        lighting: data['lighting'] ?? '',
        sceneCount: locationUsage[entry.key] ?? 0,
        lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  /// Check if travel between two locations in consecutive scenes is plausible.
  TravelCheck checkTravelPlausibility({
    required LocationEntry from,
    required LocationEntry to,
    required int sceneGap,
  }) {
    // Simple heuristic: same location = always fine
    if (from.id == to.id) {
      return TravelCheck(isPlausible: true, message: 'Same location');
    }

    // If scene gap is 0 (consecutive), warn about fast travel
    if (sceneGap == 0) {
      return TravelCheck(
        isPlausible: false,
        message: 'Characters teleport from ${from.name} to ${to.name} with no transition',
        suggestion: 'Add a travel scene or montage between these locations',
      );
    }

    return TravelCheck(isPlausible: true, message: 'Travel time adequate');
  }

  /// Generate a concept art prompt for a location.
  String generateConceptPrompt(LocationEntry location) {
    return '''
Cinematic concept art of ${location.name}.
${location.description}
Time: ${location.timeOfDay}
Lighting: ${location.lighting}
Style: photorealistic, film grain, anamorphic lens, atmospheric haze.
No text, no watermarks.
'''.trim();
  }
}

class LocationEntry {
  final String id;
  final String name;
  final String description;
  final String timeOfDay;
  final String lighting;
  final int sceneCount;
  final DateTime? lastSeen;

  LocationEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.timeOfDay,
    required this.lighting,
    required this.sceneCount,
    this.lastSeen,
  });
}

class TravelCheck {
  final bool isPlausible;
  final String message;
  final String? suggestion;

  TravelCheck({
    required this.isPlausible,
    required this.message,
    this.suggestion,
  });
}
