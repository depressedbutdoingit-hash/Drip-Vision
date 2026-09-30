import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../models/edit_project.dart';
import '../../services/edit_bay_notifier.dart';
import '../../services/video_edit_service.dart';
import '../widgets/cinematic_button.dart';

/// EDIT BAY — unified NLE + real FFmpeg finishing.
/// Multi-track timeline (project state) + media ops (trim/crop/filter/adjust).
class EditBayScreen extends ConsumerStatefulWidget {
  final String? initialVideoPathOrUrl;
  final bool seedFromScenes;

  const EditBayScreen({
    super.key,
    this.initialVideoPathOrUrl,
    this.seedFromScenes = true,
  });

  @override
  ConsumerState<EditBayScreen> createState() => _EditBayScreenState();
}

class _EditBayScreenState extends ConsumerState<EditBayScreen> {
  final _editor = VideoEditService();
  final _picker = ImagePicker();

  VideoPlayerController? _controller;
  String? _currentPath;
  bool _loading = false;
  String? _status;
  bool _seeded = false;

  // Active media-tool panel (finishing ops on current file)
  String _finishingTool = 'timeline'; // timeline|trim|crop|filters|adjust|memory

  double _duration = 5;
  double _trimStart = 0;
  double _trimEnd = 5;
  String _aspect = '16:9';
  String? _activeFilter;
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _warmth = 0;

  static const _filters = [
    ('none', 'None'),
    ('cinematic', 'Cinema'),
    ('teal_orange', 'Teal & Orange'),
    ('noir', 'Noir'),
    ('vivid', 'Vivid'),
    ('vintage', '35mm'),
    ('cool', 'Cool'),
    ('warm', 'Warm'),
    ('grain', 'Grain'),
    ('horror', 'Horror'),
    ('dream', 'Dream'),
    ('plasticFantasy', 'Plastic'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoPathOrUrl != null) {
      _loadSource(widget.initialVideoPathOrUrl!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadSource(String pathOrUrl) async {
    setState(() {
      _loading = true;
      _status = 'Loading…';
    });
    try {
      var localPath = pathOrUrl;
      if (pathOrUrl.startsWith('http')) {
        final dir = await getTemporaryDirectory();
        localPath =
            '${dir.path}/import_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final res = await http.get(Uri.parse(pathOrUrl));
        if (res.statusCode != 200) {
          throw Exception('Download failed (${res.statusCode})');
        }
        await File(localPath).writeAsBytes(res.bodyBytes);
      }
      await _setController(localPath);
    } catch (e) {
      _toast('Load failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = null;
        });
      }
    }
  }

  Future<void> _setController(String path) async {
    await _controller?.dispose();
    final c = VideoPlayerController.file(File(path));
    await c.initialize();
    final dur = c.value.duration.inMilliseconds / 1000.0;
    setState(() {
      _controller = c;
      _currentPath = path;
      _duration = dur > 0 ? dur : 5;
      _trimStart = 0;
      _trimEnd = _duration;
    });
    c.setLooping(true);
    await c.play();
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) await _loadSource(file.path);
  }

  Future<void> _runEdit(
    Future<String> Function() op,
    String label,
  ) async {
    if (_currentPath == null) return;
    setState(() {
      _loading = true;
      _status = label;
    });
    try {
      final out = await op();
      await _setController(out);
      // Keep selected clip media pointer in NLE state if possible
      final bay = ref.read(editBayProvider);
      final sel = bay.selectedClip;
      if (sel != null) {
        ref.read(editBayProvider.notifier).updateClip(
              sel.copyWith(mediaUrl: out),
            );
      }
      _toast('$label complete');
    } catch (e) {
      _toast('$label failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = null;
        });
      }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: DripTheme.surfaceRaised,
      ),
    );
  }

  Future<void> _share() async {
    if (_currentPath == null) return;
    await Share.shareXFiles([XFile(_currentPath!)], text: 'Edited with #DripVision');
  }

  Future<void> _download() async {
    if (_currentPath == null) return;
    setState(() {
      _loading = true;
      _status = 'Saving…';
    });
    try {
      await Gal.putVideo(_currentPath!);
      _toast('Saved to gallery');
    } catch (e) {
      _toast('Save failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = null;
        });
      }
    }
  }

  Future<void> _loadSelectedClipMedia(EditClip? clip) async {
    if (clip?.mediaUrl == null || clip!.mediaUrl!.isEmpty) return;
    if (clip.mediaUrl == _currentPath) return;
    await _loadSource(clip.mediaUrl!);
  }

  @override
  Widget build(BuildContext context) {
    final bay = ref.watch(editBayProvider);
    final scenes = ref.watch(sceneListProvider);
    final n = ref.read(editBayProvider.notifier);

    if (widget.seedFromScenes &&
        !_seeded &&
        bay.project.clips.isEmpty &&
        scenes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _seeded) return;
        _seeded = true;
        n.loadFromScenes(scenes);
        final first = ref.read(editBayProvider).project.clips;
        if (first.isNotEmpty) {
          n.selectClip(first.first.id);
          _loadSelectedClipMedia(first.first);
        }
      });
    }

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(bay, n),
            Expanded(flex: 5, child: _buildPreview(bay)),
            _buildTransport(bay, n),
            Expanded(flex: 3, child: _buildTimeline(bay, n)),
            _buildToolRail(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
              child: _buildInspector(bay, n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(EditBayState bay, EditBayNotifier n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: DripTheme.chrome),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bay.project.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${bay.project.sequenceName}  ·  ${bay.project.dirty ? 'UNSAVED' : 'SAVED'}',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: bay.project.dirty
                        ? DripTheme.cosmicTeal
                        : DripTheme.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Import',
            onPressed: _loading ? null : _pickFromGallery,
            icon: const Icon(Icons.add_box_outlined, size: 20, color: DripTheme.chrome),
          ),
          IconButton(
            onPressed: bay.undoStack.isEmpty ? null : n.undo,
            icon: Icon(Icons.undo, size: 18,
                color: bay.undoStack.isEmpty ? DripTheme.muted : DripTheme.chrome),
          ),
          IconButton(
            onPressed: bay.redoStack.isEmpty ? null : n.redo,
            icon: Icon(Icons.redo, size: 18,
                color: bay.redoStack.isEmpty ? DripTheme.muted : DripTheme.chrome),
          ),
          if (_currentPath != null) ...[
            IconButton(
              onPressed: _loading ? null : _download,
              icon: const Icon(Icons.download_rounded, size: 20, color: DripTheme.chrome),
            ),
            IconButton(
              onPressed: _loading ? null : _share,
              icon: const Icon(Icons.ios_share, size: 18, color: DripTheme.chrome),
            ),
          ],
          TextButton(
            onPressed: bay.saving
                ? null
                : () async {
                    try {
                      await n.save();
                      _toast('Project saved');
                    } catch (e) {
                      _toast('Save failed: $e');
                    }
                  },
            child: Text(
              bay.saving ? '…' : 'SAVE',
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                color: DripTheme.cosmicTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(EditBayState bay) {
    final adj = bay.selectedClip?.adjustments ?? const ClipAdjustments();

    Widget body;
    if (_loading) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: DripTheme.cosmicTeal, strokeWidth: 2),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!, style: const TextStyle(color: DripTheme.muted, fontSize: 12)),
            ],
          ],
        ),
      );
    } else if (_controller != null && _controller!.value.isInitialized) {
      body = ColorFiltered(
        colorFilter: ColorFilter.matrix(_previewMatrix(adj)),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    } else {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined,
                size: 40, color: DripTheme.cosmicTeal.withOpacity(0.35)),
            const SizedBox(height: 12),
            const Text('NO SIGNAL',
                style: TextStyle(letterSpacing: 3, fontSize: 11, color: DripTheme.muted)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickFromGallery,
              child: const Text('IMPORT VIDEO',
                  style: TextStyle(color: DripTheme.cosmicTeal, letterSpacing: 1.2)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          body,
          if (adj.vignette > 0.01)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(adj.vignette.clamp(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 10,
            bottom: 8,
            child: Text(
              _fmt(bay.project.playheadSec),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 8,
            child: Text(
              bay.project.aspectRatio.label,
              style: const TextStyle(fontSize: 9, letterSpacing: 1, color: DripTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransport(EditBayState bay, EditBayNotifier n) {
    final playing = _controller?.value.isPlaying ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 20, color: DripTheme.chrome),
            onPressed: () {
              n.setPlayhead(0);
              _controller?.seekTo(Duration.zero);
            },
          ),
          IconButton(
            icon: Icon(
              playing ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: DripTheme.warmWhite,
            ),
            onPressed: () {
              if (_controller == null) return;
              setState(() {
                if (playing) {
                  _controller!.pause();
                  n.setPlaying(false);
                } else {
                  _controller!.play();
                  n.setPlaying(true);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 20, color: DripTheme.chrome),
            onPressed: () {
              n.setPlayhead(bay.project.totalDuration);
              if (_controller != null) {
                _controller!.seekTo(_controller!.value.duration);
              }
            },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: DripTheme.cosmicTeal,
                inactiveTrackColor: Colors.white12,
                thumbColor: DripTheme.warmWhite,
              ),
              child: Slider(
                value: bay.project.playheadSec.clamp(0, bay.project.totalDuration),
                max: bay.project.totalDuration <= 0 ? 1 : bay.project.totalDuration,
                onChanged: (v) {
                  n.setPlayhead(v);
                  _controller?.seekTo(Duration(milliseconds: (v * 1000).round()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(EditBayState bay, EditBayNotifier n) {
    final pps = bay.project.pixelsPerSecond;
    final width = (bay.project.totalDuration * pps).clamp(320.0, 8000.0);

    return Container(
      decoration: BoxDecoration(
        color: DripTheme.deepBlack,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 2),
            child: Row(
              children: [
                const Text('TIMELINE',
                    style: TextStyle(fontSize: 9, letterSpacing: 2, color: DripTheme.muted)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_cut, size: 16, color: DripTheme.chrome),
                  tooltip: 'Split',
                  onPressed: n.splitClipAtPlayhead,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: DripTheme.chrome),
                  onPressed: n.deleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out, size: 16, color: DripTheme.chrome),
                  onPressed: () => n.setZoom(pps - 8),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, size: 16, color: DripTheme.chrome),
                  onPressed: () => n.setZoom(pps + 8),
                ),
              ],
            ),
          ),
          Expanded(
            child: bay.project.clips.isEmpty
                ? const Center(
                    child: Text(
                      'Import media or generate scenes — they appear here as clips.',
                      style: TextStyle(color: DripTheme.muted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 44, right: 12, bottom: 6),
                    child: SizedBox(
                      width: width,
                      child: Stack(
                        children: [
                          Column(
                            children: bay.project.tracks.map((track) {
                              final clips = bay.project.clips
                                  .where((c) => c.trackId == track.id)
                                  .toList();
                              return _TrackRow(
                                track: track,
                                clips: clips,
                                pps: pps,
                                selectedId: bay.selectedClipId,
                                onSelect: (id) {
                                  n.selectClip(id);
                                  EditClip? clip;
                                  for (final c in bay.project.clips) {
                                    if (c.id == id) { clip = c; break; }
                                  }
                                  if (clip != null) _loadSelectedClipMedia(clip);
                                },
                                onMove: n.moveClip,
                              );
                            }).toList(),
                          ),
                          Positioned(
                            left: bay.project.playheadSec * pps,
                            top: 0,
                            bottom: 0,
                            child: Container(width: 1.5, color: DripTheme.cosmicTeal),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolRail() {
    const tools = [
      ('timeline', Icons.view_timeline_outlined, 'CUT'),
      ('trim', Icons.content_cut, 'TRIM'),
      ('crop', Icons.crop, 'CROP'),
      ('filters', Icons.filter_vintage, 'FILTER'),
      ('adjust', Icons.tune, 'COLOR'),
      ('memory', Icons.memory, 'DNA'),
    ];
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tools.map((t) {
          final on = _finishingTool == t.$1;
          return InkWell(
            onTap: () => setState(() => _finishingTool = t.$1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(t.$2, size: 18, color: on ? DripTheme.cosmicTeal : DripTheme.muted),
                const SizedBox(height: 2),
                Text(t.$3,
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 1,
                      color: on ? DripTheme.cosmicTeal : DripTheme.muted,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInspector(EditBayState bay, EditBayNotifier n) {
    final clip = bay.selectedClip;

    if (_finishingTool == 'memory') {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: clip == null
            ? const Text('Select a clip', style: TextStyle(color: DripTheme.muted))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHARACTER  ·  ${clip.characterName ?? '—'}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('LOCATION  ·  ${clip.locationName ?? '—'}',
                      style: const TextStyle(fontSize: 12, color: DripTheme.chrome)),
                  const SizedBox(height: 6),
                  Text('CAMERA  ·  ${clip.styleNote ?? '—'}',
                      style: const TextStyle(fontSize: 11, color: DripTheme.muted)),
                  const SizedBox(height: 6),
                  Text('SCENE  ·  ${clip.sceneId ?? '—'}',
                      style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
                ],
              ),
      );
    }

    if (_finishingTool == 'timeline') {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: CinematicButton(
                label: 'SPLIT',
                icon: Icons.content_cut,
                primary: false,
                onPressed: n.splitClipAtPlayhead,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CinematicButton(
                label: 'DELETE',
                icon: Icons.delete_outline,
                primary: false,
                onPressed: n.deleteSelected,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CinematicButton(
                label: 'IMPORT',
                icon: Icons.add,
                onPressed: _pickFromGallery,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentPath == null) {
      return const Center(
        child: Text('Load a clip to use finishing tools',
            style: TextStyle(color: DripTheme.muted, fontSize: 12)),
      );
    }

    switch (_finishingTool) {
      case 'trim':
        return _trimPanel();
      case 'crop':
        return _cropPanel();
      case 'filters':
        return _filtersPanel();
      case 'adjust':
        return _adjustPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _trimPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text('IN ${_trimStart.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
              const Spacer(),
              Text('OUT ${_trimEnd.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_trimStart, _trimEnd),
            max: _duration,
            activeColor: DripTheme.cosmicTeal,
            inactiveColor: Colors.white12,
            onChanged: (v) => setState(() {
              _trimStart = v.start;
              _trimEnd = v.end;
            }),
          ),
          CinematicButton(
            label: 'APPLY TRIM',
            icon: Icons.content_cut,
            onPressed: _loading
                ? null
                : () => _runEdit(
                      () => _editor.trim(
                        inputPath: _currentPath!,
                        startSec: _trimStart,
                        endSec: _trimEnd,
                      ),
                      'Trim',
                    ),
          ),
        ],
      ),
    );
  }

  Widget _cropPanel() {
    const ratios = ['16:9', '9:16', '1:1', '4:5', '2.39:1'];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ratios
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r, style: const TextStyle(fontSize: 11)),
                          selected: _aspect == r,
                          selectedColor: DripTheme.cosmicTeal.withOpacity(0.3),
                          onSelected: (_) => setState(() => _aspect = r),
                          labelStyle: TextStyle(
                            color: _aspect == r
                                ? DripTheme.cosmicTeal
                                : DripTheme.warmWhite,
                          ),
                          backgroundColor: DripTheme.surface,
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          CinematicButton(
            label: 'APPLY CROP $_aspect',
            icon: Icons.crop,
            onPressed: _loading
                ? null
                : () => _runEdit(
                      () => _editor.crop(
                        inputPath: _currentPath!,
                        aspectRatio: _aspect,
                      ),
                      'Crop',
                    ),
          ),
        ],
      ),
    );
  }

  Widget _filtersPanel() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      children: _filters.map((f) {
        final on = _activeFilter == f.$1 || (f.$1 == 'none' && _activeFilter == null);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f.$2, style: const TextStyle(fontSize: 11)),
            selected: on,
            selectedColor: DripTheme.cosmicTeal.withOpacity(0.3),
            onSelected: (_) {
              setState(() => _activeFilter = f.$1 == 'none' ? null : f.$1);
              if (f.$1 != 'none' && !_loading) {
                _runEdit(
                  () => _editor.applyFilter(
                    inputPath: _currentPath!,
                    filterId: f.$1,
                  ),
                  'Filter ${f.$2}',
                );
              }
            },
            labelStyle: TextStyle(
              color: on ? DripTheme.cosmicTeal : DripTheme.warmWhite,
            ),
            backgroundColor: DripTheme.surface,
          ),
        );
      }).toList(),
    );
  }

  Widget _adjustPanel() {
    Widget row(String label, double value, ValueChanged<double> on) {
      return Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: -1,
              max: 1,
              activeColor: DripTheme.cosmicTeal,
              inactiveColor: Colors.white12,
              onChanged: on,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                row('BRIGHT', _brightness, (v) => setState(() => _brightness = v)),
                row('CONTRAST', _contrast, (v) => setState(() => _contrast = v)),
                row('SAT', _saturation, (v) => setState(() => _saturation = v)),
                row('WARMTH', _warmth, (v) => setState(() => _warmth = v)),
              ],
            ),
          ),
          CinematicButton(
            label: 'APPLY COLOR',
            icon: Icons.tune,
            onPressed: _loading
                ? null
                : () => _runEdit(
                      () => _editor.adjust(
                        inputPath: _currentPath!,
                        brightness: _brightness,
                        contrast: _contrast,
                        saturation: _saturation,
                        warmth: _warmth,
                      ),
                      'Color',
                    ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).floor().toString().padLeft(2, '0');
    final f = ((s % 1) * 24).floor().toString().padLeft(2, '0');
    return '$m:$sec:$f';
  }

  static List<double> _previewMatrix(ClipAdjustments a) {
    final b = a.brightness + a.exposure * 0.5;
    final c = 1 + a.contrast * 0.5 + a.cinematicContrast * 0.25;
    final sat = 1 + a.saturation * 0.5;
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final r = (1 - sat) * lr;
    final g = (1 - sat) * lg;
    final bl = (1 - sat) * lb;
    final t = a.temperature;
    return [
      (r + sat) * c, g * c, bl * c, 0, b * 255 + t * 20,
      r * c, (g + sat) * c, bl * c, 0, b * 255,
      r * c, g * c, (bl + sat) * c, 0, b * 255 - t * 12,
      0, 0, 0, 1, 0,
    ];
  }
}

class _TrackRow extends StatelessWidget {
  final EditTrack track;
  final List<EditClip> clips;
  final double pps;
  final String? selectedId;
  final void Function(String?) onSelect;
  final void Function(String, double) onMove;

  const _TrackRow({
    required this.track,
    required this.clips,
    required this.pps,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: track.kind == TrackKind.video ? 48 : 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -40,
            top: 0,
            bottom: 0,
            width: 36,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(track.name,
                  style: const TextStyle(
                      fontSize: 9, letterSpacing: 1, color: DripTheme.muted)),
            ),
          ),
          ...clips.map((c) {
            final selected = c.id == selectedId;
            return Positioned(
              left: c.startOnTimeline * pps,
              width: (c.duration * pps).clamp(24, 4000),
              top: 3,
              bottom: 3,
              child: GestureDetector(
                onTap: () => onSelect(c.id),
                onHorizontalDragUpdate: (d) {
                  onMove(c.id, c.startOnTimeline + d.delta.dx / pps);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: track.kind == TrackKind.video
                        ? (selected
                            ? DripTheme.cosmicTeal.withOpacity(0.35)
                            : DripTheme.surfaceRaised)
                        : (selected
                            ? DripTheme.nebulaCyan.withOpacity(0.28)
                            : const Color(0xFF1A2224)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: selected
                          ? DripTheme.cosmicTeal
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    c.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: DripTheme.warmWhite),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
