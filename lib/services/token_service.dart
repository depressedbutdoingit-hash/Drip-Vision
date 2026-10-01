import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Token economy. Admin unlimited is enforced via:
/// 1) Auth custom claim `admin: true` (preferred, server-set), or
/// 2) Firestore users/{uid}.role == 'admin' (transition).
/// Usage is still logged for cost visibility.
class TokenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _isAdminUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final token = await user.getIdTokenResult(true);
      if (token.claims?['admin'] == true) return true;
    } catch (_) {}
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final role = (doc.data()?['role'] ?? '').toString().trim().toLowerCase();
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }

  /// Deduct tokens. Returns true if allowed (including admin bypass).
  Future<bool> deduct(int amount, {String reason = 'generation'}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userId = user.uid;

    final admin = await _isAdminUser();
    if (admin) {
      // Unlimited access — still log usage for God Mode cost view
      await _firestore.collection('ai_usage').add({
        'uid': userId,
        'tokens': amount,
        'type': reason,
        'adminBypass': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    }

    final userRef = _firestore.collection('users').doc(userId);

    final ok = await _firestore.runTransaction((tx) async {
      final doc = await tx.get(userRef);
      if (!doc.exists) return false;
      final data = doc.data()!;
      final role = (data['role'] ?? '').toString().trim().toLowerCase();
      if (role == 'admin') return true;

      final currentBalance = (data['tokenBalance'] ?? 0) as int;
      if (currentBalance < amount) return false;

      tx.update(userRef, {
        'tokenBalance': currentBalance - amount,
        'totalSpent': FieldValue.increment(amount),
      });
      return true;
    });

    if (ok) {
      await _firestore.collection('ai_usage').add({
        'uid': userId,
        'tokens': amount,
        'type': reason,
        'adminBypass': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    return ok;
  }

  Future<int> getBalance() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 0;
    if (await _isAdminUser()) return 999999; // display only
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return 0;
    return (doc.data()?['tokenBalance'] ?? 0) as int;
  }

  Future<bool> isAdmin() => _isAdminUser();

  Future<void> addTokens(int amount, {String reason = 'purchase'}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'tokenBalance': FieldValue.increment(amount),
    });

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add({
      'amount': amount,
      'type': 'credit',
      'reason': reason,
      'timestamp': Timestamp.now(),
    });
  }
}
