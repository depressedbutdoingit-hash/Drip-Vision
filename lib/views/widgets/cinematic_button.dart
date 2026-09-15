import 'package:flutter/material.dart';
import 'drip_button.dart';
import '../../core/theme.dart';

class CinematicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  const CinematicButton({super.key, required this.label, this.onPressed, this.icon, this.primary = true});

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 9)],
      Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 1.7, fontWeight: FontWeight.w700)),
    ]);
    if (primary) return DripButton(onPressed: onPressed, height: 48, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: child));
    return OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: DripTheme.warmWhite, side: BorderSide(color: Colors.white.withOpacity(.12)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), minimumSize: const Size(0, 46)), child: child);
  }
}
