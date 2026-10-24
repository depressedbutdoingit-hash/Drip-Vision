import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'character_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200'),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Your Cinematic Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          const Center(child: Text('Universe locked • Continuity active', style: TextStyle(color: DripTheme.teal))),
          const SizedBox(height: 24),
          const Text('Your Films', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(9, (i) => Container(
              decoration: BoxDecoration(
                color: DripTheme.gunmetal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DripTheme.teal.withOpacity(0.25)),
              ),
              child: Center(child: Text('Scene ${i + 1}', style: const TextStyle(fontSize: 12))),
            )),
          ),
          const SizedBox(height: 28),
          const Text('Characters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...universe.characters.map((c) => ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(c.avatarUrl)),
            title: Text(c.name),
            subtitle: Text('${c.role} • ${c.wardrobeDNA.length} outfits'),
            trailing: const Icon(Icons.chevron_right, color: DripTheme.silver),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CharacterProfileScreen(character: c)),
            ),
          )),
        ],
      ),
    );
  }
}