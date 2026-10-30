import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'ad_generator_screen.dart';
import 'studio_screen.dart';
import 'timeline_screen.dart';
import 'style_dna_screen.dart';

class AppHubScreen extends StatelessWidget {
  const AppHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121416),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text('DRIPVISION', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4, color: Color(0xFF00FFAA))),
              const SizedBox(height: 8),
              const Text('AI Filmmaking Studio', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 40),
              _btn(context, 'ENTER STUDIO', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()))),
              const SizedBox(height: 12),
              _btn(context, 'AD GENERATOR', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdGeneratorScreen())), outline: true),
              const SizedBox(height: 12),
              _btn(context, 'TIMELINE', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen())), outline: true),
              const SizedBox(height: 12),
              _btn(context, 'STYLE DNA', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleDnaScreen())), outline: true),
              const SizedBox(height: 12),
              _btn(context, 'STUDIO', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DripVisionStudioScreen())), outline: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, VoidCallback onTap, {bool outline = false}) {
    return SizedBox(
      width: double.infinity,
      child: outline
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF00FFAA)), foregroundColor: const Color(0xFF00FFAA), padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: onTap,
              child: Text(label),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: onTap,
              child: Text(label),
            ),
    );
  }
}
