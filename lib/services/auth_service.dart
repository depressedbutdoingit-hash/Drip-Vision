import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthService(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = _auth.currentUser;
    if (user != null) {
      await ensureUserDocument(user);
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await ensureUserDocument(user, isNew: true);
    }
  }

  /// Creates users/{uid} if missing. Never overwrites role if already set
  /// (so promoting yourself to admin in Console is safe).
  Future<void> ensureUserDocument(User user, {bool isNew = false}) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    if (snap.exists) {
      // Only fill missing fields — do not reset role or tokens
      final data = snap.data() ?? {};
      final updates = <String, dynamic>{};
      if (data['email'] == null || (data['email'] as String).isEmpty) {
        updates['email'] = user.email ?? '';
      }
      if (data['role'] == null) {
        updates['role'] = 'customer';
      }
      if (data['tokenBalance'] == null) {
        updates['tokenBalance'] = 50;
      }
      if (data['subscriptionTier'] == null) {
        updates['subscriptionTier'] = 'free';
      }
      if (updates.isNotEmpty) {
        await ref.set(updates, SetOptions(merge: true));
      }
      return;
    }

    await ref.set({
      'email': user.email ?? '',
      'role': 'customer',
      'subscriptionTier': 'free',
      'tokenBalance': 50,
      'lastFreeClaimDate': Timestamp.fromDate(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    final user = cred.user;
    if (user != null) {
      await ensureUserDocument(user, isNew: true);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
