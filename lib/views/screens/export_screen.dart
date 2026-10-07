import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/scene.dart';
import '../../services/watermark_export_service.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import '../widgets/studio_empty.dart';
import '../widgets/drip_button.dart';

enum _ExportMode { fullCut, trailer }

/// EXPORT / TRAILER
/// Runs the real pipeline: download each scene's rendered video, stitch
/// via VideoStitchingService (ffmpeg concat — now actually valid ffmpeg
/// commands, see the fix to that file), reframe for the chosen aspect
/// ratio, then watermark based on the user's real Pro status.
///
/// Honest scope note: "Trailer" here means exporting a shorter cut from
/// scenes *you* pick, not AI-selected "best shots" — that curation model
/// doesn't exist in this codebase yet, so this doesn't pretend to do it.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  _ExportMode _mode = _ExportMode.fullCut;
  String _aspectRatio = '16:9';
  Set<String> _selected = {};
  bool _exporting = false;
  String? _stage;
  String? _resultPath;

  @override
  Widget build(BuildContext context) {
    final scenes = ref.watch(sceneListProvider).where((s) => s.outputVideoUrl != null).toList();
    if (_selected.isEmpty && scenes.isNotEmpty) {
      _selected = scenes.map((s) => s.id).toSet();
    }
    final isPro = ref.watch(userProfileProvider).value?.isPro ?? false;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('EXPORT', style: DripTheme.brandMark)),
      body: SafeArea(
        child: scenes.isEmpty
            ? const StudioEmpty(
                title: 'No master yet',
                subtitle: 'Render at least one shot before export.',
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _modeChip('FULL CUT', _ExportMode.fullCut)),
                        const SizedBox(width: 10),
                        Expanded(child: _modeChip('TRAILER', _ExportMode.trailer)),
                      ],
                    ),
                    const SizedBox(height: 22),

                    const Text('FORMAT', style: DripTheme.overline),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(child: _ratioChip('16:9', '1080 · CINEMA')),
                        const SizedBox(width: 8),
                        Expanded(child: _ratioChip('9:16', 'VERTICAL')),
                        const SizedBox(width: 8),
                        Expanded(child: _ratioChip('1:1', 'SQUARE')),
                      ],
                    ),
                    const SizedBox(height: 22),

                    Text(_mode == _ExportMode.trailer ? 'TRAILER SCENES' : 'EXPORT REEL', style: DripTheme.overline),
                    const SizedBox(height: 9),
                    ...scenes.asMap().entries.map((e) => _sceneRow(e.value, e.key)),
                    const SizedBox(height: 8),
                    Text('${_selected.length} of ${scenes.length} selected  ·  ${isPro ? 'Master · no watermark' : 'Studio watermark on'}', style: DripTheme.meta),
                    const SizedBox(height: 24),

                    if (_exporting)
                      CinematicCard(
                        child: Row(children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_stage ?? 'Working…', style: const TextStyle(color: DripTheme.muted))),
                        ]),
                      )
                    else
                      CinematicButton(
                        label: _mode == _ExportMode.trailer ? 'EXPORT TRAILER' : 'EXPORT',
                        icon: Icons.ios_share,
                        onPressed: _selected.isEmpty ? null : () => _export(scenes, isPro),
                      ),

                    if (_resultPath != null) ...[
                      const SizedBox(height: 14),
                      CinematicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [Icon(Icons.check_circle_outline, color: DripTheme.aquaGlow, size: 16), SizedBox(width: 8), Text('EXPORT READY', style: TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w700, color: DripTheme.aquaGlow))]),
                            const SizedBox(height: 10),
                            CinematicButton(label: 'SHARE', icon: Icons.share_outlined, primary: false, onPressed: () => Share.shareXFiles([XFile(_resultPath!)])),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _modeChip(String label, _ExportMode mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? DripTheme.surfaceLight : DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          border: Border.all(
            color: selected ? DripTheme.cosmicTeal.withOpacity(0.45) : DripTheme.hairline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
            color: selected ? DripTheme.cosmicTeal : DripTheme.chrome,
          ),
        ),
      ),
    );
  }

  Widget _ratioChip(String ratio, String preset) {
    final selected = _aspectRatio == ratio;
    return GestureDetector(
      onTap: () => setState(() => _aspectRatio = ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? DripTheme.surfaceLight : DripTheme.surface,
          borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          border: Border.all(
            color: selected ? DripTheme.cosmicTeal.withOpacity(0.45) : DripTheme.hairline,
          ),
        ),
        child: Column(
          children: [
            Text(
              ratio,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? DripTheme.warmWhite : DripTheme.chrome,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              preset,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, letterSpacing: 0.6, color: DripTheme.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sceneRow(SceneNode s, int i) {
    final checked = _selected.contains(s.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CinematicCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: () => setState(() => checked ? _selected.remove(s.id) : _selected.add(s.id)),
        child: Row(
          children: [
            Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, color: checked ? DripTheme.cosmicTeal : Colors.white24, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('SCENE ${(i + 1).toString().padLeft(2, '0')} · ${s.prompt}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5))),
          ],
        ),
      ),
    );
  }

  Future<void> _export(List<SceneNode> allScenes, bool isPro) async {
    final ordered = allScenes.where((s) => _selected.contains(s.id)).toList();
    if (ordered.isEmpty) return;

    setState(() {
      _exporting = true;
      _resultPath = null;
      _stage = 'Downloading rendered shots…';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final localPaths = <String>[];
      for (var i = 0; i < ordered.length; i++) {
        setState(() => _stage = 'Downloading shot ${i + 1} of ${ordered.length}…');
        final url = ordered[i].outputVideoUrl!;
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) throw Exception('Could not fetch scene ${i + 1}');
        final file = File('${tempDir.path}/dv_scene_${i}_${DateTime.now().millisecondsSinceEpoch}.mp4');
        await file.writeAsBytes(response.bodyBytes);
        localPaths.add(file.path);
      }

      setState(() => _stage = 'Stitching the cut…');
      var output = await ref.read(videoStitchProvider).concatenateScenes(localPaths);

      if (_aspectRatio != '16:9') {
        setState(() => _stage = 'Reframing for $_aspectRatio…');
        output = await ref.read(videoStitchProvider).reframe(output, aspectRatio: _aspectRatio);
      }

      setState(() => _stage = isPro ? 'Finishing master…' : 'Applying watermark…');
      output = await WatermarkExportService.processExport(rawVideoPath: output, isPaidUser: isPro);

      setState(() {
        _resultPath = output;
        _exporting = false;
        _stage = null;
      });
    } catch (e) {
      setState(() {
        _exporting = false;
        _stage = null;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
