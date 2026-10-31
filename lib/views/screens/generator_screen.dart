import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final _promptController = TextEditingController(
    text: 'Isabella walks into the neon-lit alley, leather jacket catching the rain.',
  );
  bool _isGenerating = false;
  String _status = 'Ready';
  String? _image;
  String? _script;

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _status = 'Generating...';
      _image = null;
      _script = null;
    });

    try {
      final openRouter = ref.read(openRouterProvider);
      final ai = ref.read(aiGenerationServiceProvider);
      final script = await openRouter.generateText(
        'Write a short cinematic scene for: $prompt',
      );
      final image = await ai.generateImage(
        prompt: '$prompt, cinematic, professional lighting',
        quality: 'standard',
      );

      setState(() {
        _isGenerating = false;
        _status = 'Done';
        _script = script;
        _image = image;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _status = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Studio')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _image!.startsWith('http')
                  ? Image.network(_image!, height: 200, fit: BoxFit.cover)
                  : Image.asset(_image!, height: 200, fit: BoxFit.cover),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: DripTheme.gunmetal,
              ),
              child: const Center(
                child: Icon(Icons.movie_outlined, size: 48, color: Colors.white38),
              ),
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _promptController,
            maxLines: 4,
            style: DripTheme.body,
            decoration: const InputDecoration(
              hintText: 'Describe the scene.',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isGenerating ? null : _generate,
            child: _isGenerating
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('GENERATE'),
          ),
          const SizedBox(height: 16),
          Text(_status, textAlign: TextAlign.center, style: DripTheme.meta),
          if (_script != null) ...[
            const SizedBox(height: 16),
            Text(_script!, style: const TextStyle(color: Colors.white, height: 1.4)),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
