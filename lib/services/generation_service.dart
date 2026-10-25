import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerationService {
  // Point this at your Cloud Function or backend
  static const _endpoint = 'https://your-backend.com/generate';

  /// Returns the generated media URL, or null on failure.
  static Future<String?> generate({
    required String prompt,
    String type = 'video', // or 'image'
    Map<String, dynamic>? characterDna,
    String style = 'cinematic',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'type': type,
          'style': style,
          'character_dna': characterDna,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }
    } catch (e) {
      // log error if needed
    }
    return null;
  }
}