import 'package:cloud_firestore/cloud_firestore.dart';

/// Drip Chain — Collaborative filmmaking where users remix each other's scenes
/// into a continuous film. Like GitHub commits but for movies.
/// 
/// Flow:
/// 1. User A creates Scene 1 (the "genesis" scene)
/// 2. User B "extends" the chain with Scene 2 (must pass continuity check)
/// 3. User C adds Scene 3, etc.
/// 4. The full chain becomes a "Drip Film" — credited to all contributors
class DripChainService {
  final FirebaseFirestore _firestore;

  DripChainService(this._firestore);

  /// Create a new chain (genesis scene).
  Future<String> createChain({
    required String creatorId,
    required String creatorName,
    required String title,
    required String genre,
    required String initialSceneId,
    required String initialScenePrompt,
  }) async {
    final chainRef = _firestore.collection('drip_chains').doc();
    await chainRef.set({
      'title': title,
      'genre': genre,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': Timestamp.now(),
      'sceneCount': 1,
      'contributors': [creatorId],
      'contributorNames': [creatorName],
      'headSceneId': initialSceneId,
      'isComplete': false,
      'totalDrips': 0,
    });

    // Add genesis link
    await chainRef.collection('links').add({
      'sceneId': initialSceneId,
      'scenePrompt': initialScenePrompt,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'sequence': 1,
      'previousLinkId': null,
      'createdAt': Timestamp.now(),
    });

    return chainRef.id;
  }

  /// Extend a chain with a new scene.
  Future<ChainLinkResult> extendChain({
    required String chainId,
    required String creatorId,
    required String creatorName,
    required String newSceneId,
    required String newScenePrompt,
    required String previousSceneId,
  }) async {
    final chainRef = _firestore.collection('drip_chains').doc(chainId);
    final chainDoc = await chainRef.get();

    if (!chainDoc.exists) {
      throw Exception('Chain not found');
    }

    final chainData = chainDoc.data()!;
    final currentCount = (chainData['sceneCount'] ?? 0) as int;
    final contributors = List<String>.from(chainData['contributors'] ?? []);

    // Add new link
    final linkRef = await chainRef.collection('links').add({
      'sceneId': newSceneId,
      'scenePrompt': newScenePrompt,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'sequence': currentCount + 1,
      'previousLinkId': previousSceneId,
      'createdAt': Timestamp.now(),
    });

    // Update chain metadata
    if (!contributors.contains(creatorId)) {
      contributors.add(creatorId);
    }

    await chainRef.update({
      'sceneCount': currentCount + 1,
      'contributors': contributors,
      'headSceneId': newSceneId,
      'updatedAt': Timestamp.now(),
    });

    return ChainLinkResult(
      linkId: linkRef.id,
      sequence: currentCount + 1,
      chainId: chainId,
    );
  }

  /// Get all scenes in a chain in order.
  Future<List<ChainLink>> getChainLinks(String chainId) async {
    final snapshot = await _firestore
        .collection('drip_chains')
        .doc(chainId)
        .collection('links')
        .orderBy('sequence')
        .get();

    return snapshot.docs.map((doc) => ChainLink(
      id: doc.id,
      sceneId: doc.data()['sceneId'],
      scenePrompt: doc.data()['scenePrompt'],
      creatorId: doc.data()['creatorId'],
      creatorName: doc.data()['creatorName'],
      sequence: doc.data()['sequence'],
      previousLinkId: doc.data()['previousLinkId'],
    )).toList();
  }

  /// Mark a chain as complete (final film).
  Future<void> finalizeChain(String chainId) async {
    await _firestore.collection('drip_chains').doc(chainId).update({
      'isComplete': true,
      'completedAt': Timestamp.now(),
    });
  }

  /// Get trending chains.
  Future<List<DripChainSummary>> getTrendingChains({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('drip_chains')
        .where('isComplete', isEqualTo: true)
        .orderBy('totalDrips', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => DripChainSummary(
      id: doc.id,
      title: doc.data()['title'] ?? 'Untitled',
      genre: doc.data()['genre'] ?? 'Unknown',
      creatorName: doc.data()['creatorName'] ?? 'Anonymous',
      sceneCount: doc.data()['sceneCount'] ?? 0,
      contributorCount: (doc.data()['contributors'] ?? []).length,
      totalDrips: doc.data()['totalDrips'] ?? 0,
    )).toList();
  }

  /// Chains a user has contributed to (started or extended) — "MY CHAINS".
  Future<List<DripChainSummary>> getUserChains(String userId, {int limit = 30}) async {
    final snapshot = await _firestore
        .collection('drip_chains')
        .where('contributors', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => DripChainSummary(
      id: doc.id,
      title: doc.data()['title'] ?? 'Untitled',
      genre: doc.data()['genre'] ?? 'Unknown',
      creatorName: doc.data()['creatorName'] ?? 'Anonymous',
      sceneCount: doc.data()['sceneCount'] ?? 0,
      contributorCount: (doc.data()['contributors'] ?? []).length,
      totalDrips: doc.data()['totalDrips'] ?? 0,
    )).toList();
  }

  /// Currently open (incomplete) chains, available to extend.
  Future<List<DripChainSummary>> getOpenChains({int limit = 30}) async {
    final snapshot = await _firestore
        .collection('drip_chains')
        .where('isComplete', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => DripChainSummary(
      id: doc.id,
      title: doc.data()['title'] ?? 'Untitled',
      genre: doc.data()['genre'] ?? 'Unknown',
      creatorName: doc.data()['creatorName'] ?? 'Anonymous',
      sceneCount: doc.data()['sceneCount'] ?? 0,
      contributorCount: (doc.data()['contributors'] ?? []).length,
      totalDrips: doc.data()['totalDrips'] ?? 0,
    )).toList();
  }
}

class ChainLink {
  final String id;
  final String sceneId;
  final String scenePrompt;
  final String creatorId;
  final String creatorName;
  final int sequence;
  final String? previousLinkId;

  ChainLink({
    required this.id,
    required this.sceneId,
    required this.scenePrompt,
    required this.creatorId,
    required this.creatorName,
    required this.sequence,
    this.previousLinkId,
  });
}

class ChainLinkResult {
  final String linkId;
  final int sequence;
  final String chainId;

  ChainLinkResult({
    required this.linkId,
    required this.sequence,
    required this.chainId,
  });
}

class DripChainSummary {
  final String id;
  final String title;
  final String genre;
  final String creatorName;
  final int sceneCount;
  final int contributorCount;
  final int totalDrips;

  DripChainSummary({
    required this.id,
    required this.title,
    required this.genre,
    required this.creatorName,
    required this.sceneCount,
    required this.contributorCount,
    required this.totalDrips,
  });
}
