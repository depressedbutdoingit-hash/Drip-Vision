import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A single selectable option inside a DirectorControlRow.
/// Deliberately not a Material ChoiceChip — flat, quiet, and restrained,
/// consistent with the rest of the DripVision surface language.
class DirectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const DirectorChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? DripTheme.cosmicTeal.withOpacity(.14) : Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? DripTheme.cosmicTeal.withOpacity(.55) : Colors.white.withOpacity(.07),
          ),
          boxShadow: selected
              ? [BoxShadow(color: DripTheme.cosmicTeal.withOpacity(.16), blurRadius: 14)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            letterSpacing: .2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? DripTheme.aquaGlow : DripTheme.chrome,
          ),
        ),
      ),
    );
  }
}

/// One full DIRECTOR MODE category: a small-caps label + a horizontally
/// scrolling row of DirectorChips.
class DirectorControlRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelect;
  const DirectorControlRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, letterSpacing: 2.4, color: DripTheme.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: options
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: DirectorChip(label: o, selected: o == value, onTap: () => onSelect(o)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
