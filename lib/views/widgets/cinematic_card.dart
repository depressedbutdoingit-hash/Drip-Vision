import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CinematicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool selected;

  const CinematicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = DripTheme.radiusMd,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: padding,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0x1400D4AA)
            : DripTheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected
              ? DripTheme.cosmicTeal.withOpacity(0.45)
              : DripTheme.hairline,
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: DripTheme.cosmicTeal.withOpacity(0.06),
        highlightColor: Colors.white.withOpacity(0.02),
        child: content,
      ),
    );
  }
}
