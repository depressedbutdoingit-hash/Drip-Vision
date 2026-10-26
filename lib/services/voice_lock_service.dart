import 'dart:io';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../core/env.dart';

/// Voice Lock System — Clone a user's voice for character dialogue.
/// 
/// Flow:
/// 1. User records 30 seconds of their voice reading a script
/// 2. Audio is sent to ElevenLabs Voice API to create a voice clone
/// 3. Voice ID is stored in CharacterDNA.voice.elevenLabsVoiceId
/// 4. Character speaks dialogue using the cloned voice
class VoiceLockService {
  final AudioRecorder _recorder = AudioRecorder();
  final Dio _dio = Dio();

  /// Check microphone permission and start recording.
  Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_sample.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    return true;
  }

  /// Stop recording and return the file path.
  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  /// Upload sample to ElevenLabs and return the voice ID.
  /// POST https://api.elevenlabs.io/v1/voices/add
  Future<String?> cloneVoice({
    required String audioPath,
    required String voiceName,
    required String description,
  }) async {
    if (Env.elevenLabsKey.isEmpty) {
      throw Exception('ELEVENLABS_KEY is missing. Add it to your .env file.');
    }

    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio sample file not found: $audioPath');
    }

    final formData = FormData.fromMap({
      'name': voiceName,
      'description': description,
      'files': await MultipartFile.fromFile(audioPath, filename: 'voice_sample.m4a'),
    });

    final response = await _dio.post(
      'https://api.elevenlabs.io/v1/voices/add',
      data: formData,
      options: Options(
        headers: {'xi-api-key': Env.elevenLabsKey},
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      return data['voice_id'] as String?;
    }
    throw Exception('ElevenLabs voice clone failed: ${response.statusCode} ${response.data}');
  }

  /// Generate speech using the cloned voice.
  /// POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}
  Future<String?> generateSpeech({
    required String voiceId,
    required String text,
    required double stability,
    required double similarityBoost,
  }) async {
    if (Env.elevenLabsKey.isEmpty) {
      throw Exception('ELEVENLABS_KEY is missing. Add it to your .env file.');
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath = '\( {tempDir.path}/tts_ \){DateTime.now().millisecondsSinceEpoch}.mp3';

    final response = await _dio.post(
      'https://api.elevenlabs.io/v1/text-to-speech/$voiceId',
      data: {
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': stability,
          'similarity_boost': similarityBoost,
        },
      },
      options: Options(
        headers: {'xi-api-key': Env.elevenLabsKey},
        responseType: ResponseType.bytes,
      ),
    );

    if (response.statusCode == 200) {
      await File(outputPath).writeAsBytes(response.data);
      return outputPath;
    }
    throw Exception('ElevenLabs TTS failed: ${response.statusCode}');
  }

  /// Full pipeline: record → clone → attach to character.
  Future<VoiceCloneResult> fullVoiceLockPipeline({
    required String characterName,
    required String recordingPath,
  }) async {
    final voiceId = await cloneVoice(
      audioPath: recordingPath,
      voiceName: '$characterName Voice',
      description: 'Cloned voice for $characterName in DripVision films',
    );

    if (voiceId == null) {
      return VoiceCloneResult(voiceId: null, previewUrl: null);
    }

    final previewUrl = await generateSpeech(
      voiceId: voiceId,
      text: 'Hello, I am $characterName. Welcome to my story.',
      stability: 0.5,
      similarityBoost: 0.75,
    );

    return VoiceCloneResult(voiceId: voiceId, previewUrl: previewUrl);
  }

  void dispose() {
    _recorder.dispose();
  }
}

class VoiceCloneResult {
  final String? voiceId;
  final String? previewUrl;

  VoiceCloneResult({this.voiceId, this.previewUrl});
}