import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Brand lockup — gunmetal field, teal "Vision", droplet accents.
class DripLogo extends StatelessWidget {
  final double size;
  final bool showTopLabel;
  final bool compact;

  const DripLogo({
    super.key,
    this.size = 28,
    this.showTopLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Drip',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w600,
                color: DripTheme.warmWhite,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            TextSpan(
              text: 'Vision',
              style: TextStyle(
                fontSize: size * 0.55,
                fontWeight: FontWeight.w700,
                color: DripTheme.cosmicTeal,
                letterSpacing: -0.5,
                height: 1,
                shadows: const [
                  Shadow(color: Color(0x6600D4AA), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTopLabel)
          Text(
            'Drip',
            style: TextStyle(
              fontSize: size * 0.28,
              color: DripTheme.chrome,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        if (showTopLabel) SizedBox(height: size * 0.15),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Drip\n',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w600,
                  color: DripTheme.warmWhite,
                  height: 0.95,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'Vision',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w700,
                  color: DripTheme.cosmicTeal,
                  height: 0.95,
                  letterSpacing: -1,
                  shadows: const [
                    Shadow(color: Color(0x8800D4AA), blurRadius: 18),
                  ],
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Animated splash identity — droplets + soft orbit.
class DripSplashMark extends StatefulWidget {
  final Duration duration;
  const DripSplashMark({super.key, this.duration = const Duration(milliseconds: 1800)});

  @override
  State<DripSplashMark> createState() => _DripSplashMarkState();
}

class _DripSplashMarkState extends State<DripSplashMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_c.value);
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft drip silhouettes in bg
              Positioned.fill(
                child: CustomPaint(
                  painter: _DripFieldPainter(progress: t),
                ),
              ),
              Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.92 + 0.08 * t,
                  child: const DripLogo(size: 42, showTopLabel: true),
                ),
              ),
              // Falling droplets under Vision
              ...List.generate(5, (i) {
                final phase = ((t * 1.2) - i * 0.12).clamp(0.0, 1.0);
                return Positioned(
                  top: 130 + phase * 50,
                  left: 90.0 + i * 12 - 20,
                  child: Opacity(
                    opacity: (1 - phase) * 0.9,
                    child: Icon(
                      Icons.water_drop,
                      size: 8 + (i % 3).toDouble(),
                      color: DripTheme.cosmicTeal.withOpacity(0.85),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _DripFieldPainter extends CustomPainter {
  final double progress;
  _DripFieldPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.fill;
    final path = Path();
    // soft background drips
    path.addOval(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.15 * progress),
        radius: 28));
    path.addOval(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.25), radius: 40));
    canvas.drawPath(path, paint);

    // orbit dots
    final orbit = Paint()..color = DripTheme.cosmicTeal.withOpacity(0.55);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = 70.0;
    for (var i = 0; i < 16; i++) {
      final a = (i / 16) * math.pi * 2 + progress * math.pi * 2;
      final x = cx + math.cos(a) * r;
      final y = cy + math.sin(a) * (r * 0.45);
      canvas.drawCircle(Offset(x, y), 1.4, orbit);
    }
  }

  @override
  bool shouldRepaint(covariant _DripFieldPainter old) =>
      old.progress != progress;
}
