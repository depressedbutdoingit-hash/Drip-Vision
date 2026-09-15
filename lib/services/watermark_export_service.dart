import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkExportService {
  static Future<String> processExport({
    required String rawVideoPath,
    required bool isPaidUser,
  }) async {
    if (isPaidUser) return rawVideoPath;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/drip_export_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final cmd = '-i "$rawVideoPath" -i "assets/images/dripvision_watermark.png" '
        "-filter_complex \"[1][0]scale2ref=w='iw*0.2':h='ow/mdar'[wm][vid];[vid][wm]overlay=main_w-overlay_w-20:main_h-overlay_h-20:format=auto\" "
        '-c:a copy -movflags +faststart "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) return outputPath;

    final logs = await session.getLogs();
    throw Exception('Watermark failed: ${logs.map((l) => l.getMessage()).join()}');
  }
}
