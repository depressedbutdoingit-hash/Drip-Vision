import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class VideoStitchingService {
  Future<String> concatenateScenes(List<String> videoPaths) async {
    if (videoPaths.isEmpty) throw ArgumentError('No videos to stitch');
    if (videoPaths.length == 1) return videoPaths.first;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/master_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final concatFile = File('${tempDir.path}/concat_${DateTime.now().millisecondsSinceEpoch}.txt');

    final lines = videoPaths.map((p) => "file '${p.replaceAll("'", r"'\''")}'").join('\n');
    await concatFile.writeAsString(lines);

    final command = '-f concat -safe 0 -i "${concatFile.path}" -c copy -movflags +faststart "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (await concatFile.exists()) await concatFile.delete();

    if (ReturnCode.isSuccess(returnCode)) return outputPath;
    final logs = await session.getLogs();
    throw Exception('Stitch failed: ${logs.map((l) => l.getMessage()).join()}');
  }

  Future<String> mixAudio({
    required String videoPath,
    required String audioPath,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/mixed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final command = '-i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -shortest "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) return outputPath;
    throw Exception('Audio mix failed');
  }

  /// Reframes a cut for a target aspect ratio (EXPORT presets: 16:9 cinema,
  /// 9:16 vertical, 1:1 square). Real ffmpeg crop+scale, not a UI-only
  /// selector — a 16:9 source becomes a center-cropped, scaled 9:16 file.
  Future<String> reframe(String videoPath, {required String aspectRatio}) async {
    if (aspectRatio == '16:9') return videoPath;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/reframed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final filter = aspectRatio == '9:16'
        ? 'crop=ih*9/16:ih,scale=1080:1920'
        : 'crop=ih:ih,scale=1080:1080'; // 1:1

    final command = '-i "$videoPath" -vf "$filter" -c:a copy -movflags +faststart "$outputPath"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) return outputPath;
    final logs = await session.getLogs();
    throw Exception('Reframe failed: ${logs.map((l) => l.getMessage()).join()}');
  }
}
