import 'package:flutter/material.dart';

void main() {
  runApp(const DripVisionApp());
}

class DripVisionApp extends StatelessWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DripVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Color(0xFF121416),
        body: Center(
          child: Text(
            'DRIPVISION\nApp opened successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF00FFAA),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
