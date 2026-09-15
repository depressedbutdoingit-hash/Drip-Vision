import 'package:firebase_core/firebase_core.dart';
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
import 'views/widgets/galaxy_background.dart';
import 'views/widgets/cosmic_stats_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await CrashlyticsService.init();
  await PurchaseService.init();
  await PushNotificationService.init();
  runApp(const ProviderScope(child: DripVisionApp()));
}

class DripVisionApp extends ConsumerWidget {
  const DripVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: CircularProgressIndicator(color: DripTheme.cosmicTeal)
          ),
        ),
        error: (_, __) => const AuthScreen(),
      ),
      routes: {
        '/story-planner': (context) => const StoryPlannerScreen(),
        '/production': (context) => ProductionQueueScreen(
          plan: ModalRoute.of(context)!.settings.arguments as StoryPlan
        ),
        '/character-create': (context) => const CharacterCreationScreen(),
        '/music-studio': (context) => const MusicStudioScreen(),
        '/custom-outfit': (context) => const CustomOutfitCreator(),
      },
    );
  }
}
