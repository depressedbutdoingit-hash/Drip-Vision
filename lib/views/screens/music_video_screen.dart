import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/generation_history_service.dart';
import 'video_player_screen.dart';

class MusicVideoScreen extends ConsumerStatefulWidget {
  const MusicVideoScreen({super.key});

  @override
  ConsumerState<MusicVideoScreen> createState() => _MusicVideoScreenState();
}

class _MusicVideoScreenState extends ConsumerState<MusicVideoScreen> {
  final _direction = TextEditingController();
  String _style = 'Cinematic Neon';
  bool _loading = false;
  String? _result;
  String? _error;

  static const _styles = ['Cinematic Neon', 'Film Grain Noir', 'High Fashion', 'Dreamlike', 'Moody Drama'];

  @override
  void dispose() {
    _direction.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final text = _direction.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Describe the visual direction.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final service = ref.read(openRouterProvider);
      final script = await service.generateText(
        'Write a 4-section music video treatment for: $text. Style: $_style. Format as Intro / Verse / Chorus / Bridge with short visual descriptions.',
      );
      if (!mounted) return;
      ref.read(generationHistoryProvider.notifier).add(
        GeneratedScene(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text.length > 40 ? '${text.substring(0, 40)}...' : text,
          prompt: text,
          createdAt: DateTime.now(),
          mode: 'Music Video',
        ),
      );
      setState(() {
        _loading = false;
        _result = script;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Music Video')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _direction,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Visual direction (e.g. neon alley, slow strings, close-ups)',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Style', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _styles.map((s) {
              final selected = s == _style;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => setState(() => _style = s),
                selectedColor: DripTheme.teal,
                labelStyle: TextStyle(color: selected ? Colors.black : Colors.white70),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DripTheme.teal,
                foregroundColor: Colors.black,
              ),
              onPressed: _loading ? null : _generate,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('GENERATE TREATMENT'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            TextButton(onPressed: _generate, child: const Text('Retry', style: TextStyle(color: DripTheme.teal))),
          ],
          if (_result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DripTheme.gunmetal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_result!, style: const TextStyle(color: Colors.white70, height: 1.4)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VideoPlayerScreen(
                    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                    title: 'Preview',
                  ),
                ),
              ),
              child: const Text('Preview sample'),
            ),
          ],
        ],
      ),
    );
  }
}
