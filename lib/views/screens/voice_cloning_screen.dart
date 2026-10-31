import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class VoiceCloningScreen extends ConsumerStatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  ConsumerState<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends ConsumerState<VoiceCloningScreen> {
  final _line = TextEditingController(text: 'This is my voice. Locked to the character.');
  final _player = AudioPlayer();
  String _voice = 'sarah';
  bool _busy = false;
  String? _error;
  String? _status;
  String? _filePath;

  static const _voices = ['sarah', 'george', 'adam', 'alice', 'bella', 'brian', 'jessica', 'daniel'];

  @override
  void dispose() {
    _line.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    final text = _line.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Enter a line to speak.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Generating with ElevenLabs via OpenRouter...';
    });
    try {
      final bytes = await ref.read(openRouterProvider).speak(text: text, voice: _voice);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _filePath = file.path;
        _status = 'Voice ready. Tap play.';
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
        _status = null;
      });
    }
  }

  Future<void> _play() async {
    if (_filePath == null) return;
    await _player.play(DeviceFileSource(_filePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Voice Clone')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.mic, size: 56, color: DripTheme.teal),
          const SizedBox(height: 12),
          const Text(
            'ElevenLabs voices through OpenRouter. Custom clones need your own ElevenLabs key (BYOK).',
            style: TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _line,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Line to speak',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Voice', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _voices.map((v) {
              final selected = v == _voice;
              return ChoiceChip(
                label: Text(v),
                selected: selected,
                onSelected: (_) => setState(() => _voice = v),
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
              onPressed: _busy ? null : _speak,
              child: _busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('GENERATE VOICE'),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: const TextStyle(color: DripTheme.teal)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            TextButton(onPressed: _speak, child: const Text('Retry', style: TextStyle(color: DripTheme.teal))),
          ],
          if (_filePath != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _play,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
          ],
        ],
      ),
    );
  }
}
