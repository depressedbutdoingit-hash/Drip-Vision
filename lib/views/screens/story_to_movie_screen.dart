import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'generator_screen.dart';

class StoryToMovieScreen extends ConsumerWidget {
  const StoryToMovieScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('STORY TO MOVIE')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('One prompt = entire short film\nwith perfect continuity', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneratorScreen())),
              child: const Text('GENERATE FULL FILM (MAML + NaML)'),
            ),
          ],
        ),
      ),
    );
  }
}