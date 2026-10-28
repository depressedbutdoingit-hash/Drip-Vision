import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/scene.dart';

final sceneListProvider = StateProvider<List<SceneNode>>((ref) => []);
final characterListProvider = StateProvider<List<Character>>((ref) => []);
final userProfileProvider = StateProvider<dynamic>((ref) => null);
final navIndexProvider = StateProvider<int>((ref) => 0);
final activeCharacterProvider = StateProvider<dynamic>((ref) => null);
final universeProvider = StateProvider<dynamic>((ref) => null);
final filmBibleProvider = StateProvider<dynamic>((ref) => null);
final pendingScenePromptProvider = StateProvider<String>((ref) => '');
final styleListProvider = StateProvider<List<dynamic>>((ref) => []);
final activeStyleProvider = StateProvider<dynamic>((ref) => null);
final musicPlayerProvider = StateProvider<dynamic>((ref) => null);
