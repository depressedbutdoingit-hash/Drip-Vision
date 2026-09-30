import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

/// Low-level FFmpeg editing operations used by the Edit Bay.
class VideoEditService {
  Future<String> _outPath(String tag) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/edit_${tag}_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  Future<void> _run(String cmd, String label) async {
    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getLogs();
      throw Exception('$label failed: ${logs.map((l) => l.getMessage()).join()}');
    }
  }

  /// Trim video between [startSec] and [endSec] (seconds).
  Future<String> trim({
    required String inputPath,
    required double startSec,
    required double endSec,
  }) async {
    final output = await _outPath('trim');
    final duration = (endSec - startSec).clamp(0.1, 3600.0);
    await _run(
      '-ss $startSec -i "$inputPath" -t $duration -c:v libx264 -c:a aac -movflags +faststart "$output"',
      'Trim',
    );
    return output;
  }

  /// Center-crop to a target aspect ratio then scale.
  Future<String> crop({
    required String inputPath,
    required String aspectRatio,
  }) async {
    final output = await _outPath('crop');
    final filter = switch (aspectRatio) {
      '9:16' => 'crop=ih*9/16:ih,scale=1080:1920',
      '1:1' => 'crop=ih:ih,scale=1080:1080',
      '4:5' => 'crop=ih*4/5:ih,scale=1080:1350',
      '2.39:1' => 'crop=iw:iw/2.39,scale=1920:804',
      _ => 'scale=1920:1080',
    };
    await _run(
      '-i "$inputPath" -vf "$filter" -c:a aac -movflags +faststart "$output"',
      'Crop',
    );
    return output;
  }

  /// Apply a named cinematic filter preset.
  Future<String> applyFilter({
    required String inputPath,
    required String filterId,
  }) async {
    final output = await _outPath('filter');
    final vf = switch (filterId) {
      'cinematic' || 'dripCinema' =>
        'eq=contrast=1.15:brightness=-0.03:saturation=0.9,curves=preset=darker',
      'teal_orange' || 'neonNight' =>
        'colorbalance=rs=.1:gs=-.05:bs=-.15:rm=.05:bm=-.1,eq=saturation=1.2',
      'noir' => 'hue=s=0,eq=contrast=1.3:brightness=-0.05',
      'vivid' => 'eq=contrast=1.2:saturation=1.4:brightness=0.02',
      'vintage' || 'film35mm' =>
        'eq=saturation=0.7:contrast=1.1,colorbalance=rs=.08:bs=-.05,noise=alls=8:allf=t',
      'cool' => 'colorbalance=bs=.12:rs=-.05,eq=saturation=0.95',
      'warm' || 'bleach' => 'colorbalance=rs=.12:bs=-.08,eq=saturation=1.05',
      'grain' || 'vhs' => 'noise=alls=12:allf=t,eq=contrast=1.05',
      'horror' => 'eq=contrast=1.35:brightness=-0.08:saturation=0.55,colorbalance=bs=.08',
      'dream' || 'pastelHorror' =>
        'eq=saturation=0.85:contrast=0.95:brightness=0.04,gblur=sigma=0.6',
      'plasticFantasy' =>
        'eq=saturation=1.35:contrast=1.1,colorbalance=rs=.05:bs=.05',
      _ => 'null',
    };
    await _run(
      '-i "$inputPath" -vf "$vf" -c:a aac -movflags +faststart "$output"',
      'Filter',
    );
    return output;
  }

  /// Apply basic color adjustments (values roughly -1..1).
  Future<String> adjust({
    required String inputPath,
    double brightness = 0,
    double contrast = 0,
    double saturation = 0,
    double warmth = 0,
  }) async {
    final output = await _outPath('adjust');
    final b = brightness.clamp(-1.0, 1.0);
    final c = (1 + contrast).clamp(0.2, 2.5);
    final s = (1 + saturation).clamp(0.0, 3.0);
    final rs = warmth * 0.12;
    final bs = -warmth * 0.1;
    final vf =
        'eq=brightness=$b:contrast=$c:saturation=$s,colorbalance=rs=$rs:bs=$bs';
    await _run(
      '-i "$inputPath" -vf "$vf" -c:a aac -movflags +faststart "$output"',
      'Adjust',
    );
    return output;
  }
}
