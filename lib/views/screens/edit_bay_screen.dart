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
        title: const Text('Edit Bay'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Export', style: TextStyle(color: DripTheme.teal)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Container(
            height: 220,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: DripTheme.gunmetal,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1485846234645-a62644f84728?w=800'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white70),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white70),
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

          // Timeline
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _clips.length,
              itemBuilder: (context, i) {
                final selected = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? DripTheme.gunmetalLight : DripTheme.gunmetal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? DripTheme.teal : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_clips[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
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

          // Tools
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolButton(icon: Icons.content_cut, label: 'Cut'),
                _ToolButton(icon: Icons.tune, label: 'Color'),
                _ToolButton(icon: Icons.speed, label: 'Speed'),
                _ToolButton(icon: Icons.music_note, label: 'Audio'),
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
        Icon(icon, color: DripTheme.teal),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}