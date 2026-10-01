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
import '../../services/timeline_export_service.dart';
import '../../services/video_edit_service.dart';
import '../widgets/cinematic_button.dart';

/// EDIT BAY — cinema NLE surface (inspired by professional post suites).
/// Charcoal environment, teal only on playhead / selection / primary actions.
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

  String _finishingTool = 'timeline';

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

  // Monitor bezel — charcoal, not pure black
  static const _monitor = Color(0xFF0C0E10);
  static const _rail = Color(0xFF0E1113);
  static const _panel = Color(0xFF121518);

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

  Future<void> _runEdit(Future<String> Function() op, String label) async {
    if (_currentPath == null) return;
    setState(() {
      _loading = true;
      _status = label;
    });
    try {
      final out = await op();
      await _setController(out);
      final bay = ref.read(editBayProvider);
      final sel = bay.selectedClip;
      if (sel != null) {
        ref.read(editBayProvider.notifier).updateClip(sel.copyWith(mediaUrl: out));
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
      SnackBar(content: Text(msg), backgroundColor: DripTheme.surfaceRaised),
    );
  }

  Future<void> _share() async {
    if (_currentPath == null) return;
    await Share.shareXFiles([XFile(_currentPath!)], text: 'Cut with #DripVision');
  }

  Future<void> _exportTimeline() async {
    final project = ref.read(editBayProvider).project;
    setState(() {
      _loading = true;
      _status = 'Exporting cut…';
    });
    try {
      final path = await TimelineExportService().exportProject(
        project,
        onStage: (s) {
          if (mounted) setState(() => _status = s);
        },
      );
      await _setController(path);
      if (!mounted) return;
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _panel,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Cut ready', style: TextStyle(color: DripTheme.warmWhite)),
          content: const Text(
            'Timeline stitched into one file.',
            style: TextStyle(color: DripTheme.chrome),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'share'),
              child: const Text('SHARE', style: TextStyle(color: DripTheme.chrome)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('SAVE TO GALLERY',
                  style: TextStyle(color: DripTheme.cosmicTeal)),
            ),
          ],
        ),
      );
      if (action == 'share') {
        await Share.shareXFiles([XFile(path)], text: 'Cut with #DripVision');
      } else if (action == 'save') {
        await Gal.putVideo(path);
        _toast('Saved to gallery');
      }
    } catch (e) {
      _toast('Export failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _status = null;
        });
      }
    }
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
      backgroundColor: _monitor,
      body: SafeArea(
        child: Column(
          children: [
            _topChrome(bay, n),
            Expanded(flex: 5, child: _cinemaMonitor(bay)),
            _transport(bay, n),
            Expanded(flex: 3, child: _timelineDeck(bay, n)),
            _toolChrome(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.19,
              child: ColoredBox(
                color: _panel,
                child: _inspector(bay, n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TOP CHROME ───────────────────────────────────────────
  Widget _topChrome(EditBayState bay, EditBayNotifier n) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: _rail,
        border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: DripTheme.chrome),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bay.project.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                    color: DripTheme.warmWhite,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${bay.project.sequenceName}  ·  ${bay.project.dirty ? 'UNSAVED' : 'SAVED'}',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: bay.project.dirty
                        ? DripTheme.cosmicTeal
                        : const Color(0xFF6A7270),
                  ),
                ),
              ],
            ),
          ),
          _iconBtn(Icons.add_box_outlined, _loading ? null : _pickFromGallery, tip: 'Import'),
          _iconBtn(Icons.undo, bay.undoStack.isEmpty ? null : n.undo),
          _iconBtn(Icons.redo, bay.redoStack.isEmpty ? null : n.redo),
          if (_currentPath != null) ...[
            _iconBtn(Icons.download_rounded, _loading ? null : _download),
            _iconBtn(Icons.ios_share, _loading ? null : _share),
          ],
          TextButton(
            onPressed: _loading ? null : _exportTimeline,
            child: const Text('EXPORT',
                style: TextStyle(
                    fontSize: 10, letterSpacing: 1.3, color: DripTheme.warmWhite)),
          ),
          TextButton(
            onPressed: bay.saving
                ? null
                : () async {
                    try {
                      await n.save();
                      _toast('Saved');
                    } catch (e) {
                      _toast('Save failed: $e');
                    }
                  },
            child: Text(
              bay.saving ? '…' : 'SAVE',
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.3,
                color: DripTheme.cosmicTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap, {String? tip}) {
    return IconButton(
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon,
          size: 18,
          color: onTap == null ? const Color(0xFF3A4040) : DripTheme.chrome),
    );
  }

  // ─── CINEMA MONITOR ───────────────────────────────────────
  Widget _cinemaMonitor(EditBayState bay) {
    final adj = bay.selectedClip?.adjustments ?? const ClipAdjustments();

    Widget picture;
    if (_loading) {
      picture = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: DripTheme.cosmicTeal,
              strokeWidth: 1.5,
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!,
                style: const TextStyle(fontSize: 11, color: Color(0xFF7A8280))),
          ],
        ],
      );
    } else if (_controller != null && _controller!.value.isInitialized) {
      picture = ColorFiltered(
        colorFilter: ColorFilter.matrix(_previewMatrix(adj)),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    } else {
      picture = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_outlined,
              size: 36, color: DripTheme.cosmicTeal.withOpacity(0.25)),
          const SizedBox(height: 10),
          const Text('NO SIGNAL',
              style: TextStyle(
                  fontSize: 10, letterSpacing: 3, color: Color(0xFF5A6260))),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickFromGallery,
            child: const Text('IMPORT',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    color: DripTheme.cosmicTeal)),
          ),
        ],
      );
    }

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Center(
        child: AspectRatio(
          aspectRatio: bay.project.aspectRatio.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x18FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: _monitor, child: Center(child: picture)),
                  if (adj.vignette > 0.01)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(adj.vignette.clamp(0, 1)),
                          ],
                        ),
                      ),
                    ),
                  // Timecode HUD
                  Positioned(
                    left: 10,
                    bottom: 8,
                    child: Text(
                      _fmt(bay.project.playheadSec),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Color(0xB3FFFFFF),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 8,
                    child: Text(
                      bay.project.aspectRatio.label,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: Color(0x66FFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── TRANSPORT ────────────────────────────────────────────
  Widget _transport(EditBayState bay, EditBayNotifier n) {
    final playing = _controller?.value.isPlaying ?? false;
    return Container(
      height: 44,
      color: _rail,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 20, color: DripTheme.chrome),
            onPressed: () {
              n.setPlayhead(0);
              _controller?.seekTo(Duration.zero);
            },
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                playing ? Icons.pause : Icons.play_arrow,
                size: 22,
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
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 20, color: DripTheme.chrome),
            onPressed: () {
              n.setPlayhead(bay.project.totalDuration);
              _controller?.seekTo(_controller!.value.duration);
            },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: DripTheme.cosmicTeal,
                inactiveTrackColor: const Color(0x18FFFFFF),
                thumbColor: DripTheme.warmWhite,
              ),
              child: Slider(
                value: bay.project.playheadSec
                    .clamp(0, bay.project.totalDuration),
                max: bay.project.totalDuration <= 0
                    ? 1
                    : bay.project.totalDuration,
                onChanged: (v) {
                  n.setPlayhead(v);
                  _controller?.seekTo(
                      Duration(milliseconds: (v * 1000).round()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TIMELINE DECK (filmstrip style) ──────────────────────
  Widget _timelineDeck(EditBayState bay, EditBayNotifier n) {
    final pps = bay.project.pixelsPerSecond;
    final width = (bay.project.totalDuration * pps).clamp(320.0, 8000.0);

    return Container(
      color: const Color(0xFF0A0C0E),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 2),
            child: Row(
              children: [
                const Text('TIMELINE',
                    style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 2,
                        color: Color(0xFF5A6260))),
                const Spacer(),
                _miniIcon(Icons.content_cut, n.splitClipAtPlayhead),
                _miniIcon(Icons.delete_outline, n.deleteSelected),
                _miniIcon(Icons.zoom_out, () => n.setZoom(pps - 8)),
                _miniIcon(Icons.zoom_in, () => n.setZoom(pps + 8)),
              ],
            ),
          ),
          Expanded(
            child: bay.project.clips.isEmpty
                ? const Center(
                    child: Text(
                      'Import media or generate scenes — clips appear here.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5A6260)),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.only(left: 40, right: 12, bottom: 8),
                    child: SizedBox(
                      width: width,
                      child: Stack(
                        children: [
                          Column(
                            children: bay.project.tracks.map((track) {
                              final clips = bay.project.clips
                                  .where((c) => c.trackId == track.id)
                                  .toList();
                              return _FilmTrack(
                                track: track,
                                clips: clips,
                                pps: pps,
                                selectedId: bay.selectedClipId,
                                onSelect: (id) {
                                  n.selectClip(id);
                                  EditClip? clip;
                                  for (final c in bay.project.clips) {
                                    if (c.id == id) {
                                      clip = c;
                                      break;
                                    }
                                  }
                                  if (clip != null) {
                                    _loadSelectedClipMedia(clip);
                                  }
                                },
                                onMove: n.moveClip,
                              );
                            }).toList(),
                          ),
                          // Playhead — only teal accent on timeline
                          Positioned(
                            left: bay.project.playheadSec * pps,
                            top: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Container(
                                width: 1.5,
                                color: DripTheme.cosmicTeal,
                              ),
                            ),
                          ),
                          Positioned(
                            left: bay.project.playheadSec * pps - 4,
                            top: 0,
                            child: IgnorePointer(
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: DripTheme.cosmicTeal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
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

  Widget _miniIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 15, color: DripTheme.chrome),
      onPressed: onTap,
    );
  }

  // ─── TOOL RAIL ────────────────────────────────────────────
  Widget _toolChrome() {
    const tools = [
      ('timeline', Icons.view_timeline_outlined, 'CUT'),
      ('trim', Icons.content_cut, 'TRIM'),
      ('crop', Icons.crop, 'CROP'),
      ('filters', Icons.filter_vintage, 'FILTER'),
      ('adjust', Icons.tune, 'COLOR'),
      ('memory', Icons.memory, 'DNA'),
    ];
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: _rail,
        border: Border(
          top: BorderSide(color: Color(0x14FFFFFF)),
          bottom: BorderSide(color: Color(0x14FFFFFF)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tools.map((t) {
          final on = _finishingTool == t.$1;
          return InkWell(
            onTap: () => setState(() => _finishingTool = t.$1),
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.$2,
                      size: 17,
                      color: on ? DripTheme.cosmicTeal : const Color(0xFF6A7270)),
                  const SizedBox(height: 3),
                  Text(t.$3,
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 1,
                        color:
                            on ? DripTheme.cosmicTeal : const Color(0xFF6A7270),
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── INSPECTOR ────────────────────────────────────────────
  Widget _inspector(EditBayState bay, EditBayNotifier n) {
    final clip = bay.selectedClip;

    if (_finishingTool == 'memory') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: clip == null
            ? const Text('Select a clip', style: DripTheme.meta)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CONTINUITY', style: DripTheme.technical),
                  const SizedBox(height: 10),
                  _dnaRow('CHARACTER', clip.characterName ?? '—'),
                  _dnaRow('LOCATION', clip.locationName ?? '—'),
                  _dnaRow('CAMERA', clip.styleNote ?? '—'),
                  _dnaRow('SCENE', clip.sceneId ?? '—'),
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
        child: Text('Load a clip for finishing tools', style: DripTheme.meta),
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

  Widget _dnaRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(k,
                style: const TextStyle(
                    fontSize: 9, letterSpacing: 1.2, color: Color(0xFF6A7270))),
          ),
          Expanded(
            child: Text(v,
                style: const TextStyle(fontSize: 12, color: DripTheme.warmWhite)),
          ),
        ],
      ),
    );
  }

  Widget _trimPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text('IN ${_trimStart.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6A7270))),
              const Spacer(),
              Text('OUT ${_trimEnd.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6A7270))),
            ],
          ),
          RangeSlider(
            values: RangeValues(_trimStart, _trimEnd),
            max: _duration,
            activeColor: DripTheme.cosmicTeal,
            inactiveColor: const Color(0x18FFFFFF),
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
                          selectedColor: DripTheme.cosmicTeal.withOpacity(0.25),
                          onSelected: (_) => setState(() => _aspect = r),
                          labelStyle: TextStyle(
                            color: _aspect == r
                                ? DripTheme.cosmicTeal
                                : DripTheme.warmWhite,
                          ),
                          backgroundColor: _panel,
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
        final on =
            _activeFilter == f.$1 || (f.$1 == 'none' && _activeFilter == null);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f.$2, style: const TextStyle(fontSize: 11)),
            selected: on,
            selectedColor: DripTheme.cosmicTeal.withOpacity(0.25),
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
            backgroundColor: _panel,
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
                style: const TextStyle(fontSize: 10, color: Color(0xFF6A7270))),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: -1,
              max: 1,
              activeColor: DripTheme.cosmicTeal,
              inactiveColor: const Color(0x18FFFFFF),
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

/// Filmstrip-style track row (reference #1 energy).
class _FilmTrack extends StatelessWidget {
  final EditTrack track;
  final List<EditClip> clips;
  final double pps;
  final String? selectedId;
  final void Function(String?) onSelect;
  final void Function(String, double) onMove;

  const _FilmTrack({
    required this.track,
    required this.clips,
    required this.pps,
    required this.selectedId,
    required this.onSelect,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = track.kind == TrackKind.video;
    return SizedBox(
      height: isVideo ? 52 : 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -36,
            top: 0,
            bottom: 0,
            width: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                track.name,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  color: Color(0xFF5A6260),
                ),
              ),
            ),
          ),
          ...clips.map((c) {
            final selected = c.id == selectedId;
            return Positioned(
              left: c.startOnTimeline * pps,
              width: (c.duration * pps).clamp(28, 4000),
              top: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: () => onSelect(c.id),
                onHorizontalDragUpdate: (d) {
                  onMove(c.id, c.startOnTimeline + d.delta.dx / pps);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isVideo
                        ? (selected
                            ? const Color(0xFF1A2A28)
                            : const Color(0xFF161A1C))
                        : (selected
                            ? const Color(0xFF1A2428)
                            : const Color(0xFF121618)),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: selected
                          ? DripTheme.cosmicTeal.withOpacity(0.7)
                          : const Color(0x14FFFFFF),
                      width: selected ? 1.2 : 1,
                    ),
                  ),
                  child: isVideo
                      ? Row(
                          children: [
                            if (c.thumbnailUrl != null &&
                                c.thumbnailUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(2),
                                  bottomLeft: Radius.circular(2),
                                ),
                                child: Image.network(
                                  c.thumbnailUrl!,
                                  width: 36,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(width: 4),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  c.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: DripTheme.warmWhite,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              c.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF8A9290),
                              ),
                            ),
                          ),
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
