import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import 'video_player_screen.dart';

class MusicVideoScreen extends ConsumerStatefulWidget {
  const MusicVideoScreen({super.key});

  @override
  ConsumerState<MusicVideoScreen> createState() => _MusicVideoScreenState();
}

class _MusicVideoScreenState extends ConsumerState<MusicVideoScreen> {
  final _songController = TextEditingController();
  final _directionController = TextEditingController();
  String _selectedCharacter = 'Isabella';
  String _style = 'Cinematic Neon';
  bool _generating = false;
  int _tab = 1;

  final _styles = const [
    'Cinematic Neon',
    'Film Grain Noir',
    'High Fashion',
    'Dreamlike',
    'Moody Drama',
  ];

  final List<_Section> _sections = [
    _Section(name: 'Intro', start: '0:00', end: '0:12', prompt: ''),
    _Section(name: 'Verse', start: '0:12', end: '0:28', prompt: ''),
    _Section(name: 'Chorus', start: '0:28', end: '0:48', prompt: ''),
    _Section(name: 'Bridge', start: '0:48', end: '1:02', prompt: ''),
  ];

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _generating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Music video sequence locked and generated')),
      );
    }
  }

  void _playTestVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VideoPlayerScreen(
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          title: 'Test Video',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final universe = ref.watch(universeProvider);
    final character = universe.characters.isNotEmpty ? universe.characters.first : null;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('Music Video Studio'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 220,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: DripTheme.gunmetal,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800'),
                fit: BoxFit.cover,
                opacity: 0.75,
              ),
            ),
            child: const Stack(
              children: [
                Center(child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white70)),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Text('00:12 / 03:48', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildPreviewTab(),
                _buildTimelineTab(character),
                _buildAssetsTab(),
                _buildExportTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: DripTheme.gunmetal,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Preview'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Timeline'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), label: 'Assets'),
          NavigationDestination(icon: Icon(Icons.upload), label: 'Export'),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _directionController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Overall visual direction…'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _generating ? null : _generate,
          child: _generating
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('GENERATE MUSIC VIDEO'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _playTestVideo,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: DripTheme.teal)),
          child: const Text('Play Test Video', style: TextStyle(color: DripTheme.teal)),
        ),
      ],
    );
  }

  Widget _buildTimelineTab(dynamic character) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SONG TIMELINE', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: DripTheme.teal)),
            TextButton(onPressed: () {}, child: const Text('EDIT TIMELINE', style: TextStyle(color: DripTheme.teal))),
          ],
        ),
        const SizedBox(height: 8),
        ..._sections.map((s) => _SectionCard(section: s)),
        const SizedBox(height: 20),
        const Text('CHARACTER', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: DripTheme.teal)),
        const SizedBox(height: 8),
        if (character != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DripTheme.gunmetal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(character.avatarUrl, width: 72, height: 96, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(character.role, style: DripTheme.meta),
                      const SizedBox(height: 8),
                      const Text('DNA', style: TextStyle(fontSize: 11, color: DripTheme.silver)),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 18,
                          height: 6 + (i * 3).toDouble(),
                          color: DripTheme.teal,
                        )),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: DripTheme.silver),
              ],
            ),
          ),
        const SizedBox(height: 20),
        const Text('STYLE', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: DripTheme.teal)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _styles.map((s) {
            final selected = s == _style;
            return ChoiceChip(
              label: Text(s),
              selected: selected