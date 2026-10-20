import 'package:flutter/material.dart';

class CharacterCreatorScreen extends StatelessWidget {
  const CharacterCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHARACTER CREATOR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '1-shot or 5-shot character creation with meta-adaptation',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('CREATE WITH 1 PHOTO'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('5-SHOT CREATION'),
            ),
          ],
        ),
      ),
    );
  }
}

// Lets the rest of the app use either name.
typedef CharacterCreationScreen = CharacterCreatorScreen;