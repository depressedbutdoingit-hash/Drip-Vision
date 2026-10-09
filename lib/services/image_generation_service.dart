import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../core/ai_tiers.dart';
import '../core/env.dart';
import '../core/product_models.dart';

class ImageGenerationException implements Exception {
  final String message;
  ImageGenerationException(this.message);
  @override
  String toString() => message;
}

/// Live image generation via OpenRouter Image API:
/// POST https://openrouter.ai/api/v1/images
class ImageGenerationService {
  final Dio _dio;

  ImageGenerationService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://openrouter.ai/api/v1/',
            headers: {
              'Authorization': 'Bearer ${Env.openRouterKey}',
              'HTTP-Referer': 'https://dripvision.app',
              'X-Title': 'DripVision',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(minutes: 1),
            receiveTimeout: const Duration(minutes: 3),
          ),
        );

  /// Returns a local file path (png) or https URL if the API returns one.
  Future<String> generate({
    required String prompt,
    ImageGenTier tier = ImageGenTier.standard,
    String? modelOverride,
    String aspectRatio = '16:9',
    String resolution = '1K',
    List<String>? referenceImageUrls,
  }) async {
    if (Env.openRouterKey.isEmpty) {
      throw ImageGenerationException(
        'OPENROUTER_KEY is missing. Add it to your .env file.',
      );
    }

    final model = (modelOverride != null && modelOverride.isNotEmpty)
        ? modelOverride
        : AiTiers.imageModelId(tier);

    final payload = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      'aspect_ratio': aspectRatio,
      'resolution': resolution,
      'n': 1,
      if (referenceImageUrls != null && referenceImageUrls.isNotEmpty)
        'input_references': [
          for (final url in referenceImageUrls.take(4))
            {
              'type': 'image_url',
              'image_url': {'url': url},
            },
        ],
    };

    try {
      final response = await _dio.post('images', data: payload);
      final data = response.data;
      if (data is! Map) {
        throw ImageGenerationException('Unexpected image API response.');
      }

      final list = data['data'] as List?;
      if (list == null || list.isEmpty) {
        throw ImageGenerationException('No image returned from OpenRouter.');
      }

      final first = list.first as Map;
      final b64 = first['b64_json'] as String?;
      final url = first['url'] as String?;

      if (url != null && url.startsWith('http')) {
        return url;
      }
      if (b64 == null || b64.isEmpty) {
        throw ImageGenerationException('Image payload missing b64_json/url.');
      }

      return _saveB64Png(b64);
    } on DioException catch (e) {
      final detail = e.response?.data;
      final message = detail is Map
          ? (detail['error']?['message'] ?? detail['message'] ?? e.message)
          : e.message;
      throw ImageGenerationException('Image generation failed: $message');
    }
  }

  Future<String> generateForProduct({
    required String prompt,
    required String quality, // draft | standard | pro
    String? modelOverride,
    List<String>? referenceImageUrls,
  }) {
    final tier = switch (quality.toLowerCase()) {
      'pro' || 'poster' || 'cinema' => ImageGenTier.pro,
      'draft' => ImageGenTier.draft,
      'board' || 'storyboard_board' => ImageGenTier.board,
      _ => ImageGenTier.standard,
    };
    return generate(
      prompt: prompt,
      tier: tier,
      modelOverride: modelOverride,
      referenceImageUrls: referenceImageUrls,
      aspectRatio: tier == ImageGenTier.pro ? '1:1' : '16:9',
    );
  }

  Future<String> _saveB64Png(String b64) async {
    final bytes = base64Decode(b64);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/drip_img_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(Uint8List.fromList(bytes));
    return file.path;
  }
}
