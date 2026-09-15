import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerationGuard {
  final _db = FirebaseFirestore.instance;

  Future<bool> deductAndValidateTokens({
    required int costInTokens,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userRef = _db.collection('users').doc(uid);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      if (!snap.exists) return false;

      final data = snap.data()!;

      // ADMIN GOD MODE: Never deduct tokens for admin
      if (data['role'] == 'admin') {
        return true;
      }

      final current = (data['tokenBalance'] ?? 0) as int;
      if (current >= costInTokens) {
        tx.update(userRef, {'tokenBalance': current - costInTokens});
        return true;
      }
      return false;
    });
  }
}
