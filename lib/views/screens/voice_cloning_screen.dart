import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';

class VoiceCloningScreen extends ConsumerStatefulWidget {
  const VoiceCloningScreen({super.key});

  @override
  ConsumerState<VoiceCloningScreen> createState() => _VoiceCloningScreenState();
}

class _VoiceCloningScreenState extends ConsumerState<VoiceCloningScreen> {
  bool _busy = false;
  String? _error;
  String? _status;
  int _remaining = 1;

  Future<void> _clone() async {
    if (_remaining <= 0) {
      setState(() => _error = 'Free limit reached. Upgrade for unlimited cloning.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Locking voice DNA...';
    });
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _busy = false;
        _remaining--;
        _status = 'Voice DNA locked to character.';
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e.toString();
        _status = null;
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 64, color: DripTheme.teal),
            const SizedBox(height: 16),
            Text('Remaining free clones: $_remaining', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Unlimited on paid tiers', style: TextStyle(color: DripTheme.teal)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DripTheme.teal,
                  foregroundColor: Colors.black,
                ),
                onPressed: _busy ? null : _clone,
                child: _busy
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('CLONE VOICE'),
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, style: const TextStyle(color: DripTheme.teal)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              TextButton(onPressed: _clone, child: const Text('Retry', style: TextStyle(color: DripTheme.teal))),
            ],
          ],
        ),
      ),
    );
  }
}
