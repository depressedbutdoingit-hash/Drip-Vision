import 'package:flutter/material.dart';

class CharacterDnaScreen extends StatelessWidget {
  const CharacterDnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Character DNA', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: ListView(
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
                    const Row(
                      children: [
                        Text('Isabella', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                        SizedBox(width: 6),
                        Icon(Icons.workspace_premium, color: Color(0xFF00E5C0), size: 16),
                      ],
                    ),
                    const Text('Lead Heroine', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00E5C0), width: 4),
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
