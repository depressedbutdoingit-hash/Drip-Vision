import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/style_dna.dart';
import 'cost_tracking_service.dart';

/// Extracts a reusable Style DNA from either a reference image or a plain
/// text description of a look, using the same OpenRouter chat-completions
/// convention (and cost tracking) as AIDirectorService and
/// SmartPromptService — no separate backend, no mock data.
class StyleDnaService {
  final String _openRouterKey;
  static const _model = 'anthropic/claude-3.5-sonnet';

  StyleDnaService(this._openRouterKey);

  static const _schemaInstruction = '''
Respond ONLY as valid JSON, no markdown fences, in exactly this structure:
{
  "name": "short evocative style name, e.g. Neon Noir",
  "lens": "e.g. 35mm",
  "colorPalette": "e.g. cyan and amber",
  "lighting": "e.g. hard low-key with wet reflections",
  "grain": "e.g. fine film grain with soft halation",
  "contrast": "e.g. high contrast, crushed blacks",
  "tags": ["3-6 short concrete visual descriptors"]
}
''';

  Future<StyleDna> analyzeImage(String base64Image, {String mimeType = 'image/jpeg'}) async {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openRouterKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a cinematographer analyzing a reference image to extract a reusable visual style — lighting, lens feel, color, grain, contrast, atmosphere.'
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'Analyze the lighting, color, composition, contrast, texture, lens feeling, film characteristics and atmosphere of this image, then extract a Style DNA.\n$_schemaInstruction'},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
              },
            ],
          },
        ],
        'temperature': 0.6,
        'max_tokens': 700,
      }),
    );

    return _parse(response, sourceImageUrl: null);
  }

  Future<StyleDna> analyzeText(String description) async {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openRouterKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': 'You are a cinematographer translating a visual description into a reusable Style DNA.'},
          {'role': 'user', 'content': 'Extract a Style DNA from this description: "$description"\n$_schemaInstruction'},
        ],
        'temperature': 0.6,
        'max_tokens': 500,
      }),
    );

    return _parse(response, sourceImageUrl: null);
  }

  Future<StyleDna> _parse(http.Response response, {String? sourceImageUrl}) async {
    if (response.statusCode != 200) {
      throw Exception('Style DNA extraction failed: ${response.body}');
    }
    final data = jsonDecode(response.body);
    CostTrackingService.parseAndCharge(callType: 'style_dna_extract', model: _model, responseData: data);

    final content = data['choices'][0]['message']['content'] as String;
    final jsonStr = content.replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(jsonStr);

    return StyleDna(
      id: 'style_${DateTime.now().millisecondsSinceEpoch}',
      name: parsed['name'] ?? 'Untitled Style',
      lens: parsed['lens'] ?? '',
      colorPalette: parsed['colorPalette'] ?? '',
      lighting: parsed['lighting'] ?? '',
      grain: parsed['grain'] ?? '',
      contrast: parsed['contrast'] ?? '',
      tags: List<String>.from(parsed['tags'] ?? const []),
      sourceImageUrl: sourceImageUrl,
      createdAt: DateTime.now(),
    );
  }
}
