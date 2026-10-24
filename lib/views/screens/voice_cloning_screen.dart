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
  int _remaining = 1;

  Future<void> _clone() async {
    if (_remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Free limit reached. Upgrade for unlimited cloning.')),
      );
      return;
    }
    setState(() => _busy = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _busy = false;
      _remaining--;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice DNA cloned and locked to character')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Voice Cloning')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 64, color: DripTheme.teal),
              const SizedBox(height: 16),
              Text('Remaining free clones this week: $_remaining', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Unlimited on paid tiers', style: TextStyle(color: DripTheme.teal)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _busy ? null : _clone,
                child: _busy
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('CLONE VOICE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}