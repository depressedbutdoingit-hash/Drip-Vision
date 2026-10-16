final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());
final universeProvider = StateProvider((ref) => UniverseData(healthScore: 100, characters: []));