import 'package:flutter/material.dart';
import 'drip_button.dart';
import '../../core/theme.dart';

class CinematicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;

  const CinematicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (primary) {
      return DripButton(
        onPressed: onPressed,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: DripTheme.warmWhite,
          disabledForegroundColor: DripTheme.muted,
          side: const BorderSide(color: DripTheme.hairlineStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DripTheme.radiusMd),
          ),
          backgroundColor: const Color(0x06FFFFFF),
        ),
        child: child,
      ),
    );
  }
}
