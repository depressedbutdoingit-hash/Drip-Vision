import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme.dart';
import '../../services/suno_service.dart';
import '../../views/widgets/galaxy_background.dart';

final musicPlayerProvider = Provider((ref) => AudioPlayer());

class MusicStudioScreen extends ConsumerStatefulWidget {
  const MusicStudioScreen({super.key});

  @override
  ConsumerState<MusicStudioScreen> createState() => _MusicStudioScreenState();
}

class _MusicStudioScreenState extends ConsumerState<MusicStudioScreen> {
  final _sceneController = TextEditingController();
  String _selectedMood = 'Tense';
  String _selectedStyle = 'Cinematic Horror';
  int _duration = 30;
  bool _isGenerating = false;
  SunoTrack? _currentTrack;
  bool _isPlaying = false;

  final _moods = ['Tense', 'Romantic', 'Epic', 'Melancholic', 'Dreamy', 'Noir'];
  final _styles = [
    'Cinematic Horror',
    'Romantic Orchestral',
    'Epic Trailer',
    'Melancholic Piano',
    'Ambient Ethereal',
    'Jazz Noir',
    'Cinematic Ambient',
  ];

  @override
  void dispose() {
    _sceneController.dispose();
    ref.read(musicPlayerProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 70, intensity: 0.3),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MUSIC STUDIO',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                      color: DripTheme.cosmicTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate AI music for your scenes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    controller: _sceneController,
                    label: 'SCENE DESCRIPTION',
                    hint: 'A dark hallway with flickering lights. The protagonist slowly walks toward a door at the end...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'MOOD',
                          value: _selectedMood,
                          items: _moods,
                          onChanged: (v) => setState(() => _selectedMood = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'STYLE',
                          value: _selectedStyle,
                          items: _styles,
                          onChanged: (v) => setState(() => _selectedStyle = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'DURATION: ${_duration}s',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: DripTheme.cosmicTeal.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _duration.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    activeColor: DripTheme.cosmicTeal,
                    inactiveColor: Colors.white.withOpacity(0.1),
                    label: '${_duration}s',
                    onChanged: (v) => setState(() => _duration = v.round()),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateMusic,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DripTheme.cosmicTeal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: DripTheme.cosmicTeal.withOpacity(0.4),
                      ),
                      child: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'GENERATE MUSIC',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_currentTrack != null) _buildPlayerCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            color: DripTheme.cosmicTeal.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DripTheme.cosmicTeal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            color: DripTheme.cosmicTeal.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0A0E1A),
              style: const TextStyle(color: Colors.white),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DripTheme.cosmicTeal.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DripTheme.cosmicTeal.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DripTheme.cosmicTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 28,
                    color: DripTheme.cosmicTeal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTrack!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentTrack!.genre} • ${_currentTrack!.durationSeconds}s',
                      style: TextStyle(
                        color: Colors.white50,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 56,
                  color: DripTheme.cosmicTeal,
                ),
                onPressed: _togglePlayback,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.download,
                label: 'DOWNLOAD',
                onTap: () {},
              ),
              _buildActionButton(
                icon: Icons.add_to_photos,
                label: 'ADD TO SCENE',
                onTap: () {},
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'SHARE',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white50, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateMusic() async {
    if (_sceneController.text.trim().isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final service = ref.read(sunoServiceProvider);
      final track = await service.generateForScene(
        sceneDescription: _sceneController.text.trim(),
        sceneMood: _selectedMood,
        lighting: '',
        duration: _duration,
      );

      setState(() {
        _currentTrack = track;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generation failed: $e')),
      );
    }
  }

  Future<void> _togglePlayback() async {
    final player = ref.read(musicPlayerProvider);

    if (_isPlaying) {
      await player.pause();
    } else {
      if (_currentTrack != null) {
        await player.play(UrlSource(_currentTrack!.audioUrl));
      }
    }

    setState(() => _isPlaying = !_isPlaying);
  }
}
