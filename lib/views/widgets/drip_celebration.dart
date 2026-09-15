import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A celebratory drip cascade that triggers when a scene is created.
/// Use: DripCelebration.show(context);
class DripCelebration extends StatefulWidget {
  final VoidCallback? onComplete;

  const DripCelebration({super.key, this.onComplete});

  static void show(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => DripCelebration(
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<DripCelebration> createState() => _DripCelebrationState();
}

class _DripCelebrationState extends State<DripCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_CelebrationDrip> _drips = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _spawnDrips();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _spawnDrips() {
    for (int i = 0; i < 30; i++) {
      _drips.add(_CelebrationDrip(
        x: _random.nextDouble(),
        startDelay: _random.nextDouble() * 0.5,
        fallDuration: _random.nextDouble() * 0.8 + 0.6,
        size: _random.nextDouble() * 5 + 2,
        color: [
          DripTheme.cosmicTeal,
          Colors.white,
          Colors.cyanAccent,
          Colors.purpleAccent,
        ][_random.nextInt(4)].withOpacity(_random.nextDouble() * 0.5 + 0.3),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _CelebrationPainter(
              drips: _drips,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _CelebrationDrip {
  final double x;
  final double startDelay;
  final double fallDuration;
  final double size;
  final Color color;

  _CelebrationDrip({
    required this.x,
    required this.startDelay,
    required this.fallDuration,
    required this.size,
    required this.color,
  });
}

class _CelebrationPainter extends CustomPainter {
  final List<_CelebrationDrip> drips;
  final double progress;

  _CelebrationPainter({required this.drips, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drip in drips) {
      final startTime = drip.startDelay;
      final endTime = startTime + drip.fallDuration;

      if (progress < startTime || progress > endTime) continue;

      final localProgress = (progress - startTime) / drip.fallDuration;
      final y = localProgress * size.height * 1.2;
      final centerX = drip.x * size.width;
      final alpha = (1 - localProgress).clamp(0.0, 1.0);

      // Main drip
      final paint = Paint()
        ..color = drip.color.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(centerX, y),
        drip.size * (1 - localProgress * 0.3),
        paint,
      );

      // Splash at bottom
      if (localProgress > 0.8) {
        final splashAlpha = ((localProgress - 0.8) / 0.2).clamp(0.0, 1.0);
        final splashPaint = Paint()
          ..color = drip.color.withOpacity(alpha * (1 - splashAlpha))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        for (int i = 0; i < 3; i++) {
          final angle = (i / 3) * pi + pi;
          final dist = splashAlpha * 20;
          canvas.drawCircle(
            Offset(
              centerX + cos(angle) * dist,
              size.height - 10 + sin(angle) * dist * 0.3,
            ),
            drip.size * 0.5 * (1 - splashAlpha),
            splashPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
