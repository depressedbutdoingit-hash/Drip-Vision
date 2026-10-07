import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Quiet empty state — one line of studio language, no illustration clutter.
class StudioEmpty extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StudioEmpty({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w500,
                color: DripTheme.chrome,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: DripTheme.meta,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.6,
                    color: DripTheme.cosmicTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
