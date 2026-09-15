import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GalaxyBackground extends StatefulWidget {
  final int starCount;
  final double intensity;
  final bool showDrips;

  const GalaxyBackground({
    super.key,
    this.starCount = 100,
    this.intensity = 0.4,
    this.showDrips = true,
  });

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with TickerProviderStateMixin {
  late AnimationController _twinkleController;
  late AnimationController _dripController;
  final List<_TwinkleStar> _stars = [];
  final List<_Drip> _drips = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _dripController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _generateStars();
    _scheduleDrips();
  }

  void _generateStars() {
    for (int i = 0; i < widget.starCount; i++) {
      _stars.add(_TwinkleStar(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 0.5,
        baseOpacity: _random.nextDouble() * 0.6 + 0.2,
        twinklePhase: _random.nextDouble() * pi * 2,
        twinkleSpeed: _random.nextDouble() * 2 + 0.5,
        color: _random.nextBool()
            ? Colors.white
            : DripTheme.cosmicTeal.withOpacity(0.8),
      ));
    }
  }

  void _scheduleDrips() {
    if (!widget.showDrips) return;
    Future.delayed(Duration(seconds: _random.nextInt(5) + 3), () {
      if (mounted) {
        _spawnDrip();
        _scheduleDrips();
      }
    });
  }

  void _spawnDrip() {
    setState(() {
      _drips.add(_Drip(
        x: _random.nextDouble(),
        startY: -0.05,
        speed: _random.nextDouble() * 0.3 + 0.2,
        size: _random.nextDouble() * 3 + 2,
        color: _random.nextBool()
            ? DripTheme.cosmicTeal.withOpacity(0.6)
            : Colors.white.withOpacity(0.4),
      ));
    });
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _dripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Deep space base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF02040A),
                Color(0xFF0A1628),
                Color(0xFF0D1B2A),
                Color(0xFF02040A),
              ],
            ),
          ),
        ),
        // Twinkling stars
        AnimatedBuilder(
          animation: _twinkleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _TwinklePainter(
                stars: _stars,
                animation: _twinkleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Falling drips
        if (widget.showDrips)
          AnimatedBuilder(
            animation: _dripController,
            builder: (context, child) {
              return CustomPaint(
                painter: _DripPainter(
                  drips: _drips,
                  animation: _dripController.value,
                  onDripComplete: (drip) {
                    setState(() => _drips.remove(drip));
                  },
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class _TwinkleStar {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double twinklePhase;
  final double twinkleSpeed;
  final Color color;

  _TwinkleStar({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinklePhase,
    required this.twinkleSpeed,
    required this.color,
  });
}

class _Drip {
  final double x;
  double startY;
  final double speed;
  final double size;
  final Color color;
  double progress = 0;

  _Drip({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _TwinklePainter extends CustomPainter {
  final List<_TwinkleStar> stars;
  final double animation;

  _TwinklePainter({required this.stars, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = sin(animation * pi * 2 * star.twinkleSpeed + star.twinklePhase);
      final opacity = star.baseOpacity * (0.5 + 0.5 * twinkle);

      // Star core
      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );

      // Glow for larger stars
      if (star.size > 1.5) {
        final glowPaint = Paint()
          ..color = DripTheme.cosmicTeal.withOpacity(opacity * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.size * 5,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DripPainter extends CustomPainter {
  final List<_Drip> drips;
  final double animation;
  final void Function(_Drip) onDripComplete;

  _DripPainter({
    required this.drips,
    required this.animation,
    required this.onDripComplete,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final drip in drips) {
      drip.progress += drip.speed * 0.016;
      final currentY = drip.startY + drip.progress;

      if (currentY > 1.1) {
        onDripComplete(drip);
        continue;
      }

      // Drip body (teardrop shape)
      final path = Path();
      final centerX = drip.x * size.width;
      final centerY = currentY * size.height;
      final r = drip.size;

      path.moveTo(centerX, centerY - r * 1.5);
      path.quadraticBezierTo(
        centerX + r, centerY - r * 0.5,
        centerX + r, centerY + r * 0.5,
      );
      path.arcToPoint(
        Offset(centerX - r, centerY + r * 0.5),
        radius: Radius.circular(r),
        clockwise: false,
      );
      path.quadraticBezierTo(
        centerX - r, centerY - r * 0.5,
        centerX, centerY - r * 1.5,
      );
      path.close();

      final paint = Paint()
        ..color = drip.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawPath(path, paint);

      // Tiny glow trail
      final trailPaint = Paint()
        ..color = drip.color.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        Offset(centerX, centerY + r * 2),
        r * 2,
        trailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
