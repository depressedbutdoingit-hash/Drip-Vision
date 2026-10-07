import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

/// Primary action control — gunmetal edge, liquid teal fill,
/// soft drip-glow only while pressed (not a permanent neon halo).
class DripButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const DripButton({
    super.key,
    required this.child,
    this.onPressed,
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
    final fill = DripTheme.cosmicTeal;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height ?? 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DripTheme.radiusMd),
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _pressed
                        ? const [
                            Color(0xFF1AFFE0),
                            Color(0xFF00D4AA),
                            Color(0xFF00B894),
                          ]
                        : const [
                            Color(0xFF14E0BB),
                            Color(0xFF00D4AA),
                            Color(0xFF00C49A),
                          ],
                  )
                : null,
            color: enabled ? null : DripTheme.surfaceLight,
            border: Border.all(
              color: enabled
                  ? (_pressed
                      ? const Color(0x66FFFFFF)
                      : const Color(0x28FFFFFF))
                  : DripTheme.hairline,
              width: 0.8,
            ),
            boxShadow: enabled
                ? [
                    // Soft teal “drip” bloom under the button
                    BoxShadow(
                      color: DripTheme.cosmicTeal
                          .withOpacity(_pressed ? 0.55 : 0.18),
                      blurRadius: _pressed ? 22 : 10,
                      spreadRadius: _pressed ? 1 : 0,
                      offset: Offset(0, _pressed ? 4 : 2),
                    ),
                    // Tight specular edge — reads liquid / wet
                    if (_pressed)
                      BoxShadow(
                        color: DripTheme.aquaGlow.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: -1,
                        offset: const Offset(0, -1),
                      ),
                  ]
                : null,
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
