import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import 'continuity_service.dart';

class CharacterList extends StateNotifier<List<Character>> {
  CharacterList() : super([
    Character(
      id: 'isabella',
      name: 'Isabella',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      role: 'Lead Heroine',
      hairColor: 'Dark brown, wavy',
      eyeColor: 'Hazel',
      voiceDescription: 'Confident, warm',
      wardrobeDNA: const ['luxury black dress', 'leather jacket'],
      defaultStylePrompt: 'photorealistic, cinematic',
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'marcus',
      name: 'Marcus',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      role: 'Lead',
      hairColor: 'Short black',
      eyeColor: 'Brown',
      voiceDescription: 'Steady',
      wardrobeDNA: const ['dark coat'],
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'elena',
      name: 'Elena',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      role: 'Supporting',
      hairColor: 'Blonde',
      eyeColor: 'Blue',
      voiceDescription: 'Soft',
      wardrobeDNA: const ['white dress'],
      dna: CharacterDNA.empty(),
    ),
    Character(
      id: 'rex',
      name: 'Rex',
      avatarUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=200',
      role: 'Companion',
      hairColor: 'Tan',
      eyeColor: 'Brown',
      voiceDescription: 'N/A',
      wardrobeDNA: const ['collar'],
      dna: CharacterDNA.empty(),
    ),
  ]);

  void add(Character c) => state = [...state, c];
  void remove(String id) => state = state.where((c) => c.id != id).toList();
}

final characterListProvider =
    StateNotifierProvider<CharacterList, List<Character>>(
  (ref) => CharacterList(),
);
