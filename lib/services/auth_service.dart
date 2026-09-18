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

  /// Creates users/{uid} if missing. New accounts get role "customer".
  /// Promote yourself to admin in Firebase Console (see project docs).
  Future<void> ensureUserDocument(User user, {bool isNew = false}) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists && !isNew) return;

    await ref.set({
      'email': user.email ?? '',
      'role': 'customer',
      'subscriptionTier': 'free',
      'tokenBalance': 50,
      'lastFreeClaimDate': Timestamp.fromDate(DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
