import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenService {
  static final _firestore = FirebaseFirestore.instance;

  /// Returns true if the user had enough tokens and they were deducted.
  static Future<bool> deduct(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final ref = _firestore.collection('users').doc(user.uid);

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['tokenBalance'] as num?)?.toInt() ?? 0;

      if (current < amount) return false;

      tx.update(ref, {
        'tokenBalance': current - amount,
        'lastGeneration': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  static Future<int> getBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    final snap = await _firestore.collection('users').doc(user.uid).get();
    return (snap.data()?['tokenBalance'] as num?)?.toInt() ?? 0;
  }
}