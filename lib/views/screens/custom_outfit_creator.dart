import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/character_dna.dart';
import '../../services/token_service.dart';
import '../../core/providers.dart';
import '../widgets/galaxy_background.dart';
import '../widgets/drip_button.dart';
import '../widgets/drip_celebration.dart';

class CustomOutfitCreator extends ConsumerStatefulWidget {
  final String? characterName;
  const CustomOutfitCreator({super.key, this.characterName});

  @override
  ConsumerState<CustomOutfitCreator> createState() => _CustomOutfitCreatorState();
}

class _CustomOutfitCreatorState extends ConsumerState<CustomOutfitCreator> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _referenceImagePath;
  String _selectedStyle = 'Casual';
  final List<String> _selectedTags = [];
  bool _isCreating = false;

  final _styles = [
    'Casual', 'Formal', 'Fantasy', 'Cyberpunk', 'Streetwear',
    'Vintage', 'Military', 'Athletic', 'Gothic', 'Bohemian'
  ];

  final _availableTags = [
    'cute', 'edgy', 'elegant', 'cozy', 'flashy', 'minimal',
    'armor', 'glowing', 'flowing', 'fitted', 'oversized'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Stack(
        children: [
          const GalaxyBackground(starCount: 60, intensity: 0.2),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESIGN OUTFIT',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                letterSpacing: 6,
                                color: DripTheme.cosmicTeal,
                              ),
                            ),
                            if (widget.characterName != null)
                              Text('FOR ${widget.characterName!.toUpperCase()}', style: const TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white38)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your own unique look. Costs 50 tokens to mint.',
                    style: TextStyle(color: DripColors.white40, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // Reference image upload
                  Center(
                    child: GestureDetector(
                      onTap: _pickReferenceImage,
                      child: Container(
                        width: 160,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: DripTheme.cosmicTeal.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _referenceImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_referenceImagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: DripTheme.cosmicTeal.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'UPLOAD REFERENCE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 2,
                                    color: DripTheme.cosmicTeal.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sketch, photo, or description',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DripColors.white20,
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
                    label: 'OUTFIT NAME',
                    hint: 'e.g. Neon Dreamcoat',
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _descriptionController,
                    label: 'DESCRIPTION',
                    hint: 'A shimmering trench coat woven from fiber-optic threads...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _buildDropdown(
                    label: 'BASE STYLE',
                    value: _selectedStyle,
                    items: _styles,
                    onChanged: (v) => setState(() => _selectedStyle = v!),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'TAGS',
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
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                              ? DripTheme.cosmicTeal.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                ? DripTheme.cosmicTeal.withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? DripTheme.cosmicTeal : Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  // AI Generate preview option
                  Container(
                    padding: const EdgeInsets.all(16),
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
                            Icon(Icons.auto_fix_high, color: DripTheme.cosmicTeal, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AI ASSIST',
                              style: TextStyle(
                                color: DripTheme.cosmicTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Let AI generate a concept image from your description. +20 tokens.',
                          style: TextStyle(color: DripColors.white40, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.generating_tokens, size: 16, color: DripTheme.cosmicTeal),
                          label: Text(
                            'GENERATE PREVIEW',
                            style: TextStyle(color: DripTheme.cosmicTeal, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: DripTheme.cosmicTeal.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DripButton(
                      onPressed: _isCreating ? null : _mintOutfit,
                      child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.token, size: 20, color: Colors.black),
                              const SizedBox(width: 8),
                              const Text(
                                'MINT OUTFIT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '50',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
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

  Future<void> _pickReferenceImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _referenceImagePath = picked.path);
    }
  }

  Future<void> _mintOutfit() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isCreating = true);

    final tokenService = ref.read(tokenServiceProvider);
    final success = await tokenService.deduct(50);

    if (success) {
      final outfit = Outfit(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        referenceImageUrl: _referenceImagePath,
        tags: [..._selectedTags, 'custom'],
        isDefault: false,
      );

      DripCelebration.show(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${outfit.name} minted to your wardrobe!'),
          backgroundColor: DripTheme.cosmicTeal.withOpacity(0.8),
        ),
      );

      Navigator.pop(context, outfit);
    } else {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough tokens. Need 50 to mint a custom outfit.'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }
}
