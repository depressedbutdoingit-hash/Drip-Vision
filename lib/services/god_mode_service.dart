
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// God Mode requires a trusted Firebase Authentication custom claim.
/// Firestore profile fields must never grant administrator privileges.
class GodModeService {
  static Future<bool> isAuthorizedAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final token = await user.getIdTokenResult(true);
      return token.claims?['admin'] == true;
    } catch (_) {
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots();
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
