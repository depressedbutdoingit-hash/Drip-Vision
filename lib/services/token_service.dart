import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user has enough tokens and deduct the cost.
  /// Returns true if deduction succeeded, false if insufficient balance.
  Future<bool> deduct(int amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    final userRef = _firestore.collection('users').doc(userId);

    return _firestore.runTransaction((tx) async {
      final doc = await tx.get(userRef);
      if (!doc.exists) return false;

      final data = doc.data()!;
      final currentBalance = (data['tokenBalance'] ?? 0) as int;

      if (currentBalance < amount) return false;

      tx.update(userRef, {
        'tokenBalance': currentBalance - amount,
        'totalSpent': FieldValue.increment(amount),
      });

      return true;
    });
  }

  /// Get current token balance.
  Future<int> getBalance() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return 0;
    return (doc.data()?['tokenBalance'] ?? 0) as int;
  }

  /// Add tokens (for purchases, rewards, etc.)
  Future<void> addTokens(int amount, {String reason = 'purchase'}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'tokenBalance': FieldValue.increment(amount),
    });

    await _firestore.collection('users').doc(userId).collection('transactions').add({
      'amount': amount,
      'type': 'credit',
      'reason': reason,
      'timestamp': Timestamp.now(),
    });
  }
}

final tokenServiceProvider = Provider((ref) => TokenService());
