import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character_dna.dart';
import '../../services/cost_tracking_service.dart';
import '../../views/widgets/galaxy_background.dart';
import '../../views/widgets/drip_celebration.dart';
import 'screenplay_screen.dart';
import 'storyboard_screen.dart';

final storyPlanProvider = StateProvider<StoryPlan?>((ref) => null);
final storyPlanCostProvider = StateProvider<ApiCallResult?>((ref) => null);
final isPlanningProvider = StateProvider<bool>((ref) => false);

class StoryPlan {
  final String title;
  final String logline;
  final List<PlannedScene> scenes;
  final List<CharacterDNA> characters;
  final int estimatedTokens;
  final Duration estimatedDuration;

  StoryPlan({
    required this.title,
    required this.logline,
    required this.scenes,
    required this.characters,
    required this.estimatedTokens,
    required this.estimatedDuration,
  });

  StoryPlan copyWith({List<PlannedScene>? scenes}) => StoryPlan(
        title: title,
        logline: logline,
        scenes: scenes ?? this.scenes,
        characters: characters,
        estimatedTokens: estimatedTokens,
        estimatedDuration: estimatedDuration,
      );
}

class PlannedScene {
  final int sceneNumber;
  final String heading;
  final String description;
  final List<String> shots;
  final Map<String, String> dialogue;
  final String locationId;
  final String timeOfDay;
  final String mood;
  final String lighting;
  final List<String> characterIds;
  final String wardrobeNote;

  PlannedScene({
    required this.sceneNumber,
    required this.heading,
    required this.description,
    required this.shots,
    required this.dialogue,
    required this.locationId,
    required this.timeOfDay,
    required this.mood,
    required this.lighting,
    required this.characterIds,
    required this.wardrobeNote,
  });

  PlannedScene copyWith({String? description, String? lighting}) => PlannedScene(
        sceneNumber: sceneNumber,
        heading: heading,
        description: description ?? this.description,
        shots: shots,
        dialogue: dialogue,
        locationId: locationId,
        timeOfDay: timeOfDay,
        mood: mood,
        lighting: lighting ?? this.lighting,
        characterIds: characterIds,
        wardrobeNote: wardrobeNote,
      );
}

class StoryPlannerScreen extends ConsumerStatefulWidget {
  const StoryPlannerScreen({super.key});

  @override
  ConsumerState<StoryPlannerScreen> createState() => _StoryPlannerScreenState();
}

class _StoryPlannerScreenState extends ConsumerState<StoryPlannerScreen> {
  final _storyController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedGenre = 'Horror';
  String _selectedDuration = '60 seconds';
  bool _includeDialogue = true;

  final _genres = ['Horror', 'Romance', 'Sci-Fi', 'Noir', 'Comedy', 'Drama', 'Thriller'];
  final _durations = ['30 seconds', '60 seconds', '2 minutes', '5 minutes'];

  @override
  void dispose() {
    _storyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(storyPlanProvider);
    final cost = ref.watch(storyPlanCostProvider);
    final isPlanning = ref.watch(isPlanningProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 80, intensity: 0.3),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STORY TO FILM',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                      color: DripTheme.cosmicTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe your story. The Director will plan the production.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildInputField(
                    controller: _titleController,
                    label: 'FILM TITLE',
                    hint: "The Door That Wasn't There",
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'GENRE',
                          value: _selectedGenre,
                          items: _genres,
                          onChanged: (v) => setState(() => _selectedGenre = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'DURATION',
                          value: _selectedDuration,
                          items: _durations,
                          onChanged: (v) => setState(() => _selectedDuration = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildStoryInput(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Switch(
                        value: _includeDialogue,
                        onChanged: (v) => setState(() => _includeDialogue = v),
                        activeColor: DripTheme.cosmicTeal,
                      ),
                      Text(
                        'Include dialogue & voiceover',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isPlanning ? null : _planProduction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DripTheme.cosmicTeal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: DripTheme.cosmicTeal.withOpacity(0.4),
                      ),
                      child: isPlanning
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'PLAN PRODUCTION',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  if (plan != null) ...[
                    if (cost != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DripTheme.cosmicTeal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DripTheme.cosmicTeal.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 16, color: DripTheme.cosmicTeal),
                            const SizedBox(width: 8),
                            Text(
                              'Director fee: ${cost.tokenCost} tokens',
                              style: TextStyle(
                                color: DripTheme.cosmicTeal.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(\$${cost.markedUpCostUsd.toStringAsFixed(4)})',
                              style: TextStyle(
                                color: Colors.white40,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildPlanResults(plan),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
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

  Widget _buildStoryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR STORY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            color: DripTheme.cosmicTeal.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _storyController,
            maxLines: 6,
            style: const TextStyle(
              color: Colors.white,
              height: 1.6,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: "A woman discovers a door in her apartment that wasn't there yesterday. When she opens it, she finds a hallway that leads to a version of her home from 30 years ago...",
              hintStyle: TextStyle(
                color: Colors.white24,
                height: 1.6,
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanResults(StoryPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
              Text(
                plan.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plan.logline,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatChip('${plan.scenes.length} SCENES'),
                  const SizedBox(width: 8),
                  _buildStatChip('${plan.estimatedTokens} TOKENS'),
                  const SizedBox(width: 8),
                  _buildStatChip('${plan.estimatedDuration.inSeconds}s'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ...plan.scenes.asMap().entries.map((entry) {
          final idx = entry.key;
          final scene = entry.value;
          return _buildSceneCard(scene, idx + 1);
        }),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenplayScreen())),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('SCREENPLAY', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(foregroundColor: DripTheme.warmWhite, side: BorderSide(color: Colors.white.withOpacity(.14)), minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryboardScreen())),
                icon: const Icon(Icons.grid_view_outlined, size: 18),
                label: const Text('STORYBOARD', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(foregroundColor: DripTheme.warmWhite, side: BorderSide(color: Colors.white.withOpacity(.14)), minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: _startProduction,
            icon: const Icon(Icons.movie_creation, size: 24),
            label: const Text(
              'START PRODUCTION',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: DripTheme.cosmicTeal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 12,
              shadowColor: DripTheme.cosmicTeal.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildStatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white70,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSceneCard(PlannedScene scene, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: DripTheme.cosmicTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: DripTheme.cosmicTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  scene.heading,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scene.description,
            style: TextStyle(
              color: Colors.white60,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          if (scene.shots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scene.shots.map((shot) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shot,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white50,
                  ),
                ),
              )).toList(),
            ),
          ],
          if (scene.dialogue.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...scene.dialogue.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: "${entry.value}"',
                style: TextStyle(
                  color: DripTheme.cosmicTeal.withOpacity(0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Future<void> _planProduction() async {
    if (_storyController.text.trim().isEmpty) return;

    ref.read(isPlanningProvider.notifier).state = true;

    try {
      final service = ref.read(aiDirectorServiceProvider);
      final result = await service.planStory(
        title: _titleController.text.trim(),
        story: _storyController.text.trim(),
        genre: _selectedGenre,
        targetDuration: _selectedDuration,
        includeDialogue: _includeDialogue,
      );

      // Deduct the actual cost with 5% markup
      final tokenService = ref.read(tokenServiceProvider);
      final hasFunds = await tokenService.deduct(result.cost.tokenCost);

      if (!hasFunds) {
        ref.read(isPlanningProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Not enough tokens. Need ${result.cost.tokenCost} tokens (\$${result.cost.markedUpCostUsd.toStringAsFixed(4)}).',
            ),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
        return;
      }

      ref.read(storyPlanProvider.notifier).state = result.plan;
      ref.read(storyPlanCostProvider.notifier).state = result.cost;

      DripCelebration.show(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Planning failed: $e'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    } finally {
      ref.read(isPlanningProvider.notifier).state = false;
    }
  }

  void _startProduction() {
    final plan = ref.read(storyPlanProvider);
    if (plan == null) return;

    Navigator.pushNamed(
      context,
      '/production',
      arguments: plan,
    );
  }
}
