import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';

/// Voice generation and stateless voice cloning via OpenRouter's /audio/speech endpoint.
/// Uses only OPENROUTER_KEY. No separate ElevenLabs account required.
class VoiceCloningService {
  final Dio _dio;

  VoiceCloningService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://openrouter.ai/api/v1/',
              headers: {
                'Authorization': 'Bearer ${Env.openRouterKey}',
                'HTTP-Referer': 'https://dripvision.app',
                'X-Title': 'DripVision',
                'Content-Type': 'application/json',
              },
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 2),
            ));

  /// Generate speech from text using a built-in voice.
  /// Returns raw audio bytes (mp3 by default).
  Future<Uint8List> generateSpeech({
    required String text,
    String model = 'google/gemini-3.8-flash-tts',
    String voice = 'en_paul_neutral',
    String responseFormat = 'mp3',
    double? speed,
    String? instructions,
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing. Add it to your .env file.');
    }

    final payload = <String, dynamic>{
      'model': model,
      'input': text,
      'voice': voice,
      'response_format': responseFormat,
      if (speed != null) 'speed': speed,
      if (instructions != null) 'instructions': instructions,
    };

    final response = await _dio.post(
      'audio/speech',
      data: payload,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data as List<int>);
  }

  /// Stateless voice cloning: generate speech that mimics a short reference sample.
  /// The sample is sent as base64 in input_references. No persistent voice is created.
  /// Works with models that support voice cloning (e.g. Fish Audio, some Gemini/Mistral).
  Future<Uint8List> cloneAndSpeak({
    required String text,
    required File referenceAudio,
    String model = 'fish-audio/s2.1-pro',
    String responseFormat = 'mp3',
    String? transcript,
    String? instructions,
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw Exception('OPENROUTER_KEY is missing. Add it to your .env file.');
    }

    final bytes = await referenceAudio.readAsBytes();
    final base64Audio = base64Encode(bytes);
    final dataUri = 'data:audio/wav;base64,$base64Audio';

    final references = <Map<String, dynamic>>[
      {
        'type': 'input_audio',
        'input_audio': {'data': dataUri},
      },
      if (transcript != null)
        {
          'type': 'text',
          'text': transcript,
        },
    ];

    final payload = <String, dynamic>{
      'model': model,
      'input': text,
      'response_format': responseFormat,
      'input_references': references,
      if (instructions != null) 'instructions': instructions,
    };

    final response = await _dio.post(
      'audio/speech',
      data: payload,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data as List<int>);
  }
}

final voiceCloningServiceProvider = Provider<VoiceCloningService>((ref) {
  return VoiceCloningService();
});
