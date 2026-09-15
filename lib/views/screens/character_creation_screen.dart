import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../models/character.dart' as live;
import '../../models/character_dna.dart';
import '../../views/widgets/galaxy_background.dart';
import 'character_lab_screen.dart';

class CharacterCreationScreen extends ConsumerStatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  ConsumerState<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends ConsumerState<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _featuresController = TextEditingController();
  String _selectedGender = 'Female';
  String _selectedBodyType = 'Average';
  String _selectedArtStyle = 'Photorealistic';
  String? _pickedImagePath;

  final _genders = ['Female', 'Male', 'Non-binary'];
  final _bodyTypes = ['Slim', 'Average', 'Athletic', 'Curvy', 'Heavyset'];
  final _artStyles = ['Photorealistic', 'Cinematic', 'Anime', 'Noir', 'Painterly', 'Pixel Art'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 60, intensity: 0.25),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'CREATE CHARACTER',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            letterSpacing: 6,
                            color: DripTheme.cosmicTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: GestureDetector(
                      onTap: _pickReferenceImage,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03),
                          border: Border.all(
                            color: DripTheme.cosmicTeal.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _pickedImagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_pickedImagePath!),
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: DripTheme.cosmicTeal.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ADD PHOTO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 2,
                                      color: DripTheme.cosmicTeal.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildTextField(
                    controller: _nameController,
                    label: 'CHARACTER NAME',
                    hint: 'e.g. Elena Voss',
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'GENDER',
                          value: _selectedGender,
                          items: _genders,
                          onChanged: (v) => setState(() => _selectedGender = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: 'AGE',
                          hint: '28',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildDropdown(
                    label: 'BODY TYPE',
                    value: _selectedBodyType,
                    items: _bodyTypes,
                    onChanged: (v) => setState(() => _selectedBodyType = v!),
                  ),
                  const SizedBox(height: 20),

                  _buildDropdown(
                    label: 'ART STYLE',
                    value: _selectedArtStyle,
                    items: _artStyles,
                    onChanged: (v) => setState(() => _selectedArtStyle = v!),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _featuresController,
                    label: 'DISTINGUISHING FEATURES',
                    hint: 'Scar above left eyebrow, green eyes, sharp jawline...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'PERSONALITY TRAITS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: DripTheme.cosmicTeal.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Confident', 'Shy', 'Aggressive', 'Kind',
                      'Sarcastic', 'Optimistic', 'Mysterious', 'Loyal',
                    ].map((trait) => _buildTraitChip(trait)).toList(),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createCharacter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DripTheme.cosmicTeal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: DripTheme.cosmicTeal.withOpacity(0.4),
                      ),
                      child: const Text(
                        'CREATE CHARACTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
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

  Widget _buildTraitChip(String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        trait,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    );
  }

  Future<void> _pickReferenceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImagePath = picked.path);
  }

  void _createCharacter() {
    final dna = CharacterDNA(
      id: 'char_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.isEmpty ? 'Unnamed' : _nameController.text,
      faceReferenceUrl: _pickedImagePath,
      physical: PhysicalTraits(
        gender: _selectedGender,
        ageRange: _ageController.text.isEmpty ? 'Unknown' : '${_ageController.text}s',
        ethnicity: '',
        hairColor: '',
        hairStyle: '',
        bodyType: _selectedBodyType,
        height: '',
        distinguishingFeatures: _featuresController.text,
      ),
      voice: VoiceProfile.empty(),
      personality: PersonalityProfile.empty(),
      closet: const [],
      defaultOutfitId: '',
      visualStyle: VisualStyle(
        artDirection: _selectedArtStyle.toLowerCase(),
        colorPalette: '',
        lightingPreference: '',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Bridge into the live Character model actually used by generation,
    // continuity and the wardrobe, via the one shared converter
    // (Character.fromDNA) — so this logic exists in exactly one place
    // instead of being re-implemented per screen.
    final character = live.Character.fromDNA(dna);

    ref.read(characterListProvider.notifier).addCharacter(character);
    ref.read(activeCharacterProvider.notifier).state = character;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CharacterLabScreen(characterId: character.id)),
    );
  }
}
