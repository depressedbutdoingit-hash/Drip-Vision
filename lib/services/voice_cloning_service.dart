import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceCloningProvider = Provider<int>((ref) => 0);

class VoiceCloningService {
  int _usedToday = 0;

  bool canClone() {
    if (_usedToday < 1) return true; // 1 per week free tier
    return false;
  }

  void clone() {
    _usedToday++;
  }
}