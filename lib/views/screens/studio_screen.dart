import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'generator_screen.dart';
import 'music_video_screen.dart';
import 'ad_generator_screen.dart';
import 'timeline_screen.dart';
import 'style_dna_screen.dart';

class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0E),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFF0A0C0E),
              elevation: 0,
              title: const Text(
                'DRIPVISION',
                style: TextStyle(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: Color(0xFFE8E8E8),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00FFAA).withOpacity(0.4), width: 1),
                    ),
                    child: const Icon(Icons.person_outline, size: 16, color: Color(0xFF00FFAA)),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 240,
                        decoration: const BoxDecoration(
                          color: Color(0xFF111416),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&q=80',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    'YOUR UNIVERSE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF00FFAA),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Your Rules.',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      height: 1.05,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Cinematic AI that remembers your characters and worlds.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      _primaryBtn(context, 'New Drip', const GeneratorScreen()),
                                      const SizedBox(width: 10),
                                      _ghostBtn(context, 'Music Video', const MusicVideoScreen()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 148,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) => _ProjectCard(
                          title: ['The Last Heist', 'Scarlet & Stone', 'Ocean Hearts', 'Broken Crown'][i],
                          status: ['Rendering', 'Edited 2h ago', 'Completed', 'In Progress'][i],
                          image: 'https://picsum.photos/id/${i + 20}/400/500',
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'STUDIO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _toolTile(context, Icons.campaign_outlined, 'Ad Generator', 'Short-form commercial scripts', const AdGeneratorScreen()),
                    const SizedBox(height: 10),
                    _toolTile(context, Icons.movie_outlined, 'Timeline', 'Director\'s cut', const TimelineScreen()),
                    const SizedBox(height: 10),
                    _toolTile(context, Icons.palette_outlined, 'Style DNA', 'Save and reuse a look', const StyleDnaScreen()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryBtn(BuildContext context, String label, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFAA),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Text(label),
    );
  }

  Widget _ghostBtn(BuildContext context, String label, Widget screen) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF00FFAA), width: 1),
        foregroundColor: const Color(0xFF00FFAA),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3),
      ),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Text(label),
    );
  }

  Widget _toolTile(BuildContext context, IconData icon, String title, String subtitle, Widget screen) {
    return Material(
      color: const Color(0xFF14181C),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF00FFAA), size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
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
      width: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF14181C),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(image, height: 88, width: 128, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(status, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef DripVisionStudioScreen = StudioHomeScreen;
