import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'studio_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudioHomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DripTheme.teal, width: 2),
              ),
              child: const Center(
                child: Text(
                  'DV',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: DripTheme.teal,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DRIPVISION',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'An AI filmmaking studio',
              style: DripTheme.meta,
            ),
            const SizedBox(height: 48),

            // Loading bar
            SizedBox(
              width: 180,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progress.value,
                    backgroundColor: DripTheme.gunmetal,
                    color: DripTheme.teal,
                    minHeight: 3,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}