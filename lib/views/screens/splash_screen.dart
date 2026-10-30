import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'auth_screen.dart';
import 'app_hub_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  late Animation<double> _progress;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

    _progress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _glow = Tween<double>(begin: 0.3, end: 1).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _fadeController.forward();
    _scaleController.forward();
    _progressController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AppHubScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fade, _scale, _progress, _glow]),
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DripTheme.teal.withOpacity(_glow.value),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DripTheme.teal.withOpacity(0.4 * _glow.value),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'DV',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: DripTheme.teal,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'DRIPVISION',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('AI Filmmaking Studio', style: DripTheme.meta.copyWith(fontSize: 16)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: DripTheme.gunmetal,
                      color: DripTheme.teal,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(_progress.value * 100).toInt()}%',
                    style: TextStyle(color: DripTheme.teal.withOpacity(0.8), fontSize: 12),
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
