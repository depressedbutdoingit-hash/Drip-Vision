import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DripButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? glowColor;
  final double? width;
  final double? height;
  const DripButton({super.key, required this.onPressed, required this.child, this.glowColor, this.width, this.height});
  @override State<DripButton> createState() => _DripButtonState();
}

class _DripButtonState extends State<DripButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressed = false;
  final _random = Random();
  final List<_LiquidDrop> _drops = [];

  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 760))..addListener(() { if (mounted) setState(() {}); }); }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  void _activate() {
    if (widget.onPressed == null) return;
    final c = widget.glowColor ?? DripTheme.cosmicTeal;
    _drops
      ..clear()
      ..addAll(List.generate(3, (i) => _LiquidDrop(x: .27 + i * .23 + (_random.nextDouble()-.5)*.08, size: 2.4 + _random.nextDouble()*2.2, distance: 10 + _random.nextDouble()*13, delay: i * .055)));
    _controller.forward(from: 0);
    widget.onPressed!.call();
    Future.delayed(const Duration(milliseconds: 820), () { if (mounted) setState(() => _drops.clear()); });
  }

  @override Widget build(BuildContext context) {
    final c = widget.glowColor ?? DripTheme.cosmicTeal;
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null ? null : (_) { setState(() => _pressed = false); _activate(); },
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width, height: widget.height,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? Colors.white12 : c,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: c.withOpacity(_pressed ? .32 : .12), blurRadius: _pressed ? 22 : 12, spreadRadius: _pressed ? 1 : 0)],
          ),
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [widget.child, if (_drops.isNotEmpty) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _LiquidPainter(drops: _drops, progress: _controller.value))))]),
        ),
      ),
    );
  }
}

class _LiquidDrop { final double x, size, distance, delay; _LiquidDrop({required this.x, required this.size, required this.distance, required this.delay}); }
class _LiquidPainter extends CustomPainter {
  final List<_LiquidDrop> drops; final double progress;
  _LiquidPainter({required this.drops, required this.progress});
  @override void paint(Canvas canvas, Size size) {
    for (final d in drops) {
      if (progress < d.delay) continue;
      final t = ((progress-d.delay)/(1-d.delay)).clamp(0.0,1.0);
      final eased = Curves.easeInCubic.transform(t);
      final fade = (1-Curves.easeIn.transform(t)).clamp(0.0,1.0);
      final y = size.height - 1 + eased*d.distance;
      final stretch = 1 + sin(min(t,1)*pi)*1.8;
      final paint = Paint()..color = DripTheme.cosmicTeal.withOpacity(.72*fade)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);
      canvas.save(); canvas.translate(size.width*d.x, y); canvas.scale(1, stretch); canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: d.size*1.35, height: d.size*2.0), paint); canvas.restore();
    }
  }
  @override bool shouldRepaint(covariant _LiquidPainter oldDelegate) => true;
}
