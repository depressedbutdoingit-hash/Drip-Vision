import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/character.dart';

// No `part '...g.dart'` here: nothing in this file uses code generation,
// so that line was the source of the "ungenerated file" error.

class ContinuityEngine {
  final Map<String, Character> _charCache = {};
  double _metaLearningRate = 0.001;
  final List<double> _history = [];

  Future<Character> loadDNA(String id) async {
    final cached = _charCache[id];
    if (cached != null) return cached;

    final response =
        await http.get(Uri.parse('https://api.dripvision.com/dna/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load character $id (${response.statusCode})');
    }
    final char = Character.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
    _charCache[id] = char;
    return char;
  }

  Future<Vector> adapt(Vector current, Vector target, {int shots = 1}) async {
    final adapted = Vector(
      face: current.face + (target.face - current.face) * 0.15 * shots,
      wardrobe:
          current.wardrobe + (target.wardrobe - current.wardrobe) * 0.12 * shots,
      location:
          current.location + (target.location - current.location) * 0.08 * shots,
      voice: current.voice + (target.voice - current.voice) * 0.10 * shots,
    );

    final error = (current - adapted).magnitude;
    _metaLearningRate = 0.001 * (1 + error * 0.1);

    _history.add(error);
    if (_history.length > 100) _history.removeAt(0);

    return adapted;
  }

  Future<Vector> createPrototype(List<Vector> shots) async {
    if (shots.isEmpty) {
      throw ArgumentError('createPrototype needs at least one shot');
    }
    double avg(double Function(Vector) f) =>
        shots.map(f).reduce((a, b) => a + b) / shots.length;
    return Vector(
      face: avg((s) => s.face),
      wardrobe: avg((s) => s.wardrobe),
      location: shots.first.location,
      voice: shots.first.voice,
    );
  }

  double getHealthScore(String id) {
    if (!_charCache.containsKey(id)) return 0;
    final double historyAvg = _history.isEmpty
        ? 0.0
        : _history.reduce((a, b) => a + b) / _history.length;
    return 100 - (historyAvg * 80).clamp(0.0, 80.0).toDouble();
  }
}

class Vector {
  final double face;
  final double wardrobe;
  final double location;
  final double voice;

  const Vector({
    required this.face,
    required this.wardrobe,
    required this.location,
    required this.voice,
  });

  Vector operator -(Vector other) => Vector(
        face: face - other.face,
        wardrobe: wardrobe - other.wardrobe,
        location: location - other.location,
        voice: voice - other.voice,
      );

  double get magnitude =>
      (face.abs() + wardrobe.abs() + location.abs() + voice.abs()) / 4;

  factory Vector.fromJson(Map<String, dynamic> json) => Vector(
        face: (json['face'] as num).toDouble(),
        wardrobe: (json['wardrobe'] as num).toDouble(),
        location: (json['location'] as num).toDouble(),
        voice: (json['voice'] as num).toDouble(),
      );
}

final continuityEngineProvider =
    Provider<ContinuityEngine>((ref) => ContinuityEngine());