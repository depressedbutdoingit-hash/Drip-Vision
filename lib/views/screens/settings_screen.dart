import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../core/theme.dart';
import 'admin_portal.dart';
import 'god_mode/god_mode_screen.dart';
import '../../services/god_mode_service.dart';
import 'auth_screen.dart';
import '../widgets/model_picker_sheet.dart';
import '../../core/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const SettingsScreen({super.key, this.isAdmin = false});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
      final role = (doc.data()?['role'] ?? '').toString().trim().toLowerCase();
      if (mounted) setState(() => _isAdmin = role == 'admin' || role == 'owner');
    } catch (_) {}
  }

  Future<void> _checkForOverTheAirUpdate() async {
    setState(() => _isCheckingUpdate = true);
    try {
      final isUpdateAvailable =
          await _shorebirdCodePush.isNewPatchAvailableForDownload();
      if (isUpdateAvailable) {
        await _shorebirdCodePush.downloadUpdateIfAvailable();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update downloaded. Restart the app to apply.'),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App is up to date.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update check failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _isCheckingUpdate = false);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DripTheme.surfaceRaised,
        title: const Text('Sign out?', style: TextStyle(color: DripTheme.warmWhite)),
        content: const Text(
          'You will need to sign in again to use DripVision.',
          style: TextStyle(color: DripTheme.chrome),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: DripTheme.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SIGN OUT',
                style: TextStyle(color: Color(0xFFFF8A80))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _signingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? user?.uid ?? 'Director';

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Text('SETTINGS', style: DripTheme.brandMark),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ACCOUNT', style: DripTheme.technical),
                const SizedBox(height: 10),
                Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (_isAdmin) ...[
                  const SizedBox(height: 6),
                  const Text('ADMIN',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: DripTheme.cosmicTeal,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const Divider(color: DripTheme.hairline, height: 1),
          _tile(
            icon: Icons.system_update_outlined,
            title: 'Check for update',
            subtitle: 'Over-the-air patch via Shorebird',
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DripTheme.cosmicTeal,
                    ),
                  )
                : null,
            onTap: _isCheckingUpdate ? null : _checkForOverTheAirUpdate,
          ),
          _tile(
            icon: Icons.auto_awesome_outlined,
            title: 'AI Models',
            subtitle: 'Text · image · video · quality',
            onTap: () {
              final tier =
                  ref.read(userProfileProvider).value?.subscriptionTier;
              showModelPickerSheet(
                context,
                initial: ModelPickerTab.video,
                subscriptionTier: tier,
              );
            },
          ),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _tile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          if (_isAdmin) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('CONTROL ROOM', style: DripTheme.technical),
            ),
            _tile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin Dashboard',
              accent: DripTheme.nebulaCyan,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPortalScreen()),
              ),
            ),
            _tile(
              icon: Icons.security,
              title: 'God Mode',
              subtitle: 'System control · server-gated',
              accent: DripTheme.cosmicTeal,
              onTap: () async {
                final ok = await GodModeService.isAuthorizedAdmin();
                if (!context.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Access denied')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GodModeScreen()),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: DripTheme.hairline, height: 1),
          _tile(
            icon: _signingOut ? null : Icons.logout,
            title: 'Sign out',
            subtitle: 'Return to login',
            accent: const Color(0xFFFF8A80),
            trailing: _signingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF8A80),
                    ),
                  )
                : null,
            onTap: _signingOut ? null : _signOut,
          ),
        ],
      ),
    );
  }

  Widget _tile({
    IconData? icon,
    required String title,
    String? subtitle,
    Color? accent,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final color = accent ?? DripTheme.chrome;
    return ListTile(
      leading: icon == null
          ? const SizedBox(width: 24)
          : Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: accent ?? DripTheme.warmWhite,
          fontWeight: accent != null ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: DripTheme.muted, fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
