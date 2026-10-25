import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/character.dart';
import '../../services/continuity_service.dart';
import '../../services/character_service.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController(text: 'Main Character');
  final _voiceController = TextEditingController(text: 'Confident, cinematic');
  bool _saving = false;

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _saving = true);

    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      avatarUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
      role: _roleController.text.trim(),
      voiceDescription: _voiceController.text.trim(),
      wardrobeDNA: const ['Leather jacket', 'Dark top'],
      dna: const CharacterDNA(
        face: 0.82,
        body: 0.74,
        wardrobe: 0.68,
        voice: 0.71,
        style: 0.86,
        locked: true,
      ),
    );

    await CharacterService.saveCharacter(character);

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Character saved')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Create Character')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _roleController,
            decoration: const InputDecoration(labelText: 'Role'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _voiceController,
            decoration: const InputDecoration(labelText: 'Voice'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Text('Save Character'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _voiceController.dispose();
    super.dispose();
  }
}