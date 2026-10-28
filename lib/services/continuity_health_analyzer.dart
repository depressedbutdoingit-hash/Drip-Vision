import '../models/character.dart';
import '../models/scene.dart';

enum HealthTone { good, warn, bad, idle }

class ContinuityIssue {
  final String type;
  final String message;
  final String? sceneId;
  final bool autoFixable;
  const ContinuityIssue({required this.type, required this.message, this.sceneId, required this.autoFixable});
}

class HealthMetric {
  final String label;
  final int score; // 0-100
  final HealthTone tone;
  final String detail;

  const HealthMetric({
    required this.label,
    required this.score,
    required this.tone,
    required this.detail,
  });
}

class ContinuityReport {
  final List<HealthMetric> characterMetrics;
  final List<HealthMetric> locationMetrics;
  final List<HealthMetric> storyMetrics;
  final List<ContinuityIssue> issues;
  final int overallScore;

  const ContinuityReport({
    required this.characterMetrics,
    required this.locationMetrics,
    required this.storyMetrics,
    required this.issues,
    required this.overallScore,
  });
}

/// Offline-first continuity scoring from local cast + scene list.
/// Firestore ContinuityService remains the server-side source of truth when a projectId exists.
class ContinuityHealthAnalyzer {
  ContinuityReport analyze({
    required List<Character> characters,
    required List<SceneNode> scenes,
  }) {
    final issues = <ContinuityIssue>[];
    final characterMetrics = <HealthMetric>[];
    final locationMetrics = <HealthMetric>[];
    final storyMetrics = <HealthMetric>[];

    final ordered = [...scenes]
      ..sort((a, b) => a.sequenceIndex.compareTo(b.sequenceIndex));

    // --- Characters ---
    for (final c in characters) {
      var score = 70;
      final notes = <String>[];

      if (c.faceReferenceUrls.isNotEmpty) {
        score += 15;
        notes.add('Face reference locked');
      } else {
        score -= 20;
        notes.add('No face reference');
        issues.add(ContinuityIssue(
          type: 'identity',
          message: '${c.name}: no face reference — identity drift risk',
          autoFixable: false,
        ));
      }

      if (c.continuityLock) {
        score += 10;
        notes.add('Continuity DNA on');
      } else {
        score -= 15;
        notes.add('Continuity DNA off');
      }

      if (c.closet.isNotEmpty) {
        score += 5;
        notes.add('${c.closet.length} look(s)');
      }

      // Wardrobe flips across scenes
      final outfits = <String>[];
      for (final s in ordered) {
        final oid = s.characterOutfits[c.id];
        if (oid != null && oid.isNotEmpty) outfits.add(oid);
        // fallback: primary character on scene
        final activeOutfitId = s.character.activeOutfitId;
        if (s.character.id == c.id && activeOutfitId != null && activeOutfitId.isNotEmpty) {
          outfits.add(activeOutfitId);
        }
      }
      var flips = 0;
      for (var i = 1; i < outfits.length; i++) {
        if (outfits[i] != outfits[i - 1]) flips++;
      }
      if (flips > 0) {
        score -= flips * 8;
        notes.add('$flips wardrobe change(s)');
        issues.add(ContinuityIssue(
          type: 'wardrobe',
          message:
              '${c.name}: $flips wardrobe change(s) across the cut — confirm intentional',
          autoFixable: flips == 1,
        ));
      }

      score = score.clamp(0, 100).toInt();
      characterMetrics.add(HealthMetric(
        label: c.name,
        score: score,
        tone: _tone(score),
        detail: notes.join(' · '),
      ));
    }

    if (characters.isEmpty) {
      characterMetrics.add(const HealthMetric(
        label: 'Cast',
        score: 0,
        tone: HealthTone.idle,
        detail: 'No characters in universe',
      ));
      issues.add(ContinuityIssue(
        type: 'cast',
        message: 'Universe has no cast — create a character before generating',
        autoFixable: false,
      ));
    }

    // --- Locations ---
    final byLoc = <String, List<SceneNode>>{};
    for (final s in ordered) {
      final key = s.locationId ?? s.locationName ?? '';
      if (key.isEmpty) continue;
      byLoc.putIfAbsent(key, () => []).add(s);
    }
    if (byLoc.isEmpty) {
      locationMetrics.add(HealthMetric(
        label: 'Locations',
        score: ordered.isEmpty ? 0 : 55,
        tone: ordered.isEmpty ? HealthTone.idle : HealthTone.warn,
        detail: ordered.isEmpty
            ? 'No scenes yet'
            : 'Scenes lack location IDs — bible incomplete',
      ));
    } else {
      for (final entry in byLoc.entries) {
        final list = entry.value;
        var score = 90;
        final lightings =
            list.map((s) => s.lighting ?? '').where((x) => x.isNotEmpty).toSet();
        final times =
            list.map((s) => s.timeOfDay ?? '').where((x) => x.isNotEmpty).toSet();
        final name = list.first.locationName ?? entry.key;
        if (lightings.length > 1) {
          score -= 20;
          issues.add(ContinuityIssue(
            type: 'lighting',
            message: '$name: lighting shifts (${lightings.join(' / ')})',
            sceneId: list.last.id,
            autoFixable: true,
          ));
        }
        if (times.length > 1) {
          score -= 15;
          issues.add(ContinuityIssue(
            type: 'time',
            message: '$name: time-of-day shifts (${times.join(' / ')})',
            sceneId: list.last.id,
            autoFixable: false,
          ));
        }
        score = score.clamp(0, 100);
        locationMetrics.add(HealthMetric(
          label: name,
          score: score,
          tone: _tone(score),
          detail:
              '${list.length} scene(s) · lighting ${lightings.isEmpty ? '—' : lightings.join(',')}',
        ));
      }
    }

    // --- Story ---
    if (ordered.isEmpty) {
      storyMetrics.add(const HealthMetric(
        label: 'Timeline',
        score: 0,
        tone: HealthTone.idle,
        detail: 'No scenes in production',
      ));
    } else {
      var timelineScore = 100;
      for (var i = 1; i < ordered.length; i++) {
        final gap = ordered[i].sequenceIndex - ordered[i - 1].sequenceIndex;
        if (gap > 1) {
          timelineScore -= 10;
          issues.add(ContinuityIssue(
            type: 'timeline',
            message:
                'Sequence gap between scene ${ordered[i - 1].sequenceIndex} and ${ordered[i].sequenceIndex}',
            sceneId: ordered[i].id,
            autoFixable: false,
          ));
        }
      }
      final withVideo =
          ordered.where((s) => s.outputVideoUrl != null).length;
      final renderScore =
          ((withVideo / ordered.length) * 100).round().clamp(0, 100);
      storyMetrics.add(HealthMetric(
        label: 'Timeline',
        score: timelineScore.clamp(0, 100).toInt(),
        tone: _tone(timelineScore),
        detail: '${ordered.length} scene(s) sequenced',
      ));
      storyMetrics.add(HealthMetric(
        label: 'Rendered',
        score: renderScore,
        tone: _tone(renderScore),
        detail: '$withVideo / ${ordered.length} shots have media',
      ));
    }

    final allScores = [
      ...characterMetrics.map((m) => m.score),
      ...locationMetrics.map((m) => m.score),
      ...storyMetrics.map((m) => m.score),
    ];
    final overall = allScores.isEmpty
        ? 0
        : (allScores.reduce((a, b) => a + b) / allScores.length).round();

    return ContinuityReport(
      characterMetrics: characterMetrics,
      locationMetrics: locationMetrics,
      storyMetrics: storyMetrics,
      issues: issues,
      overallScore: overall,
    );
  }

  static HealthTone _tone(int score) {
    if (score >= 90) return HealthTone.good;
    if (score >= 70) return HealthTone.warn;
    if (score <= 0) return HealthTone.idle;
    return HealthTone.bad;
  }
}
