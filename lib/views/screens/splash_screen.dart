import 'dart:async';
import 'package:flutter/material.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _total = 6;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_elapsed >= _total) return t.cancel();
      setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() => Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()));

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).primaryColor;
    final ready = _elapsed >= _total;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop, size: 96, color: teal),
              const SizedBox(height: 16),
              const Text('DripVision',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              LinearProgressIndicator(value: _elapsed / _total, color: teal),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: ready ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: ready ? _continue : null,
                  child: const Text('Tap to continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}