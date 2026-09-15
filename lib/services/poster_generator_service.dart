import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';

/// Auto Poster Generator — Creates a shareable movie poster from a completed film.
/// 
/// Uses AI to:
/// 1. Generate a stylized keyframe image
/// 2. Add cinematic title typography
/// 3. Create a tagline
/// 4. Output a square poster (1080x1080) for social sharing
class PosterGeneratorService {
  final String _openRouterKey;

  PosterGeneratorService(this._openRouterKey);

  /// Generate a movie poster from a film plan.
  /// 
  /// Returns a poster object with image URL, title styling, and tagline.
  Future<MoviePoster> generatePoster({
    required String filmTitle,
    required String logline,
    required String genre,
    required List<String> keyScenes,
  }) async {
    // Step 1: Generate poster prompt
    final promptResponse = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openRouterKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'anthropic/claude-3.5-sonnet',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a movie poster designer. Create a vivid image prompt and a catchy tagline.'
          },
          {
            'role': 'user',
            'content': '''
Film: $filmTitle
Genre: $genre
Logline: $logline
Key scenes: ${keyScenes.join(', ')}

Create:
1. A detailed image generation prompt for a cinematic movie poster (max 100 words)
2. A catchy one-line tagline
3. Suggested color palette (3 colors)

Respond as JSON: {"prompt": "...", "tagline": "...", "colors": ["#000000", "#FFFFFF", "#FF0000"]}
'''
          },
        ],
        'temperature': 0.8,
        'max_tokens': 500,
      }),
    );

    final data = jsonDecode(promptResponse.body);
    final content = data['choices'][0]['message']['content']
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final posterData = jsonDecode(content);

    // Step 2: Generate the actual image (stub — use FAL/Stable Diffusion in production)
    // TODO: Replace with actual image generation API call
    final imageUrl = await _generateImage(posterData['prompt']);

    return MoviePoster(
      imageUrl: imageUrl,
      title: filmTitle,
      tagline: posterData['tagline'],
      colors: List<String>.from(posterData['colors']),
      genre: genre,
    );
  }

  /// Stub: Replace with FAL AI or Stable Diffusion API
  Future<String> _generateImage(String prompt) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'https://example.com/poster_${DateTime.now().millisecondsSinceEpoch}.png';
  }
}

class MoviePoster {
  final String imageUrl;
  final String title;
  final String tagline;
  final List<String> colors;
  final String genre;

  MoviePoster({
    required this.imageUrl,
    required this.title,
    required this.tagline,
    required this.colors,
    required this.genre,
  });
}
