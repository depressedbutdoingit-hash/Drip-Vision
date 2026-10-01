import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote app config from God Mode → admin_config/app
class AppRemoteConfig {
  final bool maintenanceMode;
  final String announcement;

  const AppRemoteConfig({
    this.maintenanceMode = false,
    this.announcement = '',
  });

  factory AppRemoteConfig.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const AppRemoteConfig();
    return AppRemoteConfig(
      maintenanceMode: m['maintenanceMode'] == true,
      announcement: (m['announcement'] ?? '').toString().trim(),
    );
  }

  bool get hasBanner =>
      maintenanceMode || announcement.isNotEmpty;
}

final appRemoteConfigProvider = StreamProvider<AppRemoteConfig>((ref) {
  return FirebaseFirestore.instance
      .collection('admin_config')
      .doc('app')
      .snapshots()
      .map((snap) => AppRemoteConfig.fromMap(snap.data()));
});
