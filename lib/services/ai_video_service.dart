import 'dart:convert';
import 'package:http/http.dart' as http;

class AiVideoService {
  Future<String?> generateVideo({
    required String prompt,
    String? characterDna,
    String style = 'cinematic',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend.com/generate-video'), // your Cloud Function or OpenRouter proxy
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'character_dna': characterDna,
          'style': style,
          'duration': 5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['video_url'] as String?;
      }
    } catch (_) {}
    return null;
  }
}