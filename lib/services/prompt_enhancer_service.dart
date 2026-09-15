import 'package:dio/dio.dart';
import '../core/env.dart';

class PromptEnhancerService {
  final _dio = Dio();

  Future<String> enhancePrompt(String rawInput, String characterStyle) async {
    const systemPrompt = '''
You are an expert cinematographer. Convert input into an ultra-photorealistic visual prompt.
Inject: 35mm film grain, anamorphic lens flares, volumetric fog, Kodak Gold color balance,
photorealistic skin texture, subsurface scattering, RAW digital feel.
Keep concise but hyper-detailed. No plastic AI skin. Raw, gritty, cinematic.
''';

    final response = await _dio.post(
      'https://openrouter.ai/api/v1/chat/completions',
      options: Options(headers: {
        'Authorization': 'Bearer ${Env.openRouterKey}',
        'HTTP-Referer': 'https://dripvision.app',
        'X-Title': 'DripVision',
      }),
      data: {
        'model': 'x-ai/grok-2-1212',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': 'Character: $characterStyle. Action: $rawInput'}
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      },
    );

    return response.data['choices'][0]['message']['content'] as String;
  }
}
