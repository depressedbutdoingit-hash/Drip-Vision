import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme.dart';
import '../../services/voice_cloning_service.dart';

class VoiceCloningScreen extends ConsumerStatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  ConsumerState<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends ConsumerState<VoiceCloningScreen> {
  final _textController = TextEditingController();
  bool _busy = false;
  String? _status;
  Uint8List? _audioBytes;

  Future<void> _generate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter text to speak')),
      );
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Generating speech…';
      _audioBytes = null;
    });

    try {
      final service = ref.read(voiceCloningServiceProvider);
      final bytes = await service.generateSpeech(text: text);
      setState(() {
        _audioBytes = bytes;
        _status = 'Speech ready';
      });
    } catch (e) {
      setState(() => _status = 'Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveAudio() async {
    if (_audioBytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/drip_voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await file.writeAsBytes(_audioBytes!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Voice Cloning')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mic, size: 56, color: DripTheme.teal),
            const SizedBox(height: 16),
            const Text(
              'Generate speech with OpenRouter TTS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Uses your OPENROUTER_KEY. No separate ElevenLabs account required.',
              style: TextStyle(color: DripTheme.silver, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter text to speak…',
                hintStyle: TextStyle(color: DripTheme.faint),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _generate,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('GENERATE SPEECH'),
            ),
            const SizedBox(height: 16),
            if (_status != null)
              Text(_status!, textAlign: TextAlign.center, style: DripTheme.meta),
            if (_audioBytes != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveAudio,
                icon: const Icon(Icons.save),
                label: const Text('SAVE AUDIO'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
