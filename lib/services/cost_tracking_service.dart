import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tracks actual OpenRouter costs and applies 5% markup to customer pricing.
/// 
/// Example: If OpenRouter charges $0.10, customer pays $0.105 (5% markup)
/// Token conversion: $1.00 = 1000 drip tokens (adjustable)
class CostTrackingService {
  static const double _markupPercent = 0.05; // 5% markup
  static const double _dollarsPerToken = 0.001; // $1 = 1000 tokens

  /// Pricing per 1M tokens for common models (input / output)
  /// Fetched from OpenRouter pricing. Update as needed.
  static const Map<String, ModelPricing> _pricing = {
    'anthropic/claude-3.5-sonnet': ModelPricing(inputPer1M: 3.0, outputPer1M: 15.0),
    'anthropic/claude-3-opus': ModelPricing(inputPer1M: 15.0, outputPer1M: 75.0),
    'anthropic/claude-3-haiku': ModelPricing(inputPer1M: 0.25, outputPer1M: 1.25),
    'openai/gpt-4o': ModelPricing(inputPer1M: 5.0, outputPer1M: 15.0),
    'openai/gpt-4o-mini': ModelPricing(inputPer1M: 0.15, outputPer1M: 0.60),
    'meta-llama/llama-3.1-70b-instruct': ModelPricing(inputPer1M: 0.60, outputPer1M: 0.60),
    'google/gemini-pro-1.5': ModelPricing(inputPer1M: 3.50, outputPer1M: 10.50),
    'default': ModelPricing(inputPer1M: 3.0, outputPer1M: 15.0),
  };

  /// Calculate the cost of an API call with 5% markup applied.
  /// Returns the customer-facing token cost.
  static int calculateCost({
    required String model,
    required int promptTokens,
    required int completionTokens,
  }) {
    final pricing = _pricing[model] ?? _pricing['default']!;

    final inputCost = (promptTokens / 1000000) * pricing.inputPer1M;
    final outputCost = (completionTokens / 1000000) * pricing.outputPer1M;
    final baseCost = inputCost + outputCost;
    final markedUpCost = baseCost * (1 + _markupPercent);

    // Convert dollars to drip tokens
    final tokenCost = (markedUpCost / _dollarsPerToken).ceil();
    return tokenCost > 0 ? tokenCost : 1; // Minimum 1 token
  }

  /// Record a charge in Firestore for analytics and audit trail.
  static Future<void> recordCharge({
    required String callType, // e.g. 'story_plan', 'prompt_enhance'
    required String model,
    required int promptTokens,
    required int completionTokens,
    required int tokensCharged,
    required double baseCostUsd,
    required double markedUpCostUsd,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await FirebaseFirestore.instance.collection('cost_logs').add({
      'userId': userId,
      'callType': callType,
      'model': model,
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'tokensCharged': tokensCharged,
      'baseCostUsd': baseCostUsd,
      'markedUpCostUsd': markedUpCostUsd,
      'markupPercent': _markupPercent,
      'timestamp': Timestamp.now(),
    });
  }

  /// Convenience: parse an OpenRouter response and charge the user.
  static ApiCallResult parseAndCharge({
    required String callType,
    required String model,
    required Map<String, dynamic> responseData,
  }) {
    final usage = responseData['usage'] as Map<String, dynamic>? ?? {};
    final promptTokens = (usage['prompt_tokens'] ?? 0) as int;
    final completionTokens = (usage['completion_tokens'] ?? 0) as int;

    final pricing = _pricing[model] ?? _pricing['default']!;
    final inputCost = (promptTokens / 1000000) * pricing.inputPer1M;
    final outputCost = (completionTokens / 1000000) * pricing.outputPer1M;
    final baseCost = inputCost + outputCost;
    final markedUpCost = baseCost * (1 + _markupPercent);
    final tokenCost = (markedUpCost / _dollarsPerToken).ceil();
    final finalTokenCost = tokenCost > 0 ? tokenCost : 1;

    recordCharge(
      callType: callType,
      model: model,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      tokensCharged: finalTokenCost,
      baseCostUsd: baseCost,
      markedUpCostUsd: markedUpCost,
    );

    return ApiCallResult(
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      tokenCost: finalTokenCost,
      baseCostUsd: baseCost,
      markedUpCostUsd: markedUpCost,
    );
  }
}

class ModelPricing {
  final double inputPer1M;
  final double outputPer1M;

  const ModelPricing({required this.inputPer1M, required this.outputPer1M});
}

class ApiCallResult {
  final int promptTokens;
  final int completionTokens;
  final int tokenCost;
  final double baseCostUsd;
  final double markedUpCostUsd;

  ApiCallResult({
    required this.promptTokens,
    required this.completionTokens,
    required this.tokenCost,
    required this.baseCostUsd,
    required this.markedUpCostUsd,
  });
}
