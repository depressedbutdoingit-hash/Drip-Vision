import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/universe.dart';
import 'providers.dart';

/// Health of one character, 0-100.
/// 100 = continuity lock on AND at least one face reference saved.
/// 60  = locked but no face reference. 40 = lock is off.
int characterHealth(Character c) {
  if (!c.continuityLock) return 40;
  if (c.faceReferenceUrls.isEmpty) return 60;
  return 100;
}

double _average(List<Character> chars) => chars.isEmpty
    ? 100.0
    : chars.map(characterHealth).reduce((a, b) => a + b) / chars.length;

/// The current universe: all characters plus their overall health.
final universeProvider = Provider<Universe>((ref) {
  final chars = ref.watch(characterListProvider);
  return Universe(healthScore: _average(chars), characters: chars);
});

class ContinuityHealth {
  final int score;
  final Color color;
  final String message;

  const ContinuityHealth({
    required this.score,
    required this.color,
    required this.message,
  });
}

ContinuityHealth _healthFor(List<Character> chars) {
  if (chars.isEmpty) {
    return const ContinuityHealth(
      score: 100,
      color: Colors.green,
      message: 'No characters yet, nothing to drift.',
    );
  }
  final score = _average(chars).round();
  final unlocked = chars.where((c) => !c.continuityLock).length;
  final noRef = chars.where((c) => c.faceReferenceUrls.isEmpty).length;

  final color = score > 90
      ? Colors.green
      : score > 70
          ? Colors.orange
          : Colors.red;

  final message = unlocked > 0
      ? '$unlocked character(s) have continuity lock turned off.'
      : noRef > 0
          ? '$noRef character(s) have no face reference saved.'
          : 'All characters are locked and have a face reference.';

  return ContinuityHealth(score: score, color: color, message: message);
}

class ContinuityHealthNotifier extends StateNotifier<ContinuityHealth> {
  ContinuityHealthNotifier(this._ref)
      : super(_healthFor(_ref.read(characterListProvider)));

  final Ref _ref;

  void refresh(List<Character> chars) => state = _healthFor(chars);

  /// One-tap fix: turns continuity lock back on for every character.
  /// Characters with no face reference still need a photo added.
  void fix() {
    final notifier = _ref.read(characterListProvider.notifier);
    for (final c in _ref.read(characterListProvider)) {
      if (!c.continuityLock) {
        notifier.updateCharacter(c.copyWith(continuityLock: true));
      }
    }
  }
}

final continuityHealthProvider =
    StateNotifierProvider<ContinuityHealthNotifier, ContinuityHealth>((ref) {
  final notifier = ContinuityHealthNotifier(ref);
  ref.listen<List<Character>>(
    characterListProvider,
    (_, next) => notifier.refresh(next),
  );
  return notifier;
});