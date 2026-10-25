import 'dart:convert';
import 'package:http/http.dart' as http;

class GrokImageService {
  static const _endpoint = 'https://api.x.ai/v1/images/generations'; // placeholder

  Future<String?> generate({
    required String prompt,
    String style = 'cinematic',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_GROK_API_KEY', // move to backend
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
    } catch (e) {
      // handle error
    }
    return null;
  }
}