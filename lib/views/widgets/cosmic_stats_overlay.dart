import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/providers.dart';

class CosmicStatsOverlay extends ConsumerWidget {
  const CosmicStatsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final scenes = ref.watch(sceneListProvider);

    return userProfile.when(
      data: (profile) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: DripTheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DripTheme.cosmicTeal.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: DripTheme.cosmicTeal.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                icon: Icons.token,
                label: 'TOKENS',
                value: '${profile.tokenBalance}',
                color: DripTheme.cosmicTeal,
              ),
              _StatDivider(),
              _StatItem(
                icon: Icons.movie_filter,
                label: 'SCENES',
                value: '${scenes.length}',
                color: DripTheme.nebulaCyan,
              ),
              _StatDivider(),
              _StatItem(
                icon: Icons.bolt,
                label: 'TIER',
                value: profile.subscriptionTier.toUpperCase(),
                color: profile.isAdmin
                    ? const Color(0xFFFFD700)
                    : profile.isPro
                        ? DripTheme.cosmicTeal
                        : DripTheme.chrome,
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: DripTheme.cosmicTeal.withOpacity(0.2),
    );
  }
}
