import 'package:flutter/material.dart';

class EditBayScreen extends StatelessWidget {
  const EditBayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EDIT BAY')),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('CROP • TRIM • SPLIT • AI REMIXER • EXPORT', style: TextStyle(fontSize: 18)), SizedBox(height: 32), ElevatedButton(onPressed: () {}, child: const Text('AI REMIXER (Continuity Fixed)')),])),
    );
  }
}