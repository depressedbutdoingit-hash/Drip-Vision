import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class AdGeneratorScreen extends ConsumerStatefulWidget {
  const AdGeneratorScreen({super.key});
  @override
  ConsumerState<AdGeneratorScreen> createState() => _AdGeneratorScreenState();
}

class _AdGeneratorScreenState extends ConsumerState<AdGeneratorScreen> {
  final _product = TextEditingController();
  final _benefit = TextEditingController();
  final _audience = TextEditingController();
  bool _loading = false;
  String? _script;
  String? _imageUrl;
  String? _error;

  @override
  void dispose() {
    _product.dispose();
    _benefit.dispose();
    _audience.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final product = _product.text.trim();
    if (product.isEmpty) return;
    setState(() { _loading = true; _error = null; _script = null; _imageUrl = null; });
    try {
      final openRouter = ref.read(openRouterProvider);
      final ai = ref.read(aiGenerationServiceProvider);
      final prompt = 'Write a short 15-30s ad script for "$product". Benefit: ${_benefit.text.trim().isEmpty ? "premium quality" : _benefit.text.trim()}. Audience: ${_audience.text.trim().isEmpty ? "general" : _audience.text.trim()}. Include hook, problem, solution, CTA.';
      final script = await openRouter.generateText(prompt);
      final imagePrompt = 'Cinematic product ad photo of $product, professional lighting, high end commercial photography, ${_benefit.text.trim()}';
      final image = await ai.generateImage(prompt: imagePrompt, quality: 'standard');
      setState(() { _script = script; _imageUrl = image; });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121416),
      appBar: AppBar(title: const Text('AD GENERATOR'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product', style: TextStyle(color: Colors.white70)),
              TextField(controller: _product, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'e.g. Wireless earbuds')),
              const SizedBox(height: 12),
              const Text('Key benefit', style: TextStyle(color: Colors.white70)),
              TextField(controller: _benefit, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Audience', style: TextStyle(color: Colors.white70)),
              TextField(controller: _audience, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _loading ? null : _generate,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('GENERATE AD'),
                ),
              ),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: Colors.redAccent))],
              if (_imageUrl != null) ...[
                const SizedBox(height: 20),
                Image.network(_imageUrl!, height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Text('Image failed to load', style: TextStyle(color: Colors.white54))),
              ],
              if (_script != null) ...[
                const SizedBox(height: 16),
                const Text('Script', style: TextStyle(color: Color(0xFF00FFAA), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1A1F24), borderRadius: BorderRadius.circular(8)),
                  child: Text(_script!, style: const TextStyle(color: Colors.white, height: 1.4)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
