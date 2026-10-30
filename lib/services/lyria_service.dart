import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/env.dart';

class LyriaTrack {
  final String id;
  final String title;
  final String audioUrl; // local file path
  final String genre;
  final int durationSeconds;
  const LyriaTrack({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.genre,
    required this.durationSeconds,
  });
}

class LyriaService {
  final String apiKey;
  final Dio _dio;

  LyriaService(this.apiKey, {Dio? dio}) : _dio = dio ?? Dio();

  Future<LyriaTrack> generateScore({
    required String prompt,
    String style = 'cinematic',
    int durationSeconds = 60,
  }) async {
    if (apiKey.isEmpty) {
      throw StateError('OPENROUTER_KEY is not configured.');
    }

    final fullPrompt = [
      prompt,
      'Style: $style',
      'Target length: about $durationSeconds seconds',
      'Instrumental cinematic score, high quality, stereo.',
    ].join('\n');

    final response = await _dio.post(
      'https://openrouter.ai/api/v1/chat/completions',
      data: {
        'model': 'google/lyria-3-pro-preview',
        'messages': [
          {'role': 'user', 'content': fullPrompt},
        ],
        'modalities': ['text', 'audio'],
        'audio': {'format': 'mp3'},
        'stream': true,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://dripvision.app',
          'X-Title': 'DripVision',
        },
        responseType: ResponseType.stream,
      ),
    );

    final audioChunks = <String>[];
    final stream = response.data.stream as Stream<List<int>>;

    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]' || data.isEmpty) continue;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices.first['delta'] as Map?;
          final audio = delta?['audio'] as Map?;
          final b64 = audio?['data'] as String?;
          if (b64 != null && b64.isNotEmpty) {
            audioChunks.add(b64);
          }
        } catch (_) {}
      }
    }

    if (audioChunks.isEmpty) {
      throw StateError('Lyria returned no audio data.');
    }

    final bytes = base64Decode(audioChunks.join());
    final dir = await getTemporaryDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File('${dir.path}/lyria_$id.mp3');
    await file.writeAsBytes(bytes);

    return LyriaTrack(
      id: id,
      title: 'Lyria Score',
      audioUrl: file.path,
      genre: style,
      durationSeconds: durationSeconds,
    );
  }
}
