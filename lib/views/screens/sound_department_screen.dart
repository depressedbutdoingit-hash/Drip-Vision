import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/scene.dart';
import '../../services/suno_service.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import 'music_studio_screen.dart';

/// SOUND DEPARTMENT
/// MUSIC and AMBIENCE both call the real Suno integration — ambience is
/// simply a differently-directed prompt (soundscape, no melody) through
/// the same generateForScene() your Music Studio already uses, not a
/// second faked pipeline. SFX has no generation backend in this codebase
/// yet, so it's an honest manual cue list rather than a fake "Generate"
/// button with nothing behind it. MIX SCENE persists everything onto the
/// real SceneNode via sceneListProvider.
class SoundDepartmentScreen extends ConsumerStatefulWidget {
  final SceneNode scene;
  const SoundDepartmentScreen({super.key, required this.scene});

  @override
  ConsumerState<SoundDepartmentScreen> createState() => _SoundDepartmentScreenState();
}

class _SoundDepartmentScreenState extends ConsumerState<SoundDepartmentScreen> {
  late SunoTrack? _music = widget.scene.musicTrackUrl != null
      ? SunoTrack(id: 'existing', title: widget.scene.musicTitle ?? 'Score', audioUrl: widget.scene.musicTrackUrl!, genre: '', durationSeconds: 0)
      : null;
  late final _ambienceCtl = TextEditingController(text: widget.scene.ambienceNotes ?? '');
  late List<String> _sfx = [...widget.scene.sfxCues];
  final _sfxCtl = TextEditingController();

  bool _generatingMusic = false;
  bool _generatingAmbience = false;
  bool _playing = false;
  late String? _ambienceTrackUrl = widget.scene.ambienceTrackUrl;

  @override
  void dispose() {
    _ambienceCtl.dispose();
    _sfxCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('SOUND DEPARTMENT', style: TextStyle(fontSize: 12, letterSpacing: 3))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(scene.locationName?.toUpperCase() ?? 'SCENE', style: const TextStyle(fontSize: 10, letterSpacing: 2.4, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(scene.prompt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),

              const Text('MUSIC', style: TextStyle(fontSize: 9.5, letterSpacing: 2.2, color: DripTheme.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 9),
              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_music != null) ...[
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill, color: DripTheme.cosmicTeal, size: 34),
                            onPressed: () => _togglePlay(_music!.audioUrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_music!.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (_generatingMusic)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)), SizedBox(width: 10), Text('Scoring the scene…', style: TextStyle(color: DripTheme.muted))]))
                    else
                      CinematicButton(label: _music == null ? 'GENERATE MUSIC' : 'REGENERATE MUSIC', icon: Icons.music_note_outlined, primary: _music == null, onPressed: _generateMusic),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text('AMBIENCE', style: TextStyle(fontSize: 9.5, letterSpacing: 2.2, color: DripTheme.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 9),
              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: _ambienceCtl, style: const TextStyle(color: DripTheme.warmWhite), maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. Heavy rain, distant traffic, electrical buzz')),
                    const SizedBox(height: 10),
                    if (_generatingAmbience)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Row(children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.cosmicTeal)), SizedBox(width: 10), Text('Building the soundscape…', style: TextStyle(color: DripTheme.muted))]))
                    else
                      CinematicButton(label: 'GENERATE AMBIENCE', icon: Icons.waves_outlined, primary: false, onPressed: _generateAmbience),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text('SFX', style: TextStyle(fontSize: 9.5, letterSpacing: 2.2, color: DripTheme.muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 9),
              CinematicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_sfx.isEmpty) const Text('No cues added yet.', style: TextStyle(color: DripTheme.muted)),
                    if (_sfx.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _sfx.map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.white.withOpacity(.05),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => setState(() => _sfx.remove(s)),
                            )).toList(),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _sfxCtl, style: const TextStyle(color: DripTheme.warmWhite), decoration: const InputDecoration(hintText: 'e.g. Footsteps'), onSubmitted: (_) => _addSfx())),
                        IconButton(onPressed: _addSfx, icon: const Icon(Icons.add_circle_outline, color: DripTheme.cosmicTeal)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              CinematicButton(
                label: 'MIX SCENE',
                icon: Icons.graphic_eq_outlined,
                onPressed: _mixScene,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSfx() {
    final v = _sfxCtl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      _sfx.add(v);
      _sfxCtl.clear();
    });
  }

  Future<void> _togglePlay(String url) async {
    final player = ref.read(musicPlayerProvider);
    if (_playing) {
      await player.pause();
    } else {
      await player.play(UrlSource(url));
    }
    setState(() => _playing = !_playing);
  }

  Future<void> _generateMusic() async {
    setState(() => _generatingMusic = true);
    try {
      final track = await ref.read(sunoServiceProvider).generateForScene(
            sceneDescription: widget.scene.prompt,
            sceneMood: widget.scene.lighting ?? 'cinematic',
            lighting: widget.scene.lighting ?? '',
            duration: 30,
          );
      setState(() => _music = track);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Music generation failed: $e')));
    } finally {
      if (mounted) setState(() => _generatingMusic = false);
    }
  }

  Future<void> _generateAmbience() async {
    setState(() => _generatingAmbience = true);
    try {
      final desc = _ambienceCtl.text.trim().isEmpty ? '${widget.scene.locationDescription ?? widget.scene.prompt}, ambient background only, no melody, no instruments' : '${_ambienceCtl.text.trim()}, ambient soundscape, no melody, no instruments';
      final track = await ref.read(sunoServiceProvider).generateForScene(
            sceneDescription: desc,
            sceneMood: 'ambient soundscape',
            lighting: '',
            duration: 30,
          );
      setState(() => _ambienceTrackUrl = track.audioUrl);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ambience track generated — attached on Mix Scene.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ambience generation failed: $e')));
    } finally {
      if (mounted) setState(() => _generatingAmbience = false);
    }
  }

  void _mixScene() {
    final updated = widget.scene.copyWith(
      musicTrackUrl: _music?.audioUrl,
      musicTitle: _music?.title,
      ambienceNotes: _ambienceCtl.text.trim(),
      ambienceTrackUrl: _ambienceTrackUrl,
      sfxCues: _sfx,
    );
    ref.read(sceneListProvider.notifier).updateScene(updated);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scene mixed and saved.')));
    Navigator.pop(context);
  }
}
