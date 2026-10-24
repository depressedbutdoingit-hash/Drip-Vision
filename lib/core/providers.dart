import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/universe.dart';
import '../models/character.dart';
import '../services/continuity_service.dart';

class ContinuityHealth {
  final double score;
  final String message;
  final Color color;

  ContinuityHealth({required this.score, required this.message, required this.color});

  ContinuityHealth fix() => ContinuityHealth(
        score: 96,
        message: 'Continuity locked. Identity and wardrobe stabilized.',
        color: const Color(0xFF00D4AA),
      );
}

final continuityEngineProvider = Provider<ContinuityEngine>((ref) => ContinuityEngine());

final universeProvider = StateProvider<Universe>((ref) => Universe(
      healthScore: 94,
      characters: [
        Character(
          id: 'isabella',
          name: 'Isabella',
          avatarUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400',
          role: 'Main Character • Lead',
          age: 28,
          height: '5\'6"',
          build: 'Athletic',
          eyeColor: 'Hazel',
          hairColor: 'Dark Brown',
          voiceDescription: 'Deep, sultry, confident',
          wardrobeDNA: ['Leather jacket', 'Black top', 'Dark jeans', 'Red dress', 'White shirt'],
          dna: const CharacterDNA(face: 0.82, body: 0.75, wardrobe: 0.68, voice: 0.71, style: 0.88, locked: true),
        ),
        Character(
          id: 'monty',
          name: 'Monty',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          role: 'Supporting',
          wardrobeDNA: ['Suit', 'Glasses'],
          dna: const CharacterDNA(face: 0.45, body: 0.60, wardrobe: 0.40, voice: 0.55, style: 0.50),
        ),
      ],
    ));

final continuityHealthProvider = StateProvider<ContinuityHealth>((ref) => ContinuityHealth(
      score: 88,
      message: 'Strong consistency. Minor wardrobe drift on secondary characters.',
      color: const Color(0xFFFFB020),
    ));