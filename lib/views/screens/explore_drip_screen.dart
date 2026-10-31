import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/generation_history_service.dart';
import 'video_player_screen.dart';

class ExploreDripScreen extends ConsumerWidget {
  const ExploreDripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(generationHistoryProvider);
    final public = history.where((s) => s.isPublic && (s.videoUrl?.isNotEmpty ?? false)).toList();

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Explore')),
      body: public.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public_off, color: Colors.white24, size: 48),
                    const SizedBox(height: 16),
                    const Text('No public drips yet', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      'Make a scene public in Universe to see it here.',
                      style: TextStyle(color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: public.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final scene = public[i];
                return ListTile(
                  tileColor: const Color(0xFF12161A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: const Icon(Icons.play_circle_fill, color: DripTheme.teal),
                  title: Text(scene.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(scene.mode, style: const TextStyle(color: Colors.white54)),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(videoUrl: scene.videoUrl!, title: scene.title),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
