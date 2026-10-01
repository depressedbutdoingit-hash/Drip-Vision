import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../services/app_config_service.dart';

/// Shows maintenance / announcement from God Mode admin_config.
class SystemBannerHost extends ConsumerWidget {
  final Widget child;
  const SystemBannerHost({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appRemoteConfigProvider);
    final config = configAsync.valueOrNull ?? const AppRemoteConfig();

    if (!config.hasBanner) return child;

    return Column(
      children: [
        Material(
          color: config.maintenanceMode
              ? const Color(0xFF3A1818)
              : const Color(0xFF12201C),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    config.maintenanceMode
                        ? Icons.build_circle_outlined
                        : Icons.campaign_outlined,
                    size: 18,
                    color: config.maintenanceMode
                        ? const Color(0xFFFF8A80)
                        : DripTheme.cosmicTeal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.maintenanceMode ? 'MAINTENANCE' : 'NOTICE',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                            color: config.maintenanceMode
                                ? const Color(0xFFFF8A80)
                                : DripTheme.cosmicTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config.maintenanceMode
                              ? (config.announcement.isEmpty
                                  ? 'DripVision is temporarily under maintenance.'
                                  : config.announcement)
                              : config.announcement,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: DripTheme.warmWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
