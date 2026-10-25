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

class _Section {
  final String name;
  final String start;
  final String end;
  final String prompt;
  const _Section({required this.name, required this.start, required this.end, this.prompt = ''});
}

class _MusicVideoScreenState extends ConsumerState<MusicVideoScreen> {
  final _directionController = TextEditingController();
  String _style = 'Cinematic Neon';
  bool _generating = false;
  int _tab = 0;

  final _styles = const ['Cinematic Neon', 'Film Grain Noir', 'High Fashion', 'Dreamlike', 'Moody Drama'];

  final List<_Section> _sections = const [
    _Section(name: 'Intro', start: '0:00', end: '0:12'),
    _Section(name: 'Verse', start: '0:12', end: '0:28'),
    _Section(name: 'Chorus', start: '0:28', end: '0:48'),
    _Section(name: 'Bridge', start: '0:48', end: '1:02'),
  ];

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _generating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Music video generated')));
    }
  }

  void _playTestVideo() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoPlayerScreen(
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      title: 'Test Video',
    )));
  }

  @override
  Widget build(BuildContext context) {
    final universe = ref.watch(universeProvider);
    final character = universe.characters.isNotEmpty ? universe.characters.first : null;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Music Video Studio')),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildPreviewTab(),
          _buildTimelineTab(character),
          const Center(child: Text('Assets')),
          const Center(child: Text('Export')),
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
        TextField(controller: _directionController, maxLines: 3, decoration: const InputDecoration(hintText: 'Overall visual direction…')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _generating ? null : _generate,
          child: _generating ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('GENERATE MUSIC VIDEO'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _playTestVideo, child: const Text('Play Test Video')),
      ],
    );
  }

  Widget _buildTimelineTab(dynamic character) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('SONG TIMELINE', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: DripTheme.teal)),
        const SizedBox(height: 8),
        ..._sections.map((s) => ListTile(title: Text(s.name), subtitle: Text('${s.start} – ${s.end}'))),
        const SizedBox(height: 20),
        const Text('STYLE', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: DripTheme.teal)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _styles.map((s) => ChoiceChip(label: Text(s), selected: s == _style, onSelected: (_) => setState(() => _style = s))).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _directionController.dispose();
    super.dispose();
  }
}
