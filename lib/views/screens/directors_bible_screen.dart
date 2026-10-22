import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import 'continuity_health_screen.dart';

class DirectorsBibleScreen extends ConsumerWidget {
  const DirectorsBibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('DIRECTOR’S BIBLE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LIVE UNIVERSE HEALTH', style: DripTheme.technical),
            const SizedBox(height: 8),
            Text(
              universe.healthScore > 90
                  ? 'PERFECT'
                  : universe.healthScore > 70
                      ? 'GOOD'
                      : 'NEEDS WORK',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: universe.healthScore > 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            if (universe.characters.isEmpty)
              const Text('No characters yet.', style: DripTheme.meta),
            ...universe.characters.map((char) {
              final score = characterHealth(char);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: char.avatarUrl.isEmpty
                      ? null
                      : NetworkImage(char.avatarUrl),
                  child: char.avatarUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  char.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${char.wardrobeDNA.length} wardrobe items • Health: $score%',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContinuityHealthScreen(),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}