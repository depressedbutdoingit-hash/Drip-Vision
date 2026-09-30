import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme.dart';
import '../../../core/providers.dart';
import '../../../models/edit_project.dart';
import '../../../services/edit_bay_notifier.dart';
import '../../widgets/cinematic_button.dart';

/// EDIT BAY — dedicated full-screen non-linear editor for DripVision.
/// Mobile-first: preview on top, timeline, tool rail, inspector sheets.
class EditBayNleScreen extends ConsumerStatefulWidget {
  final bool seedFromScenes;
  const EditBayNleScreen({super.key, this.seedFromScenes = true});

  @override
  ConsumerState<EditBayScreen> createState() => _EditBayNleScreenState();
}

class _EditBayNleScreenState extends ConsumerState<EditBayScreen> {
  VideoPlayerController? _player;
  String? _loadedUrl;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _syncPlayer(EditBayState bay) async {
    final clip = bay.selectedClip ??
        (bay.project.clips.isEmpty
            ? null
            : bay.project.clips.reduce(
                (a, b) =>
                    (bay.project.playheadSec - a.startOnTimeline).abs() <
                            (bay.project.playheadSec - b.startOnTimeline).abs()
                        ? a
                        : b));
    final url = clip?.mediaUrl;
    if (url == null || url.isEmpty) {
      await _player?.pause();
      return;
    }
    if (url == _loadedUrl && _player != null) {
      if (bay.playing && !(_player!.value.isPlaying)) {
        await _player!.play();
      } else if (!bay.playing && _player!.value.isPlaying) {
        await _player!.pause();
      }
      return;
    }
    await _player?.dispose();
    _loadedUrl = url;
    try {
      final c = url.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(url))
          : VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      _player = c;
      if (mounted) setState(() {});
      if (bay.playing) await c.play();
    } catch (_) {
      _player = null;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bay = ref.watch(editBayProvider);
    final scenes = ref.watch(sceneListProvider);

    // Seed once from scenes when empty
    if (widget.seedFromScenes &&
        bay.project.clips.isEmpty &&
        scenes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editBayProvider.notifier).loadFromScenes(scenes);
      });
    }

    ref.listen<EditBayState>(editBayProvider, (_, next) {
      _syncPlayer(next);
    });

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(bay: bay),
            Expanded(flex: 5, child: _PreviewMonitor(bay: bay, player: _player)),
            _TransportBar(bay: bay, player: _player),
            Expanded(flex: 4, child: _TimelinePanel(bay: bay)),
            _ToolRail(bay: bay),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.22,
              child: _Inspector(bay: bay),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final EditBayState bay;
  const _TopBar({required this.bay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(editBayProvider.notifier);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
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
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                    color: DripTheme.warmWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${bay.project.sequenceName}  ·  ${bay.project.dirty ? 'UNSAVED' : 'SAVED'}',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: bay.project.dirty
                        ? DripTheme.cosmicTeal
                        : DripTheme.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Undo',
            onPressed: bay.undoStack.isEmpty ? null : n.undo,
            icon: Icon(Icons.undo, size: 18,
                color: bay.undoStack.isEmpty ? DripTheme.muted : DripTheme.chrome),
          ),
          IconButton(
            tooltip: 'Redo',
            onPressed: bay.redoStack.isEmpty ? null : n.redo,
            icon: Icon(Icons.redo, size: 18,
                color: bay.redoStack.isEmpty ? DripTheme.muted : DripTheme.chrome),
          ),
          TextButton(
            onPressed: bay.saving
                ? null
                : () async {
                    try {
                      await n.save();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Project saved')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Save failed: $e')),
                        );
                      }
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
}

class _PreviewMonitor extends StatelessWidget {
  final EditBayState bay;
  final VideoPlayerController? player;
  const _PreviewMonitor({required this.bay, required this.player});

  @override
  Widget build(BuildContext context) {
    final adj = bay.selectedClip?.adjustments ?? const ClipAdjustments();
    final aspect = bay.project.aspectRatio.value;

    Widget content;
    if (player != null && player!.value.isInitialized) {
      content = AspectRatio(
        aspectRatio: player!.value.aspectRatio,
        child: VideoPlayer(player!),
      );
    } else {
      final thumb = bay.selectedClip?.thumbnailUrl;
      content = thumb != null && thumb.isNotEmpty
          ? Image.network(thumb, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _emptyMonitor())
          : _emptyMonitor();
    }

    // Preview-time color matrix approximation from adjustments
    final filter = ColorFilter.matrix(_colorMatrix(adj));

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AspectRatio(
        aspectRatio: aspect,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(colorFilter: filter, child: content),
              if (adj.vignette > 0.01)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(adj.vignette.clamp(0, 1)),
                      ],
                      radius: 1.05,
                    ),
                  ),
                ),
              if (adj.letterbox > 0.01) ...[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 14 * adj.letterbox,
                    color: Colors.black,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 14 * adj.letterbox,
                    color: Colors.black,
                  ),
                ),
              ],
              // Text overlays near playhead
              ...bay.project.texts
                  .where((t) =>
                      bay.project.playheadSec >= t.startSec &&
                      bay.project.playheadSec <= t.startSec + t.durationSec)
                  .map((t) => Align(
                        alignment: t.position == 'top'
                            ? Alignment.topCenter
                            : t.position == 'center'
                                ? Alignment.center
                                : Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            t.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(t.opacity),
                              fontSize: t.fontSize,
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(blurRadius: 8, color: Colors.black)
                              ],
                            ),
                          ),
                        ),
                      )),
              Positioned(
                left: 10,
                bottom: 8,
                child: Text(
                  _fmt(bay.project.playheadSec),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
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
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: DripTheme.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyMonitor() => Container(
        color: DripTheme.deepBlack,
        alignment: Alignment.center,
        child: const Text(
          'NO SIGNAL',
          style: TextStyle(
            letterSpacing: 3,
            fontSize: 11,
            color: DripTheme.muted,
          ),
        ),
      );

  static String _fmt(double s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).floor().toString().padLeft(2, '0');
    final f = ((s % 1) * 24).floor().toString().padLeft(2, '0');
    return '$m:$sec:$f';
  }

  static List<double> _colorMatrix(ClipAdjustments a) {
    // Simplified 5x4 matrix: brightness, contrast, saturation
    final b = a.brightness + a.exposure * 0.5;
    final c = 1 + a.contrast * 0.5 + a.cinematicContrast * 0.25;
    final sat = 1 + a.saturation * 0.5;
    final t = a.temperature;
    // Luma coeffs
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final r = (1 - sat) * lr;
    final g = (1 - sat) * lg;
    final bl = (1 - sat) * lb;
    return [
      (r + sat) * c, g * c, bl * c, 0, b * 255 + t * 20,
      r * c, (g + sat) * c, bl * c, 0, b * 255,
      r * c, g * c, (bl + sat) * c, 0, b * 255 - t * 12,
      0, 0, 0, 1, 0,
    ];
  }
}

class _TransportBar extends ConsumerWidget {
  final EditBayState bay;
  final VideoPlayerController? player;
  const _TransportBar({required this.bay, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(editBayProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 20, color: DripTheme.chrome),
            onPressed: () => n.setPlayhead(0),
          ),
          IconButton(
            icon: Icon(
              bay.playing ? Icons.pause : Icons.play_arrow,
              size: 28,
              color: DripTheme.warmWhite,
            ),
            onPressed: () => n.setPlaying(!bay.playing),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 20, color: DripTheme.chrome),
            onPressed: () => n.setPlayhead(bay.project.totalDuration),
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
                onChanged: n.setPlayhead,
              ),
            ),
          ),
          PopupMenuButton<EditAspectRatio>(
            tooltip: 'Aspect',
            onSelected: n.setAspect,
            itemBuilder: (_) => EditAspectRatio.values
                .map((a) => PopupMenuItem(value: a, child: Text(a.label)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                bay.project.aspectRatio.label,
                style: const TextStyle(fontSize: 10, color: DripTheme.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends ConsumerWidget {
  final EditBayState bay;
  const _TimelinePanel({required this.bay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(editBayProvider.notifier);
    final pps = bay.project.pixelsPerSecond;
    final width = (bay.project.totalDuration * pps).clamp(320, 8000);

    return Container(
      decoration: BoxDecoration(
        color: DripTheme.deepBlack,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Row(
              children: [
                const Text('TIMELINE',
                    style: TextStyle(
                        fontSize: 9, letterSpacing: 2, color: DripTheme.muted)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.content_cut, size: 16, color: DripTheme.chrome),
                  tooltip: 'Split at playhead',
                  onPressed: n.splitClipAtPlayhead,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: DripTheme.chrome),
                  tooltip: 'Delete',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
              child: SizedBox(
                width: width.toDouble(),
                child: Stack(
                  children: [
                    Column(
                      children: bay.project.tracks.map((track) {
                        final trackClips = bay.project.clips
                            .where((c) => c.trackId == track.id)
                            .toList();
                        return _TrackRow(
                          track: track,
                          clips: trackClips,
                          pps: pps,
                          selectedId: bay.selectedClipId,
                          onSelect: n.selectClip,
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
      height: track.kind == TrackKind.video ? 52 : 36,
      child: Stack(
        children: [
          Positioned(
            left: -44,
            top: 0,
            bottom: 0,
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                track.name,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  color: DripTheme.muted,
                ),
              ),
            ),
          ),
          ...clips.map((c) {
            final selected = c.id == selectedId;
            return Positioned(
              left: c.startOnTimeline * pps,
              width: (c.duration * pps).clamp(24, 4000),
              top: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: () => onSelect(c.id),
                onHorizontalDragUpdate: (d) {
                  final newStart =
                      c.startOnTimeline + d.delta.dx / pps;
                  onMove(c.id, newStart);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: track.kind == TrackKind.video
                        ? (selected
                            ? DripTheme.cosmicTeal.withOpacity(0.35)
                            : DripTheme.surfaceRaised)
                        : (selected
                            ? DripTheme.nebulaCyan.withOpacity(0.3)
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

class _ToolRail extends ConsumerWidget {
  final EditBayState bay;
  const _ToolRail({required this.bay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tools = [
      ('color', Icons.tune, 'COLOR'),
      ('filters', Icons.filter_vintage, 'FILTERS'),
      ('transitions', Icons.animation, 'TRANS'),
      ('audio', Icons.graphic_eq, 'AUDIO'),
      ('text', Icons.title, 'TEXT'),
      ('memory', Icons.memory, 'MEMORY'),
    ];
    final n = ref.read(editBayProvider.notifier);
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tools.map((t) {
          final on = bay.toolPanel == t.$1;
          return InkWell(
            onTap: () => n.setToolPanel(t.$1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(t.$2,
                    size: 18,
                    color: on ? DripTheme.cosmicTeal : DripTheme.muted),
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
}

class _Inspector extends ConsumerWidget {
  final EditBayState bay;
  const _Inspector({required this.bay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(editBayProvider.notifier);
    final clip = bay.selectedClip;

    if (clip == null && bay.toolPanel != 'text') {
      return const Center(
        child: Text(
          'Select a clip on the timeline',
          style: TextStyle(color: DripTheme.muted, fontSize: 12),
        ),
      );
    }

    switch (bay.toolPanel) {
      case 'filters':
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          children: DripFilterId.values.map((f) {
            final on = clip!.adjustments.filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.label, style: const TextStyle(fontSize: 11)),
                selected: on,
                onSelected: (_) => n.setFilter(f),
                selectedColor: DripTheme.cosmicTeal.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: on ? DripTheme.cosmicTeal : DripTheme.warmWhite,
                ),
                backgroundColor: DripTheme.surface,
              ),
            );
          }).toList(),
        );
      case 'transitions':
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          children: TransitionType.values.map((t) {
            final on = clip!.transitionIn == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t.name, style: const TextStyle(fontSize: 11)),
                selected: on,
                onSelected: (_) => n.setTransition(t),
                selectedColor: DripTheme.cosmicTeal.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: on ? DripTheme.cosmicTeal : DripTheme.warmWhite,
                ),
                backgroundColor: DripTheme.surface,
              ),
            );
          }).toList(),
        );
      case 'audio':
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('VOLUME', style: TextStyle(fontSize: 10, color: DripTheme.muted)),
              Expanded(
                child: Slider(
                  value: clip!.volume,
                  onChanged: (v) => n.updateClip(clip.copyWith(volume: v)),
                  activeColor: DripTheme.cosmicTeal,
                ),
              ),
            ],
          ),
        );
      case 'memory':
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHARACTER  ·  ${clip!.characterName ?? '—'}',
                  style: const TextStyle(fontSize: 12, color: DripTheme.warmWhite)),
              const SizedBox(height: 6),
              Text('LOCATION  ·  ${clip.locationName ?? '—'}',
                  style: const TextStyle(fontSize: 12, color: DripTheme.chrome)),
              const SizedBox(height: 6),
              Text('CAMERA  ·  ${clip.styleNote ?? '—'}',
                  style: const TextStyle(fontSize: 11, color: DripTheme.muted)),
              const SizedBox(height: 6),
              Text('SCENE ID  ·  ${clip.sceneId ?? '—'}',
                  style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
            ],
          ),
        );
      case 'text':
        return Padding(
          padding: const EdgeInsets.all(12),
          child: CinematicButton(
            label: 'ADD TITLE AT PLAYHEAD',
            icon: Icons.title,
            onPressed: () {
              final id = 'txt_${DateTime.now().millisecondsSinceEpoch}';
              final texts = [
                ...bay.project.texts,
                TextOverlay(
                  id: id,
                  text: 'TITLE',
                  startSec: bay.project.playheadSec,
                ),
              ];
              // Direct state via notifier save path
              ref.read(editBayProvider.notifier).loadProject(
                    bay.project.copyWith(texts: texts, dirty: true),
                  );
            },
          ),
        );
      case 'color':
      default:
        final a = clip!.adjustments;
        Widget slider(String label, double value, void Function(double) on) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 88,
                  child: Text(label,
                      style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
                ),
                Expanded(
                  child: Slider(
                    value: value.clamp(-1, 1),
                    min: -1,
                    max: 1,
                    onChanged: on,
                    activeColor: DripTheme.cosmicTeal,
                    inactiveColor: Colors.white12,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          children: [
            slider('EXPOSURE', a.exposure,
                (v) => n.setAdjustment((x) => x.copyWith(exposure: v))),
            slider('CONTRAST', a.contrast,
                (v) => n.setAdjustment((x) => x.copyWith(contrast: v))),
            slider('SATURATION', a.saturation,
                (v) => n.setAdjustment((x) => x.copyWith(saturation: v))),
            slider('TEMPERATURE', a.temperature,
                (v) => n.setAdjustment((x) => x.copyWith(temperature: v))),
            slider('VIGNETTE', a.vignette,
                (v) => n.setAdjustment((x) => x.copyWith(vignette: v))),
            slider('LETTERBOX', a.letterbox,
                (v) => n.setAdjustment((x) => x.copyWith(letterbox: v))),
          ],
        );
    }
  }
}
