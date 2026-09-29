import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/video_edit_service.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';

enum _EditTool { none, trim, crop, filters, adjust }

class EditBayScreen extends ConsumerStatefulWidget {
  /// Optional starting video (local path or remote URL from a generated scene).
  final String? initialVideoPathOrUrl;

  const EditBayScreen({super.key, this.initialVideoPathOrUrl});

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
  _EditTool _tool = _EditTool.none;

  // Trim
  double _duration = 5;
  double _trimStart = 0;
  double _trimEnd = 5;

  // Crop
  String _aspect = '16:9';

  // Filter
  String? _activeFilter;

  // Adjust
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _warmth = 0;

  static const _filters = [
    ('none', 'None'),
    ('cinematic', 'Cinematic'),
    ('teal_orange', 'Teal & Orange'),
    ('noir', 'Noir'),
    ('vivid', 'Vivid'),
    ('vintage', 'Vintage'),
    ('cool', 'Cool'),
    ('warm', 'Warm'),
    ('grain', 'Grain'),
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
      _status = 'Loading video…';
    });
    try {
      String localPath = pathOrUrl;
      if (pathOrUrl.startsWith('http')) {
        final dir = await getTemporaryDirectory();
        localPath =
            '\( {dir.path}/import_ \){DateTime.now().millisecondsSinceEpoch}.mp4';
        final res = await http.get(Uri.parse(pathOrUrl));
        if (res.statusCode != 200) throw Exception('Download failed');
        await File(localPath).writeAsBytes(res.bodyBytes);
      }
      await _setController(localPath);
    } catch (e) {
      _toast('Could not load video: $e');
    } finally {
      setState(() {
        _loading = false;
        _status = null;
      });
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
    c.play();
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
      _toast('$label complete');
    } catch (e) {
      _toast('$label failed: $e');
    } finally {
      setState(() {
        _loading = false;
        _status = null;
      });
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
    await Share.shareXFiles(
      [XFile(_currentPath!)],
      text: 'Edited with #DripVision',
    );
  }

  Future<void> _download() async {
    if (_currentPath == null) return;
    setState(() {
      _loading = true;
      _status = 'Saving to gallery…';
    });
    try {
      await Gal.putVideo(_currentPath!);
      _toast('Saved to gallery');
    } catch (e) {
      _toast('Save failed: $e');
    } finally {
      setState(() {
        _loading = false;
        _status = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text(
          'EDIT BAY',
          style: TextStyle(fontSize: 12, letterSpacing: 3),
        ),
        actions: [
          if (_currentPath != null) ...[
            IconButton(
              icon: const Icon(Icons.download_rounded, color: DripTheme.nebulaCyan),
              onPressed: _loading ? null : _download,
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded, color: DripTheme.cosmicTeal),
              onPressed: _loading ? null : _share,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: DripTheme.deepBlack,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildPreview(),
              ),
            ),

            // Tool rail
            _buildToolRail(),

            // Tool panel
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              child: _buildToolPanel(),
            ),

            // Import / status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _currentPath == null
                  ? Column(
                      children: [
                        CinematicButton(
                          label: 'IMPORT FROM GALLERY',
                          icon: Icons.video_library_outlined,
                          onPressed: _pickFromGallery,
                        ),
                        const SizedBox(height: 10),
                        _buildFromScenesButton(),
                      ],
                    )
                  : _loading
                      ? CinematicCard(
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: DripTheme.cosmicTeal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _status ?? 'Working…',
                                  style: const TextStyle(color: DripTheme.muted),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: CinematicButton(
                                label: 'IMPORT NEW',
                                icon: Icons.add,
                                primary: false,
                                onPressed: _pickFromGallery,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CinematicButton(
                                label: 'SHARE',
                                icon: Icons.ios_share,
                                onPressed: _share,
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_loading && _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined,
                size: 48, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 12),
            const Text(
              'Import a video to start editing',
              style: TextStyle(color: DripTheme.muted),
            ),
          ],
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        Positioned(
          bottom: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
                border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.5)),
              ),
              child: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: DripTheme.aquaGlow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolRail() {
    if (_currentPath == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolBtn(_EditTool.trim, Icons.content_cut, 'TRIM'),
          _toolBtn(_EditTool.crop, Icons.crop, 'CROP'),
          _toolBtn(_EditTool.filters, Icons.filter_vintage, 'FILTERS'),
          _toolBtn(_EditTool.adjust, Icons.tune, 'ADJUST'),
        ],
      ),
    );
  }

  Widget _toolBtn(_EditTool tool, IconData icon, String label) {
    final selected = _tool == tool;
    return GestureDetector(
      onTap: () => setState(() => _tool = selected ? _EditTool.none : tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? DripTheme.cosmicTeal.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? DripTheme.cosmicTeal.withOpacity(0.45)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? DripTheme.cosmicTeal : Colors.white38),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? DripTheme.cosmicTeal : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolPanel() {
    switch (_tool) {
      case _EditTool.trim:
        return _trimPanel();
      case _EditTool.crop:
        return _cropPanel();
      case _EditTool.filters:
        return _filtersPanel();
      case _EditTool.adjust:
        return _adjustPanel();
      case _EditTool.none:
        return const SizedBox.shrink();
    }
  }

  Widget _trimPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CinematicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRIM  ·  ${_trimStart.toStringAsFixed(1)}s → ${_trimEnd.toStringAsFixed(1)}s',
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: DripTheme.cosmicTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
            RangeSlider(
              values: RangeValues(_trimStart, _trimEnd),
              min: 0,
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
              onPressed: () => _runEdit(
                () => _editor.trim(
                  inputPath: _currentPath!,
                  startSec: _trimStart,
                  endSec: _trimEnd,
                ),
                'Trimming',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cropPanel() {
    final ratios = ['16:9', '9:16', '1:1', '4:5'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CinematicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ASPECT RATIO',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: DripTheme.cosmicTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: ratios.map((r) {
                final sel = _aspect == r;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _aspect = r),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? DripTheme.cosmicTeal.withOpacity(0.14)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? DripTheme.cosmicTeal.withOpacity(0.5)
                              : Colors.white10,
                        ),
                      ),
                      child: Text(
                        r,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: sel ? DripTheme.aquaGlow : DripTheme.chrome,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            CinematicButton(
              label: 'APPLY CROP',
              icon: Icons.crop,
              onPressed: () => _runEdit(
                () => _editor.crop(
                  inputPath: _currentPath!,
                  aspectRatio: _aspect,
                ),
                'Cropping',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (id, name) = _filters[i];
            final sel = _activeFilter == id || (id == 'none' && _activeFilter == null);
            return GestureDetector(
              onTap: () {
                if (id == 'none') {
                  setState(() => _activeFilter = null);
                  return;
                }
                setState(() => _activeFilter = id);
                _runEdit(
                  () => _editor.applyFilter(
                    inputPath: _currentPath!,
                    filterId: id,
                  ),
                  'Applying $name',
                );
              },
              child: Container(
                width: 78,
                decoration: BoxDecoration(
                  color: sel
                      ? DripTheme.cosmicTeal.withOpacity(0.14)
                      : DripTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? DripTheme.cosmicTeal.withOpacity(0.5)
                        : Colors.white10,
                  ),
                ),
                child: Center(
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sel ? DripTheme.aquaGlow : DripTheme.chrome,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _adjustPanel() {
    Widget slider(String label, double value, ValueChanged<double> onChanged) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label  ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 10, color: DripTheme.muted),
          ),
          Slider(
            value: value,
            min: -1,
            max: 1,
            activeColor: DripTheme.cosmicTeal,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CinematicCard(
        child: Column(
          children: [
            slider('BRIGHTNESS', _brightness, (v) => setState(() => _brightness = v)),
            slider('CONTRAST', _contrast, (v) => setState(() => _contrast = v)),
            slider('SATURATION', _saturation, (v) => setState(() => _saturation = v)),
            slider('WARMTH', _warmth, (v) => setState(() => _warmth = v)),
            CinematicButton(
              label: 'APPLY ADJUSTMENTS',
              icon: Icons.tune,
              onPressed: () => _runEdit(
                () => _editor.adjust(
                  inputPath: _currentPath!,
                  brightness: _brightness,
                  contrast: _contrast,
                  saturation: _saturation,
                  warmth: _warmth,
                ),
                'Adjusting',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFromScenesButton() {
    final scenes = ref.watch(sceneListProvider)
        .where((s) => s.outputVideoUrl != null)
        .toList();
    if (scenes.isEmpty) return const SizedBox.shrink();

    return CinematicButton(
      label: 'FROM GENERATED SCENES (${scenes.length})',
      icon: Icons.auto_awesome,
      primary: false,
      onPressed: () async {
        final chosen = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: DripTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          builder: (ctx) => ListView.builder(
            shrinkWrap: true,
            itemCount: scenes.length,
            itemBuilder: (_, i) {
              final s = scenes[i];
              return ListTile(
                title: Text(
                  'SCENE ${(i + 1).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: DripTheme.nebulaCyan,
                  ),
                ),
                subtitle: Text(
                  s.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: DripTheme.warmWhite),
                ),
                onTap: () => Navigator.pop(ctx, s.outputVideoUrl),
              );
            },
          ),
        );
        if (chosen != null) await _loadSource(chosen);
      },
    );
  }
}