class VideoGenerationMetadata {
  final String generationId;
  final String sceneId;
  final DateTime timestamp;
  final String provider; // kling, runway, luma, sora, pika, comfyui
  final String model;
  final String promptFinal;
  final String? negativePrompt;
  final List<String> characterRefsUsed;
  final int? seed;
  final double duration;
  final String resolution;
  final double costCredits;
  final double? continuityScorePost;
  final String? videoUrlOrPath;
  final bool approvedByUser;
  final String? notes;

  const VideoGenerationMetadata({
    required this.generationId,
    required this.sceneId,
    required this.timestamp,
    required this.provider,
    required this.model,
    required this.promptFinal,
    this.negativePrompt,
    this.characterRefsUsed = const [],
    this.seed,
    this.duration = 0.0,
    this.resolution = '1080p',
    this.costCredits = 0.0,
    this.continuityScorePost,
    this.videoUrlOrPath,
    this.approvedByUser = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'generationId': generationId,
        'sceneId': sceneId,
        'timestamp': timestamp.toIso8601String(),
        'provider': provider,
        'model': model,
        'promptFinal': promptFinal,
        'negativePrompt': negativePrompt,
        'characterRefsUsed': characterRefsUsed,
        'seed': seed,
        'duration': duration,
        'resolution': resolution,
        'costCredits': costCredits,
        'continuityScorePost': continuityScorePost,
        'videoUrlOrPath': videoUrlOrPath,
        'approvedByUser': approvedByUser,
        'notes': notes,
      };

  factory VideoGenerationMetadata.fromJson(Map<String, dynamic> json) =>
      VideoGenerationMetadata(
        generationId: json['generationId'] ?? '',
        sceneId: json['sceneId'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        provider: json['provider'] ?? '',
        model: json['model'] ?? '',
        promptFinal: json['promptFinal'] ?? '',
        negativePrompt: json['negativePrompt'],
        characterRefsUsed: List<String>.from(json['characterRefsUsed'] ?? const []),
        seed: json['seed'],
        duration: (json['duration'] ?? 0.0).toDouble(),
        resolution: json['resolution'] ?? '1080p',
        costCredits: (json['costCredits'] ?? 0.0).toDouble(),
        continuityScorePost: json['continuityScorePost']?.toDouble(),
        videoUrlOrPath: json['videoUrlOrPath'],
        approvedByUser: json['approvedByUser'] ?? false,
        notes: json['notes'],
      );
}
