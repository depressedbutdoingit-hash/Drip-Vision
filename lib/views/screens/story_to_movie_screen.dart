import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'studio_screen.dart';

class StoryToMovieScreen extends ConsumerWidget {
  const StoryToMovieScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('STORY TO MOVIE')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie_filter, size: 64, color: DripTheme.teal),
              const SizedBox(height: 24),
              const Text(
                'One prompt = entire short film\nwith perfect continuity',
                style: TextStyle(fontSize: 20, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Opens the Studio where you generate scene-by-scene with the Continuity Engine.',
                style: TextStyle(color: DripTheme.silver),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DripVisionStudioScreen()),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('OPEN STUDIO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
