import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'services/purchase_service.dart';
import 'services/push_notification_service.dart';
import 'services/crashlytics_service.dart';
import 'views/screens/main_navigation.dart';
import 'views/screens/auth_screen.dart';
import 'views/screens/story_planner_screen.dart';
import 'views/screens/production_queue_screen.dart';
import 'views/screens/character_creation_screen.dart';
import 'views/screens/music_studio_screen.dart';
import 'views/screens/custom_outfit_creator.dart';

/// True after Firebase.initializeApp succeeds. When false, auth and
/// Firebase-backed services are skipped so the UI can still open.
bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is optional — always end up initialized so Env.* never throws.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    try {
      await dotenv.load(fileName: 'assets/.env');
    } catch (e, st) {
      // Empty init so dotenv.isInitialized is true
      dotenv.testLoad(fileInput: '');
      debugPrint('dotenv load skipped: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  // Firebase is required for full features but must not crash cold start.
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e, st) {
    firebaseReady = false;
    debugPrint('Firebase.initializeApp failed — running in offline UI mode: $e');
    debugPrintStack(stackTrace: st);
  }

  if (firebaseReady) {
    await _safeInit('Crashlytics', CrashlyticsService.init);
    await _safeInit('Purchases', PurchaseService.init);
    await _safeInit('Push', PushNotificationService.init);
  } else {
    debugPrint('Skipping Crashlytics / Purchases / Push (Firebase not ready)');
  }

  runApp(const ProviderScope(child: DripVisionApp()));
}

Future<void> _safeInit(String name, Future<void> Function() init) async {
  try {
    await init();
  } catch (e, st) {
    debugPrint('$name init failed (non-fatal): $e');
    debugPrintStack(stackTrace: st);
  }
}

class DripVisionApp extends ConsumerWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Without Firebase, skip the auth gate and open the main UI.
    if (!firebaseReady) {
      return MaterialApp(
        title: 'DripVision',
        debugShowCheckedModeBanner: false,
        theme: DripTheme.theme,
        home: const MainNavigation(),
        routes: _routes,
      );
    }

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'DripVision',
      debugShowCheckedModeBanner: false,
      theme: DripTheme.theme,
      home: authState.when(
        data: (user) => user != null
            ? const MainNavigation()
            : const AuthScreen(),
        loading: () => const Scaffold(
          backgroundColor: DripTheme.voidBlack,
          body: Center(
            child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
          ),
        ),
        error: (err, _) {
          debugPrint('authState error: $err');
          // Still open the app so a misconfigured Firebase doesn't brick launch.
          return const MainNavigation();
        },
      ),
      routes: _routes,
    );
  }
}

Map<String, WidgetBuilder> get _routes => {
      '/story-planner': (context) => const StoryPlannerScreen(),
      '/production': (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is StoryPlan) {
          return ProductionQueueScreen(plan: args);
        }
        return const StoryPlannerScreen();
      },
      '/character-create': (context) => const CharacterCreationScreen(),
      '/music-studio': (context) => const MusicStudioScreen(),
      '/custom-outfit': (context) => const CustomOutfitCreator(),
    };
