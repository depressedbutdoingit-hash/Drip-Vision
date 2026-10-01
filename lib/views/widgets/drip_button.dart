import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

/// Primary action — solid, quiet, expensive. No particle effects.
class DripButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? glowColor;
  final double? width;
  final double? height;

  const DripButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.glowColor,
    this.width,
    this.height,
  });

  @override
  State<DripButton> createState() => _DripButtonState();
}

class _DripButtonState extends State<DripButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final fill = widget.glowColor ?? DripTheme.cosmicTeal;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          height: widget.height ?? 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? (_pressed ? fill.withOpacity(0.88) : fill)
                : DripTheme.surfaceLight,
            borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: enabled ? DripTheme.voidBlack : DripTheme.muted,
            ),
            child: IconTheme(
              data: IconThemeData(
                size: 16,
                color: enabled ? DripTheme.voidBlack : DripTheme.muted,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
