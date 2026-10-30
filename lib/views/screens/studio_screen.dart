import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'generator_screen.dart';
import 'music_video_screen.dart';
import '../../core/app_providers.dart';
import '../../core/continuity_providers.dart';
import '../widgets/drip_logo.dart';

class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final tokens = profile?.tokenBalance ?? 0;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    const DripLogo(compact: true, size: 28),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: DripTheme.surfaceRaised.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: DripTheme.hairlineStrong.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: DripTheme.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('D', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$tokens',
                            style: const TextStyle(
                              color: DripTheme.pearl,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DripTheme.radiusXl),
                child: SizedBox(
                  height: 280,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x66000000),
                              Color(0xCC000000),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            const Text(
                              'VISION\nIS',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 0.95,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              'EVERYTHING.',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: DripTheme.teal,
                                height: 0.95,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Write. Generate. Direct.\nStories that transcend.',
                              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _HeroButton(
                                  icon: Icons.play_arrow,
                                  label: 'New Drip',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const GeneratorScreen()),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _HeroButton(
                                  icon: Icons.music_note,
                                  label: 'Music Video',
                                  outlined: true,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MusicVideoScreen()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  const Text('YOUR PROJECTS', style: DripTheme.overline),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('VIEW ALL', style: TextStyle(color: DripTheme.teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final titles = ['Echoes in the Static', 'Neon Requiem', 'The Last Light', 'Broken Crown'];
                  final statuses = ['IN PRODUCTION', 'GENERATING', 'COMPLETED', 'IN QUEUE'];
                  return _LuxuryProjectCard(
                    title: titles[i],
                    status: statuses[i],
                    image: 'https://picsum.photos/id/${i + 20}/400/300',
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _HeroButton({required this.icon, required this.label, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : DripTheme.teal,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white54),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: outlined ? Colors.white : Colors.black),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: outlined ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryProjectCard extends StatelessWidget {
  final String title;
  final String status;
  final String image;

  const _LuxuryProjectCard({required this.title, required this.status, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DripTheme.radiusLg),
        border: Border.all(color: DripTheme.hairline.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(image, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xDD000000)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DripTheme.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: DripTheme.teal.withOpacity(0.4)),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: DripTheme.teal, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef DripVisionStudioScreen = StudioHomeScreen;
