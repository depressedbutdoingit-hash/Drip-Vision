import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Server-oriented admin gate.
/// Preferred: Firebase Auth custom claim `admin: true` (set via Admin SDK / Cloud Function).
/// Fallback (transition only): Firestore users/{uid}.role == 'admin'.
/// Client UI still checks this, but Security Rules must enforce the same.
class GodModeService {
  static Future<bool> isAuthorizedAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final token = await user.getIdTokenResult(true);
      final claim = token.claims?['admin'];
      if (claim == true) return true;
    } catch (_) {}

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = (doc.data()?['role'] ?? '').toString().trim().toLowerCase();
      return role == 'admin';
    } catch (_) {
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> usageStream() {
    return FirebaseFirestore.instance
        .collection('ai_usage')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> configStream() {
    return FirebaseFirestore.instance
        .collection('admin_config')
        .doc('app')
        .snapshots();
  }
}
