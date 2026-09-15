import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.eyebrow, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow, style: const TextStyle(fontSize: 10, letterSpacing: 2.8, color: DripTheme.cosmicTeal, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 24, height: 1.05, fontWeight: FontWeight.w600, color: DripTheme.warmWhite)),
      ])),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: DripTheme.chrome, fontSize: 12))),
    ]),
  );
}
