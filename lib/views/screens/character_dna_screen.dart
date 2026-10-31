import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'universe_screen.dart';

class CharacterDnaScreen extends StatelessWidget {
  final Character? character;

  const CharacterDnaScreen({super.key, this.character});

  Character get _c => character ?? Character(
    id: 'isabella',
    name: 'Isabella',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    role: 'Lead Heroine',
    age: 29,
    height: "5'8\"",
    build: 'Athletic',
    eyeColor: 'Hazel',
    hairColor: 'Dark brown, wavy',
    voiceDescription: 'Confident, warm',
    wardrobeDNA: const ['luxury black dress', 'leather jacket', 'evening gown'],
    defaultStylePrompt: 'photorealistic, cinematic lighting',
    dna: CharacterDNA.empty(),
  );

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final score = c.healthScore.round();
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      body: Stack(
        children: [
          Positioned(top: -20, left: 40, child: _drip(28, 0.35)),
          Positioned(top: -10, right: 60, child: _drip(18, 0.25)),
          Positioned(top: 80, right: -8, child: _drip(14, 0.2)),
          Positioned(bottom: 120, left: -6, child: _drip(16, 0.18)),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text('Character DNA', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: c.avatarUrl.isNotEmpty
                                ? Image.network(c.avatarUrl, width: 150, height: 200, fit: BoxFit.cover)
                                : Container(width: 150, height: 200, color: const Color(0xFF12161A)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                                Text(c.role, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                const SizedBox(height: 16),
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF00E5C0), width: 4),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF00E5C0).withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('$score%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF00E5C0))),
                                ),
                                const SizedBox(height: 8),
                                Text(c.continuityLock ? 'Continuity\nLocked' : 'Continuity\nOpen', style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _check('Looks: ${c.hairColor}, ${c.eyeColor} eyes'),
                      _check('Voice: ${c.voiceDescription}'),
                      _check('Wardrobe: ${c.wardrobeDNA.length} outfits'),
                      _check('Build: ${c.build}, ${c.height}'),
                      _check('Style: ${c.defaultStylePrompt.isEmpty ? "Default" : c.defaultStylePrompt}'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00E5C0)),
                            foregroundColor: const Color(0xFF00E5C0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UniverseScreen())),
                          child: const Text('View Universe'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Recent Scenes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 10),
                      _sceneCard('Rooftop Escape', '00:15', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800'),
                      const SizedBox(height: 8),
                      _sceneCard('Neon Alley', '00:12', 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=800'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sceneCard(String title, String duration, String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Image.network(image, height: 120, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(duration, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drip(double size, double opacity) {
    return Container(
      width: size,
      height: size * 1.6,
      decoration: BoxDecoration(
        color: const Color(0xFF00E5C0).withOpacity(opacity),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          topRight: Radius.circular(size),
          bottomLeft: Radius.circular(size * 0.4),
          bottomRight: Radius.circular(size * 0.4),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5C0).withOpacity(opacity * 0.8), blurRadius: 18, spreadRadius: 2),
        ],
      ),
    );
  }

  Widget _check(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00E5C0), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
