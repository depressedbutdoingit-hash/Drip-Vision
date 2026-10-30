import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/crashlytics_service.dart';
import 'views/screens/auth_gate.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (error) {
      debugPrint('DripVision .env load skipped: $error');
    }

    var firebaseReady = false;
    try {
      await Firebase.initializeApp();
      firebaseReady = true;
    } catch (error, stackTrace) {
      debugPrint('DripVision Firebase initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (firebaseReady) {
      try {
        await CrashlyticsService.init();
      } catch (error, stackTrace) {
        debugPrint('DripVision Crashlytics initialization failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    runApp(ProviderScope(child: DripVisionApp(firebaseReady: firebaseReady)));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class DripVisionApp extends StatelessWidget {
  const DripVisionApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (details) {
      return Material(
        color: const Color(0xFF0B0F14),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Widget error:\n${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    };

    return MaterialApp(
      title: 'DripVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        primaryColor: const Color(0xFF00D4AA),
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: const Color(0xFF00D4AA),
          secondary: const Color(0xFF00D4AA),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: firebaseReady
          ? const AuthGate()
          : const FirebaseStartupErrorScreen(),
    );
  }
}

class FirebaseStartupErrorScreen extends StatelessWidget {
  const FirebaseStartupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  color: Color(0xFF00D4AA),
                  size: 56,
                ),
                const SizedBox(height: 20),
                const Text(
                  'DripVision couldn\u2019t connect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Firebase did not initialize, so sign-in and saved projects are unavailable. Check your connection and Firebase app configuration, then try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const FirebaseRetryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry connection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FirebaseRetryScreen extends StatefulWidget {
  const FirebaseRetryScreen({super.key});

  @override
  State<FirebaseRetryScreen> createState() => _FirebaseRetryScreenState();
}

class _FirebaseRetryScreenState extends State<FirebaseRetryScreen> {
  bool _retrying = false;
  String? _error;

  Future<void> _retry() async {
    setState(() {
      _retrying = true;
      _error = null;
    });

    try {
      await Firebase.initializeApp();
      try {
        await CrashlyticsService.init();
      } catch (error) {
        debugPrint('DripVision Crashlytics retry failed: $error');
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const DripVisionApp(firebaseReady: true),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _retrying = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _retry());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_retrying) const CircularProgressIndicator(),
              if (_error != null) ...[
                const Text(
                  'Firebase connection still failed.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _retry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
