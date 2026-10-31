import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: DripVisionApp()));
}

class DripVisionApp extends StatelessWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DripVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121416),
        primaryColor: const Color(0xFF00FFAA),
      ),
      home: const SplashScreen(),
    );
  }
}
