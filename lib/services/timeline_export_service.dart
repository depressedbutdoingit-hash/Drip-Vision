import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/edit_project.dart';
import 'video_stitching_service.dart';

/// Exports an [EditProject] timeline to a single MP4.
/// Uses V1 video clips ordered by timeline start; downloads remote media;
/// applies per-clip in/out trims when needed; concatenates; optional reframe.
class TimelineExportService {
  final _stitch = VideoStitchingService();

  Future<String> exportProject(
    EditProject project, {
    void Function(String stage)? onStage,
  }) async {
    final clips = project.clips
        .where((c) =>
            c.trackId.startsWith('v') &&
            c.mediaUrl != null &&
            c.mediaUrl!.isNotEmpty)
        .toList()
      ..sort((a, b) => a.startOnTimeline.compareTo(b.startOnTimeline));

    if (clips.isEmpty) {
      throw Exception('No video clips with media on the timeline to export.');
    }

    onStage?.call('Preparing ${clips.length} clip${clips.length == 1 ? '' : 's'}…');
    final tempDir = await getTemporaryDirectory();
    final prepared = <String>[];

    for (var i = 0; i < clips.length; i++) {
      final clip = clips[i];
      onStage?.call('Clip ${i + 1}/${clips.length}: load');
      final local = await _ensureLocal(clip.mediaUrl!, tempDir);

      onStage?.call('Clip ${i + 1}/${clips.length}: trim');
      final trimmed = await _trimIfNeeded(local, clip, tempDir);
      prepared.add(trimmed);
    }

    onStage?.call('Stitching cut…');
    String master = prepared.length == 1
        ? prepared.first
        : await _stitch.concatenateScenes(prepared);

    final ratio = project.aspectRatio.label;
    if (ratio != '16:9') {
      onStage?.call('Reframe $ratio…');
      final aspect = ratio == '2.39:1' ? '16:9' : ratio; // stitch service presets
      if (ratio == '2.39:1') {
        master = await _letterboxCinema(master, tempDir);
      } else {
        master = await _stitch.reframe(master, aspectRatio: aspect);
      }
    }

    onStage?.call('Finalizing…');
    final out =
        '${tempDir.path}/dripvision_cut_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await File(master).copy(out);
    return out;
  }

  Future<String> _ensureLocal(String pathOrUrl, Directory tempDir) async {
    if (!pathOrUrl.startsWith('http')) {
      if (!await File(pathOrUrl).exists()) {
        throw Exception('Missing media file: $pathOrUrl');
      }
      return pathOrUrl;
    }
    final dest =
        '${tempDir.path}/src_${pathOrUrl.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final res = await http.get(Uri.parse(pathOrUrl));
    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }
    await File(dest).writeAsBytes(res.bodyBytes);
    return dest;
  }

  Future<String> _trimIfNeeded(
    String input,
    EditClip clip,
    Directory tempDir,
  ) async {
    // If full clip with no meaningful trim window, skip re-encode
    final needsTrim = clip.inPoint > 0.05 ||
        (clip.outPoint > 0 && clip.outPoint > clip.inPoint + 0.05);
    if (!needsTrim && clip.duration <= 0) return input;

    final start = clip.inPoint.clamp(0, 36000);
    final dur = clip.duration > 0.1
        ? clip.duration
        : (clip.outPoint > clip.inPoint
            ? clip.outPoint - clip.inPoint
            : 4.0);

    final output =
        '${tempDir.path}/trim_${clip.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final cmd =
        '-ss $start -i "$input" -t $dur -c:v libx264 -c:a aac -movflags +faststart "$output"';
    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      final logs = await session.getLogs();
      throw Exception(
        'Trim failed for ${clip.label}: ${logs.map((l) => l.getMessage()).join()}',
      );
    }
    return output;
  }

  Future<String> _letterboxCinema(String input, Directory tempDir) async {
    final output =
        '${tempDir.path}/scope_${DateTime.now().millisecondsSinceEpoch}.mp4';
    // 2.39:1 inside 1920x1080 with black bars
    final cmd =
        '-i "$input" -vf "scale=1920:804:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" -c:a aac -movflags +faststart "$output"';
    final session = await FFmpegKit.execute(cmd);
    final code = await session.getReturnCode();
    if (!ReturnCode.isSuccess(code)) {
      throw Exception('Cinema letterbox failed');
    }
    return output;
  }
}
