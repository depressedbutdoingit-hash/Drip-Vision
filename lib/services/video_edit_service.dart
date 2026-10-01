import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

/// Low-level FFmpeg ops for Edit Bay. Uses codec fallbacks so devices
/// without libx264 still complete trim/crop/filter.
class VideoEditService {
  Future<String> _outPath(String tag) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/edit_${tag}_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  /// Runs FFmpeg; tries alternate video codecs if the first fails.
  Future<void> _runVariants(List<String> commands, String label) async {
    String? lastHint;
    for (final cmd in commands) {
      final session = await FFmpegKit.execute(cmd);
      final code = await session.getReturnCode();
      if (ReturnCode.isSuccess(code)) return;
      final logs = await session.getLogs();
      final text = logs.map((l) => l.getMessage()).join(' ');
      lastHint = _shortHint(text);
    }
    throw Exception(lastHint ?? '$label failed');
  }

  String _shortHint(String logs) {
    final lower = logs.toLowerCase();
    if (lower.contains('no such file') || lower.contains('does not exist')) {
      return 'Video file missing — re-import the clip';
    }
    if (lower.contains('unknown encoder') || lower.contains('libx264')) {
      return 'Encoder not available on this device';
    }
    if (lower.contains('invalid') && lower.contains('filter')) {
      return 'Filter not supported on this file';
    }
    if (logs.trim().isEmpty) return 'Video processing failed';
    // Never dump full FFmpeg log into the UI
    final lines = logs
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (lines.isEmpty) return 'Video processing failed';
    final line = lines.last;
    return line.length > 80 ? '${line.substring(0, 80)}…' : line;
  }

  Future<String> trim({
    required String inputPath,
    required double startSec,
    required double endSec,
  }) async {
    if (!await File(inputPath).exists()) {
      throw Exception('Video file missing — re-import the clip');
    }
    final output = await _outPath('trim');
    final duration = (endSec - startSec).clamp(0.1, 3600.0);
    final start = startSec.clamp(0, 36000);
    await _runVariants([
      '-y -ss $start -i "$inputPath" -t $duration -c:v libx264 -preset ultrafast -c:a aac -movflags +faststart "$output"',
      '-y -ss $start -i "$inputPath" -t $duration -c:v mpeg4 -q:v 5 -c:a aac -movflags +faststart "$output"',
      '-y -ss $start -i "$inputPath" -t $duration -c copy -movflags +faststart "$output"',
    ], 'Trim');
    return output;
  }

  Future<String> crop({
    required String inputPath,
    required String aspectRatio,
  }) async {
    if (!await File(inputPath).exists()) {
      throw Exception('Video file missing — re-import the clip');
    }
    final output = await _outPath('crop');
    final filter = switch (aspectRatio) {
      '9:16' => 'crop=ih*9/16:ih,scale=720:1280',
      '1:1' => 'crop=ih:ih,scale=720:720',
      '4:5' => 'crop=ih*4/5:ih,scale=720:900',
      '2.39:1' => 'crop=iw:iw/2.39,scale=1280:536',
      _ => 'scale=1280:720',
    };
    await _runVariants([
      '-y -i "$inputPath" -vf "$filter" -c:v libx264 -preset ultrafast -c:a aac -movflags +faststart "$output"',
      '-y -i "$inputPath" -vf "$filter" -c:v mpeg4 -q:v 5 -c:a aac -movflags +faststart "$output"',
    ], 'Crop');
    return output;
  }

  Future<String> applyFilter({
    required String inputPath,
    required String filterId,
  }) async {
    if (!await File(inputPath).exists()) {
      throw Exception('Video file missing — re-import the clip');
    }
    final output = await _outPath('filter');
    final vf = _filterVf(filterId);
    if (vf == 'null') {
      return inputPath;
    }
    await _runVariants([
      '-y -i "$inputPath" -vf "$vf" -c:v libx264 -preset ultrafast -c:a aac -movflags +faststart "$output"',
      '-y -i "$inputPath" -vf "$vf" -c:v mpeg4 -q:v 5 -c:a aac -movflags +faststart "$output"',
    ], 'Filter');
    return output;
  }

  Future<String> adjust({
    required String inputPath,
    double brightness = 0,
    double contrast = 0,
    double saturation = 0,
    double warmth = 0,
  }) async {
    if (!await File(inputPath).exists()) {
      throw Exception('Video file missing — re-import the clip');
    }
    final output = await _outPath('adjust');
    final b = brightness.clamp(-1.0, 1.0);
    final c = (1 + contrast).clamp(0.2, 2.5);
    final s = (1 + saturation).clamp(0.0, 3.0);
    final rs = warmth * 0.12;
    final bs = -warmth * 0.1;
    final vf =
        'eq=brightness=$b:contrast=$c:saturation=$s,colorbalance=rs=$rs:bs=$bs';
    await _runVariants([
      '-y -i "$inputPath" -vf "$vf" -c:v libx264 -preset ultrafast -c:a aac -movflags +faststart "$output"',
      '-y -i "$inputPath" -vf "$vf" -c:v mpeg4 -q:v 5 -c:a aac -movflags +faststart "$output"',
    ], 'Color');
    return output;
  }

  static String _filterVf(String filterId) {
    return switch (filterId) {
      'cinematic' || 'dripCinema' =>
        'eq=contrast=1.15:brightness=-0.03:saturation=0.9',
      'teal_orange' || 'neonNight' =>
        'eq=saturation=1.15:contrast=1.05,colorbalance=rs=0.08:bs=-0.1',
      'noir' => 'hue=s=0,eq=contrast=1.25:brightness=-0.04',
      'vivid' => 'eq=contrast=1.15:saturation=1.35:brightness=0.02',
      'vintage' || 'film35mm' =>
        'eq=saturation=0.75:contrast=1.08:brightness=-0.02',
      'cool' => 'colorbalance=bs=0.1:rs=-0.04,eq=saturation=0.95',
      'warm' || 'bleach' => 'colorbalance=rs=0.1:bs=-0.06,eq=saturation=1.05',
      'grain' || 'vhs' => 'noise=alls=10:allf=t,eq=contrast=1.05',
      'horror' => 'eq=contrast=1.3:brightness=-0.06:saturation=0.6',
      'dream' || 'pastelHorror' =>
        'eq=saturation=0.9:contrast=0.95:brightness=0.03',
      'plasticFantasy' => 'eq=saturation=1.25:contrast=1.08',
      _ => 'null',
    };
  }
}
