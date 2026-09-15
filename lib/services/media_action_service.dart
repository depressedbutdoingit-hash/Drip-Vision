import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MediaActionService {
  final Dio _dio;
  MediaActionService({Dio? dio}) : _dio = dio ?? Dio();

  Future<bool> downloadVideoToGallery(
    String videoUrl, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/drip_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _dio.download(videoUrl, path, onReceiveProgress: onProgress);
      await Gal.putVideo(path);

      final file = File(path);
      if (await file.exists()) await file.delete();

      return true;
    } catch (e, st) {
      debugPrint('Download error: $e\n$st');
      return false;
    }
  }

  Future<void> shareVideoToApps(String videoUrl, String promptText) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _dio.download(videoUrl, path);
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Created with #DripVision AI!\nPrompt: "$promptText"',
      );

      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e, st) {
      debugPrint('Share error: $e\n$st');
    }
  }
}
