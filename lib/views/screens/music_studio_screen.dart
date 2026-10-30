import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/env.dart';
import '../../core/theme.dart';
import '../../services/lyria_service.dart';

class MusicStudioScreen extends ConsumerStatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  ConsumerState<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends ConsumerState<MusicStudioScreen> {
  final _prompt = TextEditingController();
  final _player = AudioPlayer();
  bool _generating = false;
  String _status = 'Ready to generate cinematic score';
  LyriaTrack? _track;

  @override
  void dispose() {
    _prompt.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _prompt.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the score first')),
      );
      return;
    }

    setState(() {
      _generating = true;
      _status = 'Generating with Lyria…';
      _track = null;
    });

    try {
      final service = LyriaService(Env.openRouterKey);
      final track = await service.generateScore(
        prompt: prompt,
        style: 'cinematic',
        durationSeconds: 60,
      );
      setState(() {
        _track = track;
        _status = 'Score ready';
      });
    } catch (e) {
      setState(() => _status = 'Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _play() async {
    if (_track == null) return;
    try {
      await _player.setFilePath(_track!.audioUrl);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('MUSIC STUDIO', style: DripTheme.overline)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: DripTheme.surface,
                borderRadius: BorderRadius.circular(DripTheme.radiusXl),
                border: Border.all(color: DripTheme.hairline),
              ),
              child: const Center(
                child: Icon(Icons.music_note, size: 56, color: DripTheme.teal),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _prompt,
              maxLines: 4,
              style: const TextStyle(color: DripTheme.warmWhite, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Describe the score (tense neon alley, slow strings, low drone)',
                hintStyle: const TextStyle(color: DripTheme.muted),
                filled: true,
                fillColor: DripTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                  borderSide: const BorderSide(color: DripTheme.hairline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                  borderSide: const BorderSide(color: DripTheme.hairline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                  borderSide: const BorderSide(color: DripTheme.teal),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generating ? null : _generate,
              child: _generating
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('GENERATE SCORE'),
            ),
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center, style: DripTheme.meta),
            if (_track != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _play,
                icon: const Icon(Icons.play_arrow),
                label: const Text('PLAY SCORE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DripTheme.teal,
                  side: const BorderSide(color: DripTheme.teal),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
