import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character.dart';

class CharacterProfileScreen extends ConsumerWidget {
  final Character character;

  const CharacterProfileScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(continuityEngineProvider);
    final score = engine.getHealthScore(character.id);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('Character Profile'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Edit Profile', style: TextStyle(color: DripTheme.teal)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    character.avatarUrl,
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 160,
                      color: DripTheme.gunmetal,
                      child: const Icon(Icons.person, size: 48, color: DripTheme.silver),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(character.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (character.locked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: DripTheme.teal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Locked', style: TextStyle(fontSize: 11, color: DripTheme.teal)),
                            ),
                        ],
                      ),
                      Text(character.role, style: DripTheme.meta),
                      const SizedBox(height: 12),
                      Text(
                        '${character.name} is a strong, independent woman with a mysterious past. She\'s intelligent, loyal, and never backs down.',
                        style: DripTheme.body.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoRow('Age', '${character.age}'),
            _InfoRow('Height', character.height),
            _InfoRow('Build', character.build),
            _InfoRow('Eye Color', character.eyeColor),
            _InfoRow('Hair Color', character.hairColor),
            _InfoRow('Voice', character.voiceDescription),
            const SizedBox(height: 28),
            const Text('Identity DNA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _DNARow('Face', character.dna.face, character.locked),
            _DNARow('Body', character.dna.body, character.locked),
            _DNARow('Wardrobe', character.dna.wardrobe, character.locked),
            _DNARow('Voice', character.dna.voice, character.locked),
            _DNARow('Style', character.dna.style, character.locked),
            const SizedBox(height: 28),
            const Text('Wardrobe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: character.wardrobeDNA.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: DripTheme.gunmetal,
                    border: Border.all(color: DripTheme.teal.withOpacity(0.3)),
                  ),
                  child: Center(child: Text(character.wardrobeDNA[i], style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(side: const BorderSide(color: DripTheme.teal)),
                child: const Text('Add to Wardrobe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: DripTheme.meta)),
          Text(value, style: DripTheme.body),
        ],
      ),
    );
  }
}

class _DNARow extends StatelessWidget {
  final String label;
  final double value;
  final bool locked;
  const _DNARow(this.label, this.value, this.locked);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: DripTheme.meta)),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: DripTheme.gunmetalLight,
              color: DripTheme.teal,
              minHeight: 4,
            ),
          ),
          const SizedBox(width: 12),
          Icon(locked ? Icons.lock : Icons.lock_open, size: 16, color: locked ? DripTheme.teal : DripTheme.silver),
        ],
      ),
    );
  }
}