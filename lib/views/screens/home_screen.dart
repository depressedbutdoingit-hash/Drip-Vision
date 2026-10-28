import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/app_providers.dart';
import '../../core/theme.dart';
import '../widgets/cinematic_button.dart';
import '../widgets/cinematic_card.dart';
import 'character_lab_screen.dart';
import 'edit_bay_screen.dart';
import 'settings_screen.dart';
import 'story_planner_screen.dart';
import 'timeline_screen.dart';
import 'main_navigation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(sceneListProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'GOOD MORNING' : hour < 18 ? 'GOOD AFTERNOON' : 'GOOD EVENING';

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ... (the rest of the code I gave you earlier — it's the long one with the pipeline and cinematic cards)
            // (I already sent it in the previous message)
          ],
        ),
      ),
    );
  }
}