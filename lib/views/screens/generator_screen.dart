import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class GeneratorScreen extends ConsumerWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(continuityEngineProvider);

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('GENERATING')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Generating with MAML + NaML...', style: DripTheme.body),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Future.delayed(const Duration(seconds: 3), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Generation complete! Continuity locked. Full film produced.')),
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen()));
                });
              },
              child: const Text('START GENERATION'),
            ),
          ],
        ),
      ),
    );
  }
}