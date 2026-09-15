import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Season Pass / Battle Pass System
/// 
/// 30-day themed challenges with tiered rewards.
/// Increases retention and gives users goals beyond just making films.
class SeasonPassService {
  final FirebaseFirestore _firestore;

  SeasonPassService(this._firestore);

  /// Current season config.
  static const SeasonConfig currentSeason = SeasonConfig(
    id: 'season_1_horror',
    title: 'Season of Shadows',
    theme: 'Horror',
    durationDays: 30,
    tiers: [
      PassTier(level: 1, xpRequired: 0, reward: 'Cozy Pajamas outfit'),
      PassTier(level: 2, xpRequired: 100, reward: '100 bonus tokens'),
      PassTier(level: 3, xpRequired: 250, reward: 'Neon Punk outfit'),
      PassTier(level: 4, xpRequired: 500, reward: '200 bonus tokens'),
      PassTier(level: 5, xpRequired: 1000, reward: 'Galaxy Gown outfit'),
      PassTier(level: 6, xpRequired: 2000, reward: '500 bonus tokens'),
      PassTier(level: 7, xpRequired: 3500, reward: 'Ethereal Wings outfit'),
      PassTier(level: 8, xpRequired: 5000, reward: '1000 bonus tokens + Legendary badge'),
    ],
    challenges: [
      SeasonChallenge(
        id: 'make_horror_film',
        title: 'Make a Horror Film',
        description: 'Create any film with the Horror genre',
        xpReward: 100,
      ),
      SeasonChallenge(
        id: 'use_rain',
        title: 'Storm Chaser',
        description: 'Include rain in a scene',
        xpReward: 50,
      ),
      SeasonChallenge(
        id: 'get_10_drips',
        title: 'Crowd Pleaser',
        description: 'Receive 10 drips on one film',
        xpReward: 150,
      ),
      SeasonChallenge(
        id: 'remix_someone',
        title: 'Collaborator',
        description: 'Remix another creator\'s film',
        xpReward: 75,
      ),
      SeasonChallenge(
        id: 'use_voice_lock',
        title: 'Voice Actor',
        description: 'Use Voice Lock on a character',
        xpReward: 200,
      ),
      SeasonChallenge(
        id: 'make_5_films',
        title: 'Prolific',
        description: 'Create 5 films this season',
        xpReward: 300,
      ),
    ],
  );

  /// Get user's current season progress.
  Future<SeasonProgress> getUserProgress(String userId) async {
    final doc = await _firestore.collection('season_progress').doc(userId).get();
    if (!doc.exists) {
      return SeasonProgress(userId: userId, currentXp: 0, completedChallenges: []);
    }

    final data = doc.data()!;
    return SeasonProgress(
      userId: userId,
      currentXp: data['currentXp'] ?? 0,
      completedChallenges: List<String>.from(data['completedChallenges'] ?? []),
      seasonId: data['seasonId'] ?? currentSeason.id,
    );
  }

  /// Complete a challenge and award XP.
  Future<void> completeChallenge({
    required String userId,
    required String challengeId,
  }) async {
    final progress = await getUserProgress(userId);
    if (progress.completedChallenges.contains(challengeId)) return;

    final challenge = currentSeason.challenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => const SeasonChallenge(id: '', title: '', description: '', xpReward: 0),
    );

    if (challenge.id.isEmpty) return;

    final newXp = progress.currentXp + challenge.xpReward;
    final newCompleted = [...progress.completedChallenges, challengeId];

    await _firestore.collection('season_progress').doc(userId).set({
      'currentXp': newXp,
      'completedChallenges': newCompleted,
      'seasonId': currentSeason.id,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Calculate current tier based on XP.
  PassTier getCurrentTier(int xp) {
    PassTier current = currentSeason.tiers.first;
    for (final tier in currentSeason.tiers) {
      if (xp >= tier.xpRequired) {
        current = tier;
      }
    }
    return current;
  }

  /// Get next tier and remaining XP needed.
  ({PassTier? nextTier, int xpNeeded}) getNextTier(int xp) {
    for (final tier in currentSeason.tiers) {
      if (xp < tier.xpRequired) {
        return (nextTier: tier, xpNeeded: tier.xpRequired - xp);
      }
    }
    return (nextTier: null, xpNeeded: 0);
  }
}

class SeasonConfig {
  final String id;
  final String title;
  final String theme;
  final int durationDays;
  final List<PassTier> tiers;
  final List<SeasonChallenge> challenges;

  const SeasonConfig({
    required this.id,
    required this.title,
    required this.theme,
    required this.durationDays,
    required this.tiers,
    required this.challenges,
  });
}

class PassTier {
  final int level;
  final int xpRequired;
  final String reward;

  const PassTier({
    required this.level,
    required this.xpRequired,
    required this.reward,
  });
}

class SeasonChallenge {
  final String id;
  final String title;
  final String description;
  final int xpReward;

  const SeasonChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
  });
}

class SeasonProgress {
  final String userId;
  final int currentXp;
  final List<String> completedChallenges;
  final String seasonId;

  SeasonProgress({
    required this.userId,
    required this.currentXp,
    required this.completedChallenges,
    this.seasonId = '',
  });
}
