import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'video_player_screen.dart';

class EditBayScreen extends StatefulWidget {
  const EditBayScreen({super.key});

  @override
  State<EditBayScreen> createState() => _EditBayScreenState();
}

class _EditBayScreenState extends State<EditBayScreen> {
  final List<_Clip> _clips = [
    _Clip(name: 'Opening', duration: '0:08'),
    _Clip(name: 'Character Intro', duration: '0:12'),
    _Clip(name: 'Action', duration: '0:15'),
    _Clip(name: 'Ending', duration: '0:10'),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('EDIT BAY', style: DripTheme.overline),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('EXPORT', style: TextStyle(color: DripTheme.teal, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DripTheme.radiusXl),
              child: SizedBox(
                height: 240,
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
                          colors: [Color(0x44000000), Color(0xAA000000)],
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.play_circle_fill, size: 72, color: Colors.white70),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VideoPlayerScreen(
                                videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                                title: 'Edit Bay Preview',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('TIMELINE', style: DripTheme.overline),
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _clips.length,
              itemBuilder: (context, i) {
                final selected = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? DripTheme.surfaceRaised : DripTheme.surface,
                      borderRadius: BorderRadius.circular(DripTheme.radiusMd),
                      border: Border.all(
                        color: selected ? DripTheme.teal : DripTheme.hairline.withOpacity(0.5),
                        width: selected ? 1.5 : 1,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: DripTheme.teal.withOpacity(0.15), blurRadius: 12)]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_clips[i].name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.3)),
                        const Spacer(),
                        Text(_clips[i].duration, style: DripTheme.meta),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: DripTheme.hairline, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ToolButton(icon: Icons.content_cut, label: 'CUT'),
                _ToolButton(icon: Icons.tune, label: 'COLOR'),
                _ToolButton(icon: Icons.speed, label: 'SPEED'),
                _ToolButton(icon: Icons.music_note, label: 'AUDIO'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Clip {
  final String name;
  final String duration;
  _Clip({required this.name, required this.duration});
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ToolButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DripTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DripTheme.hairline),
          ),
          child: Icon(icon, color: DripTheme.teal, size: 22),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600, color: DripTheme.silver)),
      ],
    );
  }
}
