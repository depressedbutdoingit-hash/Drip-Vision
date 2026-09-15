import 'dart:io';
import 'package:dio/dio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../core/env.dart';

class WhisperService {
  final _audioRecorder = AudioRecorder();
  final _dio = Dio();

  Future<bool> hasPermission() => _audioRecorder.hasPermission();

  Future<String> startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/prompt_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(const RecordConfig(), path: path);
    return path;
  }

  Future<String?> stopRecording() => _audioRecorder.stop();

  Future<String> transcribe(String filePath) async {
    final file = File(filePath);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'audio.m4a'),
      'model': 'whisper-1',
    });

    final response = await _dio.post(
      'https://api.openai.com/v1/audio/transcriptions',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer ${Env.openAiKey}'},
      ),
    );

    if (await file.exists()) await file.delete();
    return response.data['text'] as String;
  }

  void dispose() => _audioRecorder.dispose();
}
