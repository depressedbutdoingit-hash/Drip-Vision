import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/universe.dart';
import 'services/continuity_service.dart';
import 'models/character.dart';

final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());
final universeProvider = StateProvider((ref) => Universe(healthScore: 100, characters: []));
final continuityHealthProvider = StateProvider((ref) => ContinuityHealth(score: 0, message: '', color: Colors.red));