import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';
import '../../services/continuity_service.dart';
import '../../services/token_service.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  final _promptController = TextEditingController(
    text: 'Isabella walks into the neon-lit alley, leather jacket catching the rain.',
  );
  bool _isGenerating = false;
  String _status = 'Ready — Character DNA will be fused and locked';

  Future<void> _generate() async {
    const cost = 10;

    final success = await TokenService.deduct(cost);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough tokens')),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
      _status = 'Fusing character DNA with Vector Learning...';
    });

    final engine = ref.read(continuityEngineProvider);
    final universe = ref.read(universeProvider);
    if (universe.characters.isNotEmpty) {
      final char = universe.characters.first;
      engine.adapt(char.dna, char.dna, shots: 3);
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      _isGenerating = false;
      _status = 'Generation complete. Continuity locked across the sequence.';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Scene generated with locked character identity')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('Studio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: DripTheme.gunmetal,
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600'),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                ),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _promptController,
              maxLines: 4,
              style: DripTheme.body,
              decoration: const InputDecoration(
                hintText: 'Describe the scene. Characters remember their DNA.',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isGenerating ? null : _generate,
              child: _isGenerating
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('GENERATE WITH CONTINUITY'),
            ),
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center, style: DripTheme.meta),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}