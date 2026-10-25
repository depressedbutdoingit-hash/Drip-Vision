import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';

/// Vector Learning Fusion Continuity Engine
/// Practical MAML-inspired few-shot adaptation, prototype networks,
/// adaptive meta-rate, and live health scoring for character DNA.
class ContinuityEngine {
  final Map<String, CharacterDNA> _dnaCache = {};
  final Map<String, List<double>> _driftHistory = {};
  double _metaLearningRate = 0.015;

  CharacterDNA? getDNA(String characterId) => _dnaCache[characterId];

  CharacterDNA adapt(CharacterDNA current, CharacterDNA target, {int shots = 1, double strength = 1.0}) {
    final rate = _metaLearningRate * strength * (1 + shots * 0.05);
    final adapted = CharacterDNA(
      face: _lerp(current.face, target.face, rate * 0.18),
      body: _lerp(current.body, target.body, rate * 0.12),
      wardrobe: _lerp(current.wardrobe, target.wardrobe, rate * 0.22),
      voice: _lerp(current.voice, target.voice, rate * 0.15),
      style: _lerp(current.style, target.style, rate * 0.10),
      locked: current.locked,
    );

    final drift = current.distanceTo(adapted);
    _recordDrift(current.id, drift);
    _updateMetaRate();

    return adapted;
  }

  CharacterDNA createPrototype(List<CharacterDNA> references) {
    if (references.isEmpty) return CharacterDNA.empty();
    final n = references.length.toDouble();
    return CharacterDNA(
      id: references.first.id,
      face: references.map((r) => r.face).reduce((a, b) => a + b) / n,
      body: references.map((r) => r.body).reduce((a, b) => a + b) / n,
      wardrobe: references.map((r) => r.wardrobe).reduce((a, b) => a + b) / n,
      voice: references.map((r) => r.voice).reduce((a, b) => a + b) / n,
      style: references.map((r) => r.style).reduce((a, b) => a + b) / n,
      locked: references.any((r) => r.locked),
    );
  }

  double getHealthScore(String characterId) {
    final history = _driftHistory[characterId];
    if (history == null || history.isEmpty) return 92.0;
    final avg = history.reduce((a, b) => a + b) / history.length;
    final score = 100 - (avg * 120).clamp(0.0, 85.0);
    return score.clamp(15.0, 100.0);
  }

  String getHealthMessage(double score) {
    if (score >= 95) return 'Perfect continuity. Identity locked.';
    if (score >= 85) return 'Strong consistency. Minor wardrobe drift possible.';
    if (score >= 70) return 'Good. Some attributes need attention.';
    return 'Continuity drift detected. One-tap fix recommended.';
  }

  Color getHealthColor(double score) {
    if (score >= 90) return const Color(0xFF00D4AA);
    if (score >= 75) return const Color(0xFFFFB020);
    return const Color(0xFFFF6B6B);
  }

  void lockCharacter(String id) {
    final dna = _dnaCache[id];
    if (dna != null) {
      _dnaCache[id] = dna.copyWith(locked: true);
    }
  }

  void _recordDrift(String id, double drift) {
    final list = _driftHistory.putIfAbsent(id, () => []);
    list.add(drift);
    if (list.length > 50) list.removeAt(0);
  }

  void _updateMetaRate() {
    final all = _driftHistory.values.expand((e) => e).toList();
    if (all.isEmpty) return;
    final avg = all.reduce((a, b) => a + b) / all.length;
    _metaLearningRate = (0.01 + avg * 0.05).clamp(0.005, 0.04);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}

class CharacterDNA {
  final String id;
  final double face;
  final double body;
  final double wardrobe;
  final double voice;
  final double style;
  final bool locked;

  const CharacterDNA({
    this.id = '',
    required this.face,
    required this.body,
    required this.wardrobe,
    required this.voice,
    required this.style,
    this.locked = false,
  });

  factory CharacterDNA.empty() => const CharacterDNA(
        face: 0.5,
        body: 0.5,
        wardrobe: 0.5,
        voice: 0.5,
        style: 0.5,
      );

  double distanceTo(CharacterDNA other) {
    final df = face - other.face;
    final db = body - other.body;
    final dw = wardrobe - other.wardrobe;
    final dv = voice - other.voice;
    final ds = style - other.style;
    return math.sqrt(df * df + db * db + dw * dw + dv * dv + ds * ds) / math.sqrt(5);
  }

  CharacterDNA copyWith({
    double? face,
    double? body,
    double? wardrobe,
    double? voice,
    double? style,
    bool? locked,
  }) {
    return CharacterDNA(
      id: id,
      face: face ?? this.face,
      body: body ?? this.body,
      wardrobe: wardrobe ?? this.wardrobe,
      voice: voice ?? this.voice,
      style: style ?? this.style,
      locked: locked ?? this.locked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'face': face,
        'body': body,
        'wardrobe': wardrobe,
        'voice': voice,
        'style': style,
        'locked': locked,
      };

  factory CharacterDNA.fromJson(Map<String, dynamic> json) => CharacterDNA(
        id: json['id'] as String? ?? '',
        face: (json['face'] as num?)?.toDouble() ?? 0.5,
        body: (json['body'] as num?)?.toDouble() ?? 0.5,
        wardrobe: (json['wardrobe'] as num?)?.toDouble() ?? 0.5,
        voice: (json['voice'] as num?)?.toDouble() ?? 0.5,
        style: (json['style'] as num?)?.toDouble() ?? 0.5,
        locked: json['locked'] as bool? ?? false,
      );
}

final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());