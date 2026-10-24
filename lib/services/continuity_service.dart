import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/universe.dart';

part 'continuity_service.g.dart';

class ContinuityEngine {
  final Map<String, Vector> _dnaCache = {};
  double _metaLearningRate = 0.001;
  final List<double> _history = [];

  Future<Character> loadDNA(String id) async {
    if (_dnaCache.containsKey(id)) return _dnaCache[id]!;
    final response = await http.get(Uri.parse('https://api.dripvision.com/dna/$id'));
    final char = Character.fromJson(json.decode(response.body));
    _dnaCache[id] = char;
    return char;
  }

  Future<Vector> adapt(Vector current, Vector target, {int shots = 1}) async {
    final adapted = Vector(
      face: current.face + (target.face - current.face) * 0.15 * shots,
      wardrobe: current.wardrobe + (target.wardrobe - current.wardrobe) * 0.12 * shots,
      location: current.location + (target.location - current.location) * 0.08 * shots,
      voice: current.voice + (target.voice - current.voice) * 0.10 * shots,
    );

    final error = (current - adapted).magnitude;
    _metaLearningRate = 0.001 * (1 + error * 0.1);

    _history.add(error);
    if (_history.length > 100) _history.removeAt(0);

    return adapted;
  }

  Future<Vector> createPrototype(List<Vector> shots) async {
    final avgFace = shots.map((s) => s.face).reduce((a, b) => a + b) / shots.length;
    final avgWardrobe = shots.map((s) => s.wardrobe).reduce((a, b) => a + b) / shots.length;
    return Vector(face: avgFace, wardrobe: avgWardrobe, location: shots[0].location, voice: shots[0].voice);
  }

  double getHealthScore(String id) {
    if (!_dnaCache.containsKey(id)) return 0;
    final char = _dnaCache[id]!;
    final historyAvg = _history.isEmpty ? 0 : _history.reduce((a, b) => a + b) / _history.length;
    return 100 - (historyAvg * 80).clamp(0.0, 80.0);
  }
}

class Vector {
  final double face;
  final double wardrobe;
  final double location;
  final double voice;

  Vector({required this.face, required this.wardrobe, required this.location, required this.voice});

  Vector operator -(Vector other) => Vector(
        face: face - other.face,
        wardrobe: wardrobe - other.wardrobe,
        location: location - other.location,
        voice: voice - other.voice,
      );

  double get magnitude => (face.abs() + wardrobe.abs() + location.abs() + voice.abs()) / 4;

  factory Vector.fromJson(Map<String, dynamic> json) {
    return Vector(
      face: json['face'] as double,
      wardrobe: json['wardrobe'] as double,
      location: json['location'] as double,
      voice: json['voice'] as double,
    );
  }
}

final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());