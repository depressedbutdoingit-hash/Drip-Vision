import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratedScene {
  final String id;
  final String title;
  final String prompt;
  final String? videoUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final String mode;

  GeneratedScene({
    required this.id,
    required this.title,
    required this.prompt,
    this.videoUrl,
    this.imageUrl,
    required this.createdAt,
    this.mode = 'Realistic',
  });
}

class GenerationHistory extends StateNotifier<List<GeneratedScene>> {
  GenerationHistory() : super(const []);

  void add(GeneratedScene scene) {
    state = [scene, ...state];
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void clear() => state = const [];
}

final generationHistoryProvider =
    StateNotifierProvider<GenerationHistory, List<GeneratedScene>>(
  (ref) => GenerationHistory(),
);
