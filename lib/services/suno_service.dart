import 'package:dio/dio.dart';
import '../core/env.dart';

/// Thin integration boundary for the existing music studio.
/// The endpoint is configurable so the production backend can remain the
/// source of truth without coupling the UI to a mock implementation.
class SunoTrack {
  final String id;
  final String title;
  final String audioUrl;
  final String genre;
  final int durationSeconds;
  const SunoTrack({required this.id, required this.title, required this.audioUrl, required this.genre, required this.durationSeconds});

  factory SunoTrack.fromJson(Map<String, dynamic> json) => SunoTrack(
    id: '${json['id'] ?? json['audio_id'] ?? ''}',
    title: '${json['title'] ?? 'Untitled score'}',
    audioUrl: '${json['audio_url'] ?? json['audioUrl'] ?? json['source_audio_url'] ?? ''}',
    genre: '${json['genre'] ?? json['style'] ?? 'Cinematic'}',
    durationSeconds: int.tryParse('${json['duration_seconds'] ?? json['durationSeconds'] ?? 0}') ?? 0,
  );
}

class SunoService {
  final String apiKey;
  final Dio _dio;
  SunoService(this.apiKey, {Dio? dio}) : _dio = dio ?? Dio();

  Future<SunoTrack> generateForScene({required String sceneDescription, required String sceneMood, required String lighting, required int duration}) async {
    if (apiKey.isEmpty) throw StateError('SUNO_API_KEY is not configured.');
    final baseUrl = const String.fromEnvironment('SUNO_API_BASE_URL', defaultValue: 'https://api.sunoapi.org');
    final response = await _dio.post('$baseUrl/api/v1/generate', data: {
      'prompt': sceneDescription,
      'style': sceneMood,
      'title': 'DripVision Score',
      'duration': duration,
      if (lighting.isNotEmpty) 'metadata': {'lighting': lighting},
    }, options: Options(headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'}));
    final data = response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : <String, dynamic>{};
    final payload = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
    return SunoTrack.fromJson(payload);
  }
}
