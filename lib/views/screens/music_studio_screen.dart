import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class MusicStudioScreen extends ConsumerStatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  ConsumerState<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends ConsumerState<MusicStudioScreen> {
  final _prompt = TextEditingController();
  bool _generating = false;
  String? _result;
  String? _error;

  Future<void> _generate() async {
    final text = _prompt.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Describe the score.');
      return;
    }
    setState(() {
      _generating = true;
      _error = null;
      _result = null;
    });
    try {
      final service = ref.read(openRouterProvider);
      final score = await service.generateText(
        'Write a short cinematic score direction for: $text. Include mood, instruments, tempo, and how it should evolve over 30 seconds.',
      );
      if (!mounted) return;
      setState(() {
        _generating = false;
        _result = score;
      });
    } catch (e) {
      setState(() {
        _generating = false;
        _error = e.toString();
      });
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
              height: 120,
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
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DripTheme.teal,
                foregroundColor: Colors.black,
              ),
              onPressed: _generating ? null : _generate,
              child: _generating
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('GENERATE SCORE'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              TextButton(onPressed: _generate, child: const Text('Retry', style: TextStyle(color: DripTheme.teal))),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DripTheme.gunmetal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(_result!, style: const TextStyle(color: Colors.white70, height: 1.4)),
                  ),
                ),
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
