import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../core/theme.dart';
import 'admin_portal.dart';

class SettingsScreen extends StatefulWidget {
  final bool isAdmin;
  const SettingsScreen({super.key, this.isAdmin = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shorebirdCodePush = ShorebirdCodePush();
  bool _isCheckingUpdate = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.isAdmin;
    _loadAdminFlag();
  }

  Future<void> _loadAdminFlag() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = doc.data()?['role'] as String?;
      if (mounted) {
        setState(() => _isAdmin = role == 'admin');
      }
    } catch (_) {
      // Offline / rules — keep existing flag
    }
  }

  Future<void> _checkForOverTheAirUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final isUpdateAvailable =
        await _shorebirdCodePush.isNewPatchAvailableForDownload();

    if (isUpdateAvailable) {
      await _shorebirdCodePush.downloadUpdateIfAvailable();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New update downloaded! Restart app to apply.'),
          ),
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
            subtitle: Text(
              FirebaseAuth.instance.currentUser?.email ?? 'Not signed in',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DripTheme.nebulaCyan,
                    ),
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
          if (_isAdmin)
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
