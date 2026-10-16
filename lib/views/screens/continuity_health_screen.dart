import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';

class ContinuityHealthScreen extends ConsumerWidget {
  const ContinuityHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(continuityHealthProvider);
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('CONTINUITY HEALTH')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${health.score}%', style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: health.color)),
            const SizedBox(height: 16),
            Text(health.message, style: DripTheme.meta),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.read(continuityHealthProvider.notifier).fix(),
              child: const Text('ONE-TAP FIX'),
            ),
          ],
        ),
      ),
    );
  }
}