import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../core/theme.dart';
import '../../services/suno_service.dart';

class MusicStudioScreen extends ConsumerStatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  ConsumerState<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends ConsumerState<MusicStudioScreen> {
  final _prompt = TextEditingController();
  bool _generating = false;
  String _status = 'Ready to generate cinematic score';
  SunoTrack? _track;

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
      _status = 'Generating score…';
      _track = null;
    });

    try {
      final service = SunoService(Env.sunoApiKey);
      final track = await service.generateForScene(
        sceneDescription: prompt,
        sceneMood: 'cinematic',
        lighting: '',
        duration: 30,
      );
      setState(() {
        _track = track;
        _status = 'Score ready: ${track.title}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Music Studio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: DripTheme.gunmetal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(Icons.music_note, size: 56, color: DripTheme.teal)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _prompt,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe the score (e.g. tense neon alley, slow strings)',
                hintStyle: TextStyle(color: DripTheme.faint),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generating ? null : _generate,
              child: _generating
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('GENERATE SCORE'),
            ),
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center, style: DripTheme.meta),
            if (_track != null && _track!.audioUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              SelectableText(
                _track!.audioUrl,
                style: const TextStyle(color: DripTheme.teal, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }
}
