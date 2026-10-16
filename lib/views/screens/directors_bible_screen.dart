import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/continuity_service.dart';
import 'continuity_health_screen.dart';

class DirectorsBibleScreen extends ConsumerWidget {
  const DirectorsBibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(continuityEngineProvider);
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('DIRECTOR’S BIBLE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIVE UNIVERSE HEALTH', style: DripTheme.technical),
            const SizedBox(height: 8),
            Text(
              universe.healthScore > 90 ? 'PERFECT' : universe.healthScore > 70 ? 'GOOD' : 'NEEDS WORK',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: universe.healthScore > 70 ? Colors.green : Colors.orange),
            ),
            const SizedBox(height: 24),

            // Real MAML/NaML health score + characters
            ...universe.characters.map((char) {
              final score = engine.getHealthScore(char.id);
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(char.avatarUrl)),
                title: Text(char.name, style: DripTheme.title),
                subtitle: Text('${char.wardrobeDNA.length} wardrobe items • Health: ${score.toInt()}%'),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContinuityHealthScreen())),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}