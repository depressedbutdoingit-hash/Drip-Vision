import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../widgets/cinematic_card.dart';

class DirectorsBibleScreen extends ConsumerWidget {
  const DirectorsBibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universe = ref.watch(universeProvider); // continuity health + DNA

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('DIRECTOR’S BIBLE'),
        backgroundColor: DripTheme.voidBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIVE UNIVERSE HEALTH', style: DripTheme.technical),
            const SizedBox(height: 8),
            Text(
              universe.healthScore > 90 ? 'PERFECT' : universe.healthScore > 70 ? 'GOOD' : 'NEEDS WORK',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: universe.healthScore > 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            ...universe.characters.map((char) => CinematicCard(
                  child: Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(char.avatarUrl)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(char.name, style: DripTheme.title),
                            Text('${char.war drobeDNA.length} wardrobe items', style: DripTheme.meta),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: DripTheme.muted),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}