import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_dna.dart';
import '../views/screens/story_planner_screen.dart';
import '../services/cost_tracking_service.dart';
import '../core/env.dart';

class AIDirectorService {
  final String _openRouterKey;

  AIDirectorService(this._openRouterKey);

  Future<DirectorResult> planStory({
    required String title,
    required String story,
    required String genre,
    required String targetDuration,
    required bool includeDialogue,
  }) async {
    final prompt = '''
You are an AI Film Director. Break the following user story into a production-ready film plan.

STORY: $story
GENRE: $genre
TARGET DURATION: $targetDuration
DIALOGUE: ${includeDialogue ? 'Include character dialogue/voiceover' : 'No dialogue, visual storytelling only'}

Your task:
1. Write a compelling logline (1 sentence)
2. Break the story into scenes. Each scene needs:
   - Scene heading (INT./EXT. LOCATION - TIME)
   - Description (2-3 sentences)
   - Shot list (3-5 specific camera shots)
   - ${includeDialogue ? 'Dialogue lines mapped to character names' : ''}
   - Location ID (unique identifier for continuity)
   - Time of day
   - Mood
   - Lighting description
   - Character IDs present
   - Wardrobe note

3. Create character profiles if not already established:
   - Name
   - Age range
   - Physical description
   - Personality traits
   - Voice description (if dialogue enabled)

4. Estimate token cost (assume ~15 tokens per second of video)
5. Estimate total duration

Respond ONLY as valid JSON in this exact structure:
{
  "title": "string",
  "logline": "string",
  "estimatedTokens": number,
  "estimatedDurationSeconds": number,
  "characters": [
    {
      "id": "unique_id",
      "name": "string",
      "ageRange": "string",
      "physicalDescription": "string",
      "personality": "string",
      "voiceDescription": "string"
    }
  ],
  "scenes": [
    {
      "sceneNumber": 1,
      "heading": "INT. LOCATION - TIME",
      "description": "string",
      "shots": ["shot1", "shot2"],
      "dialogue": {"CharacterName": "Line of dialogue"},
      "locationId": "unique_location_id",
      "timeOfDay": "string",
      "mood": "string",
      "lighting": "string",
      "characterIds": ["char_id_1"],
      "wardrobeNote": "string"
    }
  ]
}
''';

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openRouterKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
      },
      body: jsonEncode({
        'model': 'anthropic/claude-3.5-sonnet',
        'messages': [
          {'role': 'system', 'content': 'You are a professional film director and screenwriter.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 4000,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Director failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final costResult = CostTrackingService.parseAndCharge(
      callType: 'story_plan',
      model: 'anthropic/claude-3.5-sonnet',
      responseData: data,
    );

    final content = data['choices'][0]['message']['content'];
    final jsonStr = content.replaceAll('```json', '').replaceAll('```', '').trim();
    final planJson = jsonDecode(jsonStr);

    final plan = StoryPlan(
      title: planJson['title'],
      logline: planJson['logline'],
      estimatedTokens: planJson['estimatedTokens'],
      estimatedDuration: Duration(seconds: planJson['estimatedDurationSeconds']),
      characters: (planJson['characters'] as List).map((c) => CharacterDNA(
        id: c['id'],
        name: c['name'],
        faceReferenceUrl: null,
        fullBodyReferenceUrl: null,
        physical: PhysicalTraits(
          gender: '',
          ageRange: c['ageRange'],
          ethnicity: '',
          hairColor: '',
          hairStyle: '',
          bodyType: '',
          height: '',
          distinguishingFeatures: c['physicalDescription'],
        ),
        voice: VoiceProfile(
          elevenLabsVoiceId: null,
          description: c['voiceDescription'] ?? '',
          language: 'en',
          accent: '',
          stability: 0.5,
          similarityBoost: 0.75,
        ),
        personality: PersonalityProfile(
          archetype: '',
          traits: c['personality'],
          mannerisms: '',
          speechPattern: '',
        ),
        closet: const [],
        defaultOutfitId: '',
        visualStyle: VisualStyle.empty(),
        continuityLock: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList(),
      scenes: (planJson['scenes'] as List).map((s) => PlannedScene(
        sceneNumber: s['sceneNumber'],
        heading: s['heading'],
        description: s['description'],
        shots: List<String>.from(s['shots']),
        dialogue: Map<String, String>.from(s['dialogue'] ?? {}),
        locationId: s['locationId'],
        timeOfDay: s['timeOfDay'],
        mood: s['mood'],
        lighting: s['lighting'],
        characterIds: List<String>.from(s['characterIds']),
        wardrobeNote: s['wardrobeNote'],
      )).toList(),
    );

    return DirectorResult(plan: plan, cost: costResult);
  }
}

class DirectorResult {
  final StoryPlan plan;
  final ApiCallResult cost;

  DirectorResult({required this.plan, required this.cost});
}
