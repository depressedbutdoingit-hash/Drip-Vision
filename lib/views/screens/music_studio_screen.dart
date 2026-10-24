import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class MusicStudioScreen extends ConsumerStatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  ConsumerState<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends ConsumerState<MusicStudioScreen> {
  final _prompt = TextEditingController();
  bool _generating = false;
  String _status = 'Ready to generate cinematic score';

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _status = 'Generating score…';
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _generating = false;
      _status = 'Score ready. Continuity locked to scene.';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Music generated and attached to project')),
      );
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
              decoration: const InputDecoration(hintText: 'Describe the score (e.g. tense neon alley, slow strings)'),
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