import 'package:flutter/material.dart';

class CharacterDnaScreen extends StatelessWidget {
  const CharacterDnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      body: Stack(
        children: [
          // Subtle glowing drips
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
                            child: Image.network(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                              width: 150,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Isabella', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                                const Text('Lead Heroine', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                                  child: const Text('98%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF00E5C0))),
                                ),
                                const SizedBox(height: 8),
                                const Text('Continuity\nLocked', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _check('Looks: Locked'),
                      _check('Voice: Cloned'),
                      _check('Wardrobe: 12 outfits'),
                      _check('Personality: Active'),
                      _check('Story Arc: In Sync'),
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
                          onPressed: () {},
                          child: const Text('View Her Universe'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Recent Scenes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Rooftop Escape', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  Text('00:15', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
          BoxShadow(
            color: const Color(0xFF00E5C0).withOpacity(opacity * 0.8),
            blurRadius: 18,
            spreadRadius: 2,
          ),
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
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
