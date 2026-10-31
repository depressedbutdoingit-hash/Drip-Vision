import 'package:flutter/material.dart';

class UniverseScreen extends StatelessWidget {
  const UniverseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('The Last Goodbye', '24 Scenes', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600'),
      ('Baja Dreams', '18 Scenes', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600'),
      ('Love & Chaos', '32 Scenes', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600'),
      ('The Return', '27 Scenes', 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Universe', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final (title, sub, img) = items[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(img, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
