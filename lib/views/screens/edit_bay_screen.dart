import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class EditBayScreen extends ConsumerWidget {
  const EditBayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(continuityEngineProvider);
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(title: const Text('EDIT BAY')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CROP • TRIM • SPLIT • AI REMIXER • EXPORT', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ AI Remixer + Continuity Fix Applied')),
                );
              },
              child: const Text('AI REMIXER (Continuity Fixed)'),
            ),
          ],
        ),
      ),
    );
  }
}