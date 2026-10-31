import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneratedScene {
  final String id;
  final String title;
  final String prompt;
  final String? videoUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final String mode;
  final bool isPublic;

  GeneratedScene({
    required this.id,
    required this.title,
    required this.prompt,
    this.videoUrl,
    this.imageUrl,
    required this.createdAt,
    this.mode = 'Realistic',
    this.isPublic = false,
  });

  GeneratedScene copyWith({bool? isPublic}) => GeneratedScene(
        id: id,
        title: title,
        prompt: prompt,
        videoUrl: videoUrl,
        imageUrl: imageUrl,
        createdAt: createdAt,
        mode: mode,
        isPublic: isPublic ?? this.isPublic,
      );
}

class GenerationHistory extends StateNotifier<List<GeneratedScene>> {
  GenerationHistory() : super(const []);

  void add(GeneratedScene scene) {
    state = [scene, ...state];
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void setPublic(String id, bool isPublic) {
    state = [for (final s in state) if (s.id == id) s.copyWith(isPublic: isPublic) else s];
  }

  void clear() => state = const [];
}

final generationHistoryProvider =
    StateNotifierProvider<GenerationHistory, List<GeneratedScene>>(
  (ref) => GenerationHistory(),
);

final profilePublicProvider = StateProvider<bool>((ref) => false);
