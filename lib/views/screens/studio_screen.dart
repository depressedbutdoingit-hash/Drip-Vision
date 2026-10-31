import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/character.dart';
import '../../services/continuity_service.dart';
import 'generator_screen.dart';
import 'music_video_screen.dart';
import 'ad_generator_screen.dart';
import 'timeline_screen.dart';
import 'style_dna_screen.dart';
import 'character_dna_screen.dart';
import 'create_drip_screen.dart';
import 'universe_screen.dart';
import 'profile_premium_screen.dart';

class StudioHomeScreen extends ConsumerStatefulWidget {
  const StudioHomeScreen({super.key});

  @override
  ConsumerState<StudioHomeScreen> createState() => _StudioHomeScreenState();
}

class _StudioHomeScreenState extends ConsumerState<StudioHomeScreen> {
  int _tab = 0;
  int _nav = 0;

  static final _characters = [
    Character(
      id: 'isabella',
      name: 'Isabella',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      role: 'Lead Heroine',
      hairColor: 'Dark brown, wavy',
      eyeColor: 'Hazel',
      voiceDescription: 'Confident, warm',
      wardrobeDNA: const ['luxury black dress', 'leather jacket'],
      defaultStylePrompt: 'photorealistic, cinematic',
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'marcus',
      name: 'Marcus',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      role: 'Lead',
      hairColor: 'Short black',
      eyeColor: 'Brown',
      voiceDescription: 'Steady',
      wardrobeDNA: const ['dark coat'],
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'elena',
      name: 'Elena',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      role: 'Supporting',
      hairColor: 'Blonde',
      eyeColor: 'Blue',
      voiceDescription: 'Soft',
      wardrobeDNA: const ['white dress'],
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'rex',
      name: 'Rex',
      avatarUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200',
      role: 'Companion',
      hairColor: 'Tan',
      eyeColor: 'Brown',
      voiceDescription: 'N/A',
      wardrobeDNA: const ['collar'],
      dna: CharacterDNA.empty(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeBody(),
      const UniverseScreen(),
      const CreateDripScreen(),
      const UniverseScreen(),
      const ProfilePremiumScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      body: SafeArea(child: pages[_nav]),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _homeBody() {
    return Column(
      children: [
        _topBar(),
        _tabs(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _hero(),
              const SizedBox(height: 22),
              _section('Continue Where You Left Off'),
              const SizedBox(height: 10),
              _continueCard(),
              const SizedBox(height: 22),
              _section('Your Characters'),
              const SizedBox(height: 10),
              _charactersRow(),
              const SizedBox(height: 22),
              _section('Studio'),
              const SizedBox(height: 10),
              _tool(Icons.campaign_outlined, 'Ad Generator', 'Commercial scripts', const AdGeneratorScreen()),
              const SizedBox(height: 8),
              _tool(Icons.movie_outlined, 'Timeline', 'Director\'s cut', const TimelineScreen()),
              const SizedBox(height: 8),
              _tool(Icons.palette_outlined, 'Style DNA', 'Save a look', const StyleDnaScreen()),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5C0), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.water_drop, color: Color(0xFF00E5C0), size: 16),
          ),
          const SizedBox(width: 8),
          const Text('DripVision', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
          const Spacer(),
          Icon(Icons.notifications_none, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePremiumScreen())),
            child: const CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Studio', 'Story', 'Explore', 'Music', 'My Drips'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF00E5C0) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: selected ? null : Border.all(color: Colors.white12),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.black : Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=1000&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.15)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your Universe.\nIn Motion.',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400, color: Colors.white, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create. Continue. Be Legendary.',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5C0),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDripScreen())),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('New Drip', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UniverseScreen())),
          child: Text('See All', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
        ),
      ],
    );
  }

  Widget _continueCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12161A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400',
                width: 110,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('The Last Goodbye', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('2h ago • 00:15', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Color(0xFF00E5C0), size: 32),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _charactersRow() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _characters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = _characters[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CharacterDnaScreen(character: c)),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(c.avatarUrl),
            ),
          );
        },
      ),
    );
  }

  Widget _tool(IconData icon, String title, String sub, Widget screen) {
    return Material(
      color: const Color(0xFF12161A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF00E5C0), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1014),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, 'Home'),
              _navItem(1, Icons.movie_outlined, 'Studio'),
              _plus(),
              _navItem(3, Icons.folder_outlined, 'Library'),
              _navItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _nav == index;
    return GestureDetector(
      onTap: () => setState(() => _nav = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF00E5C0) : Colors.white38, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: active ? const Color(0xFF00E5C0) : Colors.white38)),
        ],
      ),
    );
  }

  Widget _plus() {
    return GestureDetector(
      onTap: () => setState(() => _nav = 2),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF00E5C0),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 24),
      ),
    );
  }
}

typedef DripVisionStudioScreen = StudioHomeScreen;
