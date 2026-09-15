import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../core/theme.dart';
import 'admin_portal.dart';

class SettingsScreen extends StatefulWidget {
  final bool isAdmin;
  const SettingsScreen({super.key, required this.isAdmin});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shorebirdCodePush = ShorebirdCodePush();
  bool _isCheckingUpdate = false;

  Future<void> _checkForOverTheAirUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final isUpdateAvailable = await _shorebirdCodePush.isNewPatchAvailableForDownload();

    if (isUpdateAvailable) {
      await _shorebirdCodePush.downloadUpdateIfAvailable();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New update downloaded! Restart app to apply.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App is up to date.')),
        );
      }
    }
    setState(() => _isCheckingUpdate = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: DripTheme.nebulaCyan,
            shadows: [
              Shadow(color: DripTheme.cosmicTeal, blurRadius: 15),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: DripTheme.cosmicTeal),
            title: const Text('Account Profile', style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.system_update, color: DripTheme.nebulaCyan),
            title: const Text('Check for App Updates', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Downloads Over-the-Air patches instantly',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: DripTheme.nebulaCyan),
                  )
                : const Icon(Icons.download, color: Colors.white54),
            onTap: _checkForOverTheAirUpdate,
          ),
          const ListTile(
            leading: Icon(Icons.restore, color: DripTheme.chrome),
            title: Text('Restore Purchases', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: DripTheme.chrome),
            title: Text('Privacy Policy', style: TextStyle(color: Colors.white)),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined, color: DripTheme.chrome),
            title: Text('Terms of Service', style: TextStyle(color: Colors.white)),
          ),
          if (widget.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: DripTheme.nebulaCyan),
              title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPortalScreen()),
                );
              },
            ),
        ],
      ),
    );
  }
}
