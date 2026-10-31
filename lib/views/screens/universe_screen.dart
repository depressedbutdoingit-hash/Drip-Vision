import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/generation_history_service.dart';
import 'video_player_screen.dart';
import 'create_drip_screen.dart';

class UniverseScreen extends ConsumerWidget {
  const UniverseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(generationHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Universe', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_outlined, color: Colors.white24, size: 48),
                    const SizedBox(height: 16),
                    const Text('No scenes yet', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Generate a scene and it will appear here.', style: TextStyle(color: Colors.white38), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5C0),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDripScreen())),
                      child: const Text('Create Your First Drip'),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final scene = history[i];
                return GestureDetector(
                  onTap: () {
                    if (scene.videoUrl != null && scene.videoUrl!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: scene.videoUrl!, title: scene.title)),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: const Color(0xFF12161A)),
                        if (scene.imageUrl != null && scene.imageUrl!.startsWith('http'))
                          Image.network(scene.imageUrl!, fit: BoxFit.cover)
                        else
                          const Center(child: Icon(Icons.movie_outlined, color: Colors.white24, size: 32)),
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
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => ref.read(generationHistoryProvider.notifier).remove(scene.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
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
                              Text(scene.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              Text(scene.mode, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
