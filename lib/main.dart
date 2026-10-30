import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional for launch. Catch everything so the app still opens.
  try {
    // Lazy-load Firebase only if available.
    // If it fails, we still run the app.
  } catch (e, st) {
    debugPrint('Startup warning: $e\n$st');
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

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
      builder: (context, child) {
        ErrorWidget.builder = (details) {
          return Scaffold(
            backgroundColor: const Color(0xFF121416),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong\n${details.exceptionAsString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
