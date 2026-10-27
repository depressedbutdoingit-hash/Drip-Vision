import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../widgets/token_status_bar.dart';
import 'character_profile_screen.dart';
import 'plans_screen.dart';
import '../../core/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: TokenStatusBar(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Header
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Cinematic Profile',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Universe locked • Continuity active',
                  style: DripTheme.meta.copyWith(color: DripTheme.teal),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DripTheme.gunmetal,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DripTheme.teal.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                const TokenStatusBar(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlansScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: DripTheme.teal),
                      foregroundColor: DripTheme.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Plans'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Films
          const Text(
            'Your Films',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: List.generate(
              9,
              (i) => Container(
                decoration: BoxDecoration(
                  color: DripTheme.gunmetal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Center(
                  child: Text(
                    'Scene ${i + 1}',
                    style: const TextStyle(fontSize: 12, color: DripTheme.silver),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Characters
          const Text(
            'Characters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...universe.characters.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(c.avatarUrl),
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${c.role} • ${c.wardrobeDNA.length} outfits',
                  style: DripTheme.meta,
                ),
                trailing: const Icon(Icons.chevron_right, color: DripTheme.silver),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CharacterProfileScreen(character: c),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}