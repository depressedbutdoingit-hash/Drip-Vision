import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/drip_logo.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _glowController;

  late Animation<double> _progress;
  late Animation<double> _fade;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 2, milliseconds: 400));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

    _progress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _glow = Tween<double>(begin: 0.25, end: 1).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _fadeController.forward();
    _progressController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fade, _progress, _glow]),
          builder: (context, _) {
            return Opacity(
              opacity: _fade.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DripTheme.teal.withOpacity(_glow.value * 0.7), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: DripTheme.teal.withOpacity(0.25 * _glow.value),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(child: DripSplashMark()),
                  ),
                  const SizedBox(height: 36),
                  const DripLogo(size: 36),
                  const SizedBox(height: 8),
                  Text('AI FILMMAKING STUDIO', style: DripTheme.overline.copyWith(color: DripTheme.silver)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: DripTheme.gunmetal,
                        color: DripTheme.teal,
                        minHeight: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
