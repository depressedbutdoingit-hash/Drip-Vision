import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../../models/character.dart';
import '../../services/continuity_service.dart';
import 'character_dna_screen.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _name = TextEditingController();
  final _role = TextEditingController(text: 'Lead');
  final _hair = TextEditingController();
  final _eyes = TextEditingController();
  final _voice = TextEditingController();
  final _outfit = TextEditingController();
  String? _referencePath;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _hair.dispose();
    _eyes.dispose();
    _voice.dispose();
    _outfit.dispose();
    super.dispose();
  }

  Future<void> _uploadReference() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _referencePath = picked.path);
    }
  }

  Future<void> _downloadReference() async {
    if (_referencePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reference image to download')),
      );
      return;
    }
    try {
      await Gal.putImage(_referencePath!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    }
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarUrl: _referencePath ?? '',
      role: _role.text.trim().isEmpty ? 'Lead' : _role.text.trim(),
      hairColor: _hair.text.trim().isEmpty ? 'Unknown' : _hair.text.trim(),
      eyeColor: _eyes.text.trim().isEmpty ? 'Unknown' : _eyes.text.trim(),
      voiceDescription: _voice.text.trim().isEmpty ? 'Neutral' : _voice.text.trim(),
      wardrobeDNA: [_outfit.text.trim().isEmpty ? 'default' : _outfit.text.trim()],
      faceReferenceUrls: _referencePath != null ? [_referencePath!] : const [],
      dna: CharacterDNA.empty(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CharacterDnaScreen(character: character)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Character', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_referencePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_referencePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF12161A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No reference image', style: TextStyle(color: Colors.white38)),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00E5C0)),
                    foregroundColor: const Color(0xFF00E5C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _uploadReference,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload Reference'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    foregroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _downloadReference,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field(_name, 'Name'),
          _field(_role, 'Role'),
          _field(_hair, 'Hair'),
          _field(_eyes, 'Eyes'),
          _field(_voice, 'Voice'),
          _field(_outfit, 'Outfit'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C0),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _save,
              child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF12161A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
