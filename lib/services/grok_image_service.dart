import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/env.dart';

class GrokImageService {
  static const _endpoint = 'https://api.x.ai/v1/images/generations';

  Future<String?> generate({
    required String prompt,
    String style = 'cinematic',
  }) async {
    final key = Env.openRouterKey; // Prefer OpenRouter; xAI direct key can be added to Env later
    if (key.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'prompt': '$prompt, $style, highly detailed, cinematic lighting',
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?[0]?['url'] as String?;
      }
    } catch (_) {
      // Silent fail — caller handles null
    }
    return null;
  }
}