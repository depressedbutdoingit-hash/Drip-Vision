import 'package:cloud_firestore/cloud_firestore.dart';

/// Drip Score — Gamified virality metric for films.
/// 
/// Formula:
/// - Base: dripCount × 10
/// - Watch time bonus: avgWatchSeconds × 2
/// - Remix multiplier: remixCount × 50
/// - Token tips: tipsReceived × 5
/// - Continuity complexity: sceneCount × 5
/// - Creator streak: consecutiveDays × 20
class DripScoreService {
  final FirebaseFirestore _firestore;

  DripScoreService(this._firestore);

  /// Calculate drip score for a film.
  Future<int> calculateScore({
    required String filmId,
    required String creatorId,
  }) async {
    final filmDoc = await _firestore.collection('public_scenes').doc(filmId).get();
    final creatorDoc = await _firestore.collection('users').doc(creatorId).get();

    if (!filmDoc.exists) return 0;

    final film = filmDoc.data()!;
    final creator = creatorDoc.data() ?? {};

    final dripCount = (film['dripCount'] ?? 0) as int;
    final remixCount = (film['remixCount'] ?? 0) as int;
    final tipsReceived = (film['tipsReceived'] ?? 0) as int;
    final avgWatchSeconds = (film['avgWatchSeconds'] ?? 0) as int;
    final sceneCount = (film['sceneCount'] ?? 1) as int;
    final streak = (creator['creatorStreak'] ?? 0) as int;

    final score = 
        (dripCount * 10) +
        (avgWatchSeconds * 2) +
        (remixCount * 50) +
        (tipsReceived * 5) +
        (sceneCount * 5) +
        (streak * 20);

    // Update the film's drip score
    await _firestore.collection('public_scenes').doc(filmId).update({
      'dripScore': score,
      'dripScoreUpdatedAt': Timestamp.now(),
    });

    return score;
  }

  /// Get global leaderboard.
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('public_scenes')
        .orderBy('dripScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => LeaderboardEntry(
      filmId: doc.id,
      title: doc.data()['title'] ?? 'Untitled',
      creatorName: doc.data()['creatorName'] ?? 'Anonymous',
      dripScore: doc.data()['dripScore'] ?? 0,
      dripCount: doc.data()['dripCount'] ?? 0,
    )).toList();
  }

  /// Award badges based on milestones.
  Future<List<String>> checkBadges(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    final data = userDoc.data()!;
    final badges = <String>[];

    final filmsMade = (data['filmsMade'] ?? 0) as int;
    final totalDrips = (data['totalDripsReceived'] ?? 0) as int;
    final totalRemixes = (data['totalRemixes'] ?? 0) as int;

    if (filmsMade >= 1) badges.add('First Cut');
    if (filmsMade >= 10) badges.add('Prolific');
    if (filmsMade >= 50) badges.add('Auteur');
    if (totalDrips >= 100) badges.add('Crowd Pleaser');
    if (totalDrips >= 1000) badges.add('Viral Sensation');
    if (totalRemixes >= 10) badges.add('Influencer');
    if (totalRemixes >= 50) badges.add('Trendsetter');

    return badges;
  }
}

class LeaderboardEntry {
  final String filmId;
  final String title;
  final String creatorName;
  final int dripScore;
  final int dripCount;

  LeaderboardEntry({
    required this.filmId,
    required this.title,
    required this.creatorName,
    required this.dripScore,
    required this.dripCount,
  });
}
