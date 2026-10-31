import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class VoiceCloningScreen extends ConsumerStatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  ConsumerState<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends ConsumerState<VoiceCloningScreen> {
  final _line = TextEditingController(text: 'This is a test of my cloned voice.');
  final _transcript = TextEditingController(text: 'This is my voice sample.');
  final _player = AudioPlayer();
  final _recorder = AudioRecorder();
  String _voice = 'sarah';
  bool _busy = false;
  bool _recording = false;
  String? _error;
  String? _status;
  String? _samplePath;
  String? _resultPath;

  static const _voices = ['sarah', 'george', 'adam', 'alice', 'bella', 'brian', 'jessica', 'daniel'];

  @override
  void dispose() {
    _line.dispose();
    _transcript.dispose();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() {
        _recording = false;
        _samplePath = path;
        _status = 'Sample saved. Add the exact words you said, then Clone.';
      });
      return;
    }
    if (!await _recorder.hasPermission()) {
      setState(() => _error = 'Microphone permission denied.');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/sample_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _recording = true;
      _error = null;
      _status = 'Recording... speak clearly for 10-20 seconds.';
    });
  }

  Future<void> _speakPremade() async {
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
        _resultPath = file.path;
        _status = 'Premade voice ready.';
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
        _status = null;
      });
    }
  }

  Future<void> _clone() async {
    if (_samplePath == null) {
      setState(() => _error = 'Record a sample first.');
      return;
    }
    final text = _line.text.trim();
    final transcript = _transcript.text.trim();
    if (text.isEmpty || transcript.isEmpty) {
      setState(() => _error = 'Need a test line and the sample transcript.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Cloning with Fish Audio via OpenRouter...';
    });
    try {
      final sample = await File(_samplePath!).readAsBytes();
      final bytes = await ref.read(openRouterProvider).cloneSpeak(
        text: text,
        sampleBytes: sample,
        sampleTranscript: transcript,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/clone_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _resultPath = file.path;
        _status = 'Clone ready. Tap play to test.';
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
        _status = null;
      });
    }
  }

  Future<void> _play(String? path) async {
    if (path == null) return;
    await _player.play(DeviceFileSource(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Voice Clone')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _recording ? Colors.redAccent : DripTheme.teal,
                    foregroundColor: _recording ? Colors.white : Colors.black,
                  ),
                  onPressed: _busy ? null : _toggleRecord,
                  icon: Icon(_recording ? Icons.stop : Icons.mic),
                  label: Text(_recording ? 'Stop' : 'Record sample'),
                ),
              ),
              if (_samplePath != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _play(_samplePath),
                  icon: const Icon(Icons.play_arrow, color: DripTheme.teal),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _transcript,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Exact words you said in the sample',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _line,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Test line to speak in the clone',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DripTheme.teal,
                foregroundColor: Colors.black,
              ),
              onPressed: _busy || _samplePath == null ? null : _clone,
              child: _busy
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('CLONE AND TEST'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Or use a premade voice', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _speakPremade,
            child: const Text('Generate premade'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!, style: const TextStyle(color: DripTheme.teal)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (_resultPath != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _play(_resultPath),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play result'),
            ),
          ],
        ],
      ),
    );
  }
}
