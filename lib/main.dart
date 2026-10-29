
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/crashlytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await CrashlyticsService.init();
    debugPrint('DripVision: Firebase initialized successfully.');
  } catch (e, st) {
    debugPrint('DripVision: Firebase initialization failed: $e');
    debugPrint('$st');
  }

  runApp(const ProviderScope(child: DripVisionApp()));
}

class DripVisionApp extends StatelessWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DripVision Startup Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        primaryColor: const Color(0xFF00D4AA),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      locale: const Locale('en'),
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(
        backgroundColor: Color(0xFF0B0F14),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.movie_creation_outlined,
                  color: Color(0xFF00D4AA),
                  size: 64,
                ),
                SizedBox(height: 24),
                Text(
                  'DRIPVISION',
                  style: TextStyle(
                    color: Color(0xFF00D4AA),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'STARTUP TEST',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
