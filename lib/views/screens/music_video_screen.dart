import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class MusicVideoScreen extends ConsumerStatefulWidget {
  const MusicVideoScreen({super.key});

  @override
  ConsumerState<MusicVideoScreen> createState() => _MusicVideoScreenState();
}

class _MusicVideoScreenState extends ConsumerState<MusicVideoScreen> {
  final _songPrompt = TextEditingController();
  final _videoPrompt = TextEditingController();
  String _selectedCharacter = 'Isabella';
  String _style = 'Cinematic Neon';
  bool _generating = false;
  int _clipCount = 4;
  final List<_Clip> _clips = [];

  final _styles = const [
    'Cinematic Neon',
    'Film Grain Noir',
    'High Fashion',
    'Dreamlike',
    'Horror Atmosphere',
  ];

  @override
  void initState() {
    super.initState();
    _clips.addAll([
      _Clip(title: 'Intro', duration: '0:08'),
      _Clip(title: 'Verse', duration: '0:12'),
      _Clip(title: 'Chorus', duration: '0:15'),
      _Clip(title: 'Bridge', duration: '0:10'),
    ]);
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _generating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Music video sequence generated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final universe = ref.watch(universeProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('Music Video'),
        actions: [
          TextButton(
            onPressed: _generating ? null : _generate,
            child: const Text('Generate', style: TextStyle(color: DripTheme.teal)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: DripTheme.gunmetal,
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800'),
                fit: BoxFit.cover,
                opacity: 0.65,
              ),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_filled, size: 64, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),

          // Song
          const Text('Song', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _songPrompt,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Describe the track or paste lyrics…',
            ),
          ),
          const SizedBox(height: 16),

          // Character lock
          const Text('Character', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCharacter,
            dropdownColor: DripTheme.gunmetal,
            decoration: const InputDecoration(),
            items: universe.characters
                .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCharacter = v ?? _selectedCharacter),
          ),
          const SizedBox(height: 16),

          // Visual style
          const Text('Visual Style', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _styles.map((s) {
              final selected = s == _style;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                selectedColor: DripTheme.teal,
                backgroundColor: DripTheme.gunmetal,
                labelStyle: TextStyle(color: selected ? Colors.black : DripTheme.pearl),
                onSelected: (_) => setState(() => _style = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Video prompt
          TextField(
            controller: _videoPrompt,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Overall visual direction for the music video…',
            ),
          ),
          const SizedBox(height: 24),

          // Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text('$_clipCount clips', style: DripTheme.meta),
            ],
          ),
          const SizedBox(height: 12),
          ..._clips.asMap().entries.map((e) => _TimelineClip(
                index: e.key + 1,
                clip: e.value,
                onRemove: () => setState(() => _clips.removeAt(e.key)),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _clips.add(_Clip(title: 'New Clip', duration: '0:08'))),
            icon: const Icon(Icons.add, color: DripTheme.teal),
            label: const Text('Add Clip', style: TextStyle(color: DripTheme.teal)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: DripTheme.teal)),
          ),

          const SizedBox(height: 28),

          // Generate button
          ElevatedButton(
            onPressed: _generating ? null : _generate,
            child: _generating
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('GENERATE MUSIC VIDEO'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: const BorderSide(color: DripTheme.silver)),
            child: const Text('Export', style: TextStyle(color: DripTheme.pearl)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _songPrompt.dispose();
    _videoPrompt.dispose();
    super.dispose();
  }
}

class _Clip {
  final String title;
  final String duration;
  _Clip({required this.title, required this.duration});
}

class _TimelineClip extends StatelessWidget {
  final int index;
  final _Clip clip;
  final VoidCallback onRemove;

  const _TimelineClip({required this.index, required this.clip, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DripTheme.gunmetal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('$index', style: const TextStyle(color: DripTheme.teal, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(child: Text(clip.title)),
          Text(clip.duration, style: DripTheme.meta),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: DripTheme.silver),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}