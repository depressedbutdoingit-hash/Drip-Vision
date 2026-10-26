import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/character_dna.dart';
import '../../services/token_service.dart';
import '../../core/providers.dart';
import '../widgets/drip_button.dart';
import '../widgets/drip_celebration.dart';
import '../widgets/outfit_reveal_sheet.dart';

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
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MINT OUTFIT',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DripTheme.warmWhite,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'OUTFIT NAME',
                hint: 'Midnight leather coat',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'DESCRIPTION',
                hint: 'Materials, colors, silhouette…',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'STYLE',
                value: _selectedStyle,
                items: _styles,
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStyle = v);
                },
              ),
              const SizedBox(height: 20),
              const Text('TAGS', style: DripTheme.overline),
              const SizedBox(height: 8),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
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
                          color: isSelected
                              ? DripTheme.cosmicTeal
                              : Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.image_outlined, color: DripTheme.chrome),
                title: Text(
                  _referenceImagePath == null
                      ? 'Add reference image'
                      : 'Reference selected',
                  style: const TextStyle(color: DripTheme.warmWhite),
                ),
                onTap: _pickReferenceImage,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DripButton(
                  onPressed: _isCreating ? null : _mintOutfit,
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.token, size: 20, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'MINT OUTFIT · 50',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
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
    final success = await TokenService.deduct(50);

    if (success) {
      final outfit = Outfit(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        referenceImageUrl: _referenceImagePath,
        tags: [..._selectedTags, 'custom'],
        isDefault: false,
      );

      if (mounted) {
        DripCelebration.show(context);
        await showOutfitReveal(
          context,
          outfit: outfit,
          characterName: widget.characterName,
        );
      }
      if (mounted) Navigator.pop(context, outfit);
    } else {
      if (mounted) setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough tokens. Need 50 to mint a custom outfit.'),
            backgroundColor: Color(0xCCB00020),
          ),
        );
      }
    }
  }
}
