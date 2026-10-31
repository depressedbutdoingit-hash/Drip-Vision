import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Safe auth provider. Returns null if Firebase is not initialized so screens
/// can degrade instead of throwing the red "No Firebase App" error.
final authServiceProvider = Provider<AuthService?>((ref) {
  try {
    return AuthService(FirebaseAuth.instance);
  } catch (_) {
    return null;
  }
});
