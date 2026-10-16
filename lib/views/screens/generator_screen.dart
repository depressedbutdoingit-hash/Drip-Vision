import 'package:flutter/material.dart';

class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GENERATING')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}