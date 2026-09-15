import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CinematicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool selected;

  const CinematicCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(18), this.radius = 18, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? DripTheme.cosmicTeal.withOpacity(.075) : DripTheme.surface.withOpacity(.88),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: selected ? DripTheme.cosmicTeal.withOpacity(.38) : Colors.white.withOpacity(.065)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.22), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      child: child,
    );
    return onTap == null ? content : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content);
  }
}
