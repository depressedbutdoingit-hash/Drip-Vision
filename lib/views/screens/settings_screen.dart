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
  bool _signingOut = false;

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

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surface,
        title: const Text('Sign out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You will need to sign in again to use your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _signingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      // Pop settings; root listens to auth and shows AuthScreen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
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
              email ?? 'Not signed in',
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
          const Divider(color: Colors.white12, height: 32),
          ListTile(
            leading: _signingOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Sign out',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Return to the login screen',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            onTap: _signingOut ? null : _signOut,
          ),
        ],
      ),
    );
  }
}
