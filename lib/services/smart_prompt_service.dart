import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/env.dart';

/// Smart Prompt Suggestions — On-device lightweight suggestions
/// to guide users as they write their stories.
/// 
/// Uses a fast, cheap model (GPT-4o-mini) for real-time suggestions.
class SmartPromptService {
  final String _openRouterKey;

  SmartPromptService(this._openRouterKey);

  /// Analyze a story draft and return suggestions.
  Future<List<PromptSuggestion>> analyzeStory(String storyText) async {
    if (storyText.length < 20) return [];

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openRouterKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'openai/gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '''
You are a creative writing assistant for filmmakers. Analyze the user's story and provide 2-3 concise, actionable suggestions to improve it visually.

Rules:
- Each suggestion must be under 15 words
- Focus on visual storytelling, camera work, or atmosphere
- Be encouraging, not critical
- Respond ONLY as JSON array: [{"type": "visual|atmosphere|character", "text": "..."}]
'''
          },
          {'role': 'user', 'content': storyText},
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode != 200) return [];

    try {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content']
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final suggestions = jsonDecode(content) as List;

      return suggestions.map((s) => PromptSuggestion(
        type: SuggestionType.values.firstWhere(
          (t) => t.name == s['type'],
          orElse: () => SuggestionType.visual,
        ),
        text: s['text'],
      )).toList();
    } catch (_) {
      return [];
    }
  }

  /// Quick local suggestions (no API call) for common patterns.
  List<PromptSuggestion> getLocalSuggestions(String storyText) {
    final suggestions = <PromptSuggestion>[];
    final lower = storyText.toLowerCase();

    if (!lower.contains('rain') && !lower.contains('storm') && lower.contains('sad')) {
      suggestions.add(PromptSuggestion(
        type: SuggestionType.atmosphere,
        text: 'Add rain to amplify the melancholy mood',
      ));
    }

    if (!lower.contains('mirror') && !lower.contains('reflection')) {
      suggestions.add(PromptSuggestion(
        type: SuggestionType.visual,
        text: 'A mirror reflection adds visual depth to any scene',
      ));
    }

    if (lower.contains('dialogue') || lower.contains('said') || lower.contains('says')) {
      suggestions.add(PromptSuggestion(
        type: SuggestionType.character,
        text: 'Show emotion through action, not just dialogue',
      ));
    }

    if (lower.contains('run') || lower.contains('chase')) {
      suggestions.add(PromptSuggestion(
        type: SuggestionType.visual,
        text: 'Use a tracking shot to sell the urgency',
      ));
    }

    return suggestions;
  }
}

enum SuggestionType { visual, atmosphere, character }

class PromptSuggestion {
  final SuggestionType type;
  final String text;

  PromptSuggestion({required this.type, required this.text});

  IconData get icon {
    switch (type) {
      case SuggestionType.visual:
        return Icons.videocam;
      case SuggestionType.atmosphere:
        return Icons.cloud;
      case SuggestionType.character:
        return Icons.person;
    }
  }

  Color get color {
    switch (type) {
      case SuggestionType.visual:
        return const Color(0xFF00D4AA);
      case SuggestionType.atmosphere:
        return const Color(0xFF6C5CE7);
      case SuggestionType.character:
        return const Color(0xFFFF6B6B);
    }
  }
}
