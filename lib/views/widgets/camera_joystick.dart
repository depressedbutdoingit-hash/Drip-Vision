import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CameraMotionJoystick extends StatefulWidget {
  final Function(String motionType) onMotionSelected;
  final String? initialSelection;

  const CameraMotionJoystick({
    super.key,
    required this.onMotionSelected,
    this.initialSelection,
  });

  @override
  State<CameraMotionJoystick> createState() => _CameraMotionJoystickState();
}

class _CameraMotionJoystickState extends State<CameraMotionJoystick> {
  late String selectedMotion;

  final List<Map<String, dynamic>> motions = [
    {'id': 'static', 'label': 'Lock', 'icon': Icons.lock_outline},
    {'id': 'pan_right', 'label': 'Pan R', 'icon': Icons.arrow_forward},
    {'id': 'zoom_in', 'label': 'Zoom', 'icon': Icons.zoom_in},
    {'id': 'drone_up', 'label': 'Lift', 'icon': Icons.arrow_upward},
    {'id': 'whip_pan', 'label': 'Whip', 'icon': Icons.bolt},
    {'id': 'orbit', 'label': 'Orbit', 'icon': Icons.rotate_right},
  ];

  @override
  void initState() {
    super.initState();
    selectedMotion = widget.initialSelection ?? 'static';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DripTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: DripTheme.cosmicTeal.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: motions.map((m) {
            final isSelected = selectedMotion == m['id'];
            return GestureDetector(
              onTap: () {
                setState(() => selectedMotion = m['id']!);
                widget.onMotionSelected(m['id']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? DripTheme.cosmicTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: DripTheme.aquaGlow.withOpacity(0.5))
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: DripTheme.cosmicTeal.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 16,
                      color: isSelected ? DripTheme.voidBlack : DripTheme.chrome,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m['label']!,
                      style: TextStyle(
                        color: isSelected ? DripTheme.voidBlack : DripTheme.chrome,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
