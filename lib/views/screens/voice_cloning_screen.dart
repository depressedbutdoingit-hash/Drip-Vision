import 'package:flutter/material.dart';

class VoiceCloningScreen extends StatelessWidget {
  const VoiceCloningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VOICE CLONING')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('1 per week on free tier\nUnlimited on paid', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Voice cloned! DNA locked for all scenes')),
              ),
              child: const Text('CLONE VOICE (1/week free)'),
            ),
          ],
        ),
      ),
    );
  }
}