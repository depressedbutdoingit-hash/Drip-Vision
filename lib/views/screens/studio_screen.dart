import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'generator_screen.dart';
import 'music_video_screen.dart';

class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: DripTheme.voidBlack,
              title: const Text('DRIPVISION', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: DripTheme.teal,
                    child: const Icon(Icons.person, size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0B0F14), Color(0xFF1A2A30)],
                        ),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1485846234645-a62644f84728?w=800'),
                          fit: BoxFit.cover,
                          opacity: 0.6,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20,
                            bottom: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Universe.\nYour Rules.',
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'AI filmmaking that remembers your characters, your worlds, and your story.',
                                  style: DripTheme.meta.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const GeneratorScreen()),
                                      ),
                                      child: const Text('New Drip'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const MusicVideoScreen()),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: DripTheme.teal),
                                        foregroundColor: DripTheme.teal,
                                      ),
                                      child: const Text('Music Video'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Recent Projects', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => _ProjectCard(
                          title: ['The Last Heist', 'Scarlet & Stone', 'Ocean Hearts', 'Broken Crown'][i],
                          status: ['Rendering...', 'Edited 2h ago', 'Completed', 'In Progress'][i],
                          image: 'https://picsum.photos/id/${i + 10}/200/300',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final String status;
  final String image;

  const _ProjectCard({required this.title, required this.status, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: DripTheme.gunmetal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(image, height: 80, width: 120, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(status, style: DripTheme.meta.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}