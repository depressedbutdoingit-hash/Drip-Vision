class AIGenerationService {
  Future<String> generateVideo({
    required String prompt,
    required String cameraMotion,
  }) async {
    // Stub: replace with actual FAL AI / video generation integration
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/generated_video.mp4';
  }
}

final aiGenerationServiceProvider = Provider((ref) => AIGenerationService());
