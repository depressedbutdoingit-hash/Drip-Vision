import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../services/god_mode_service.dart';

/// DRIPVISION // GOD MODE — control room.
/// Access must pass [GodModeService.isAuthorizedAdmin] before this opens.
class GodModeScreen extends StatefulWidget {
  const GodModeScreen({super.key});

  @override
  State<GodModeScreen> createState() => _GodModeScreenState();
}

class _GodModeScreenState extends State<GodModeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _gate();
  }

  Future<void> _gate() async {
    final ok = await GodModeService.isAuthorizedAdmin();
    if (!mounted) return;
    setState(() {
      _allowed = ok;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: DripTheme.voidBlack,
        body: Center(
          child: CircularProgressIndicator(color: DripTheme.cosmicTeal, strokeWidth: 2),
        ),
      );
    }
    if (!_allowed) {
      return Scaffold(
        backgroundColor: DripTheme.voidBlack,
        appBar: AppBar(title: const Text('DENIED', style: DripTheme.brandMark)),
        body: const Center(
          child: Text(
            'You are not authorized to access God Mode.',
            style: DripTheme.body,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DripTheme.voidBlack,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DRIPVISION // GOD MODE', style: DripTheme.brandMark),
            Text('SYSTEM CONTROL', style: DripTheme.technical),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: DripTheme.cosmicTeal,
          labelColor: DripTheme.cosmicTeal,
          unselectedLabelColor: DripTheme.muted,
          labelStyle: const TextStyle(fontSize: 10, letterSpacing: 1.2),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'USERS'),
            Tab(text: 'USAGE'),
            Tab(text: 'CONFIG'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _OverviewTab(),
          _UsersTab(),
          _UsageTab(),
          _ConfigTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: GodModeService.usersStream(),
      builder: (context, usersSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: GodModeService.usageStream(),
          builder: (context, usageSnap) {
            final users = usersSnap.data?.docs.length ?? 0;
            final admins = usersSnap.data?.docs
                    .where((d) => (d.data()['role'] ?? '') == 'admin')
                    .length ??
                0;
            final usageDocs = usageSnap.data?.docs ?? [];
            var tokenSum = 0;
            var adminBypass = 0;
            for (final d in usageDocs) {
              tokenSum += (d.data()['tokens'] as num?)?.toInt() ?? 0;
              if (d.data()['adminBypass'] == true) adminBypass++;
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('PLATFORM', style: DripTheme.technical),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'USERS', value: '$users')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(label: 'ADMINS', value: '$admins')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'USAGE EVENTS',
                        value: '${usageDocs.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(label: 'TOKENS LOGGED', value: '$tokenSum'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _StatCard(
                  label: 'ADMIN BYPASS EVENTS',
                  value: '$adminBypass',
                  wide: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Revenue requires RevenueCat webhooks writing to Firestore. '
                  'Token totals above come from ai_usage (including your own admin use).',
                  style: DripTheme.meta,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool wide;
  const _StatCard({required this.label, required this.value, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DripTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DripTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DripTheme.technical),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w300,
              color: DripTheme.warmWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            style: const TextStyle(color: DripTheme.warmWhite, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Search email or user id',
              prefixIcon: Icon(Icons.search, size: 20, color: DripTheme.muted),
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: GodModeService.usersStream(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: DripTheme.cosmicTeal,
                    strokeWidth: 2,
                  ),
                );
              }
              var docs = snap.data!.docs;
              if (_query.isNotEmpty) {
                docs = docs.where((d) {
                  final email = (d.data()['email'] ?? '').toString().toLowerCase();
                  final role = (d.data()['role'] ?? '').toString().toLowerCase();
                  return email.contains(_query) ||
                      d.id.toLowerCase().contains(_query) ||
                      role.contains(_query);
                }).toList();
              }
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No users match', style: DripTheme.meta),
                );
              }
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: DripTheme.hairline),
                itemBuilder: (context, i) {
                  final d = docs[i].data();
                  final role = (d['role'] ?? 'customer').toString();
                  final email = (d['email'] ?? docs[i].id).toString();
                  final tokens = d['tokenBalance'] ?? 0;
                  final tier = (d['subscriptionTier'] ?? 'free').toString();
                  return ListTile(
                    title: Text(email, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      'role: $role  ·  $tier  ·  tokens: $tokens\n${docs[i].id}',
                      style: const TextStyle(fontSize: 10, color: DripTheme.muted, height: 1.35),
                    ),
                    isThreeLine: true,
                    trailing: role.toString().trim().toLowerCase() == 'admin' || role.toString().trim().toLowerCase() == 'owner'
                        ? const Icon(Icons.shield, color: DripTheme.cosmicTeal, size: 18)
                        : IconButton(
                            icon: const Icon(Icons.add, color: DripTheme.chrome, size: 20),
                            tooltip: '+100 tokens',
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(docs[i].id)
                                  .update({
                                'tokenBalance': FieldValue.increment(100),
                              });
                              await _audit('token_grant', docs[i].id, '+100');
                            },
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _audit(String action, String target, String detail) async {
    final admin = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('admin_audit').add({
      'action': action,
      'target': target,
      'detail': detail,
      'adminUid': admin?.uid,
      'adminEmail': admin?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class _UsageTab extends StatelessWidget {
  const _UsageTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: GodModeService.usageStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Usage log empty or rules not deployed.\n'
                'Writes go to collection ai_usage from TokenService.',
                textAlign: TextAlign.center,
                style: DripTheme.meta,
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No usage events yet', style: DripTheme.meta),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final bypass = d['adminBypass'] == true;
            return ListTile(
              dense: true,
              title: Text(
                '${d['type'] ?? 'event'}  ·  ${d['tokens'] ?? 0} tok'
                '${bypass ? '  ·  ADMIN' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                '${d['uid'] ?? ''}',
                style: const TextStyle(fontSize: 10, color: DripTheme.muted),
              ),
            );
          },
        );
      },
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab();

  Future<void> _audit(String action, String detail) async {
    final admin = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('admin_audit').add({
      'action': action,
      'target': 'admin_config/app',
      'detail': detail,
      'adminUid': admin?.uid,
      'adminEmail': admin?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: GodModeService.configStream(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? {};
        final maintenance = data['maintenanceMode'] == true;
        final announcement = (data['announcement'] ?? '').toString();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              title: const Text('Maintenance mode'),
              subtitle: const Text('Remote flag · admin_config/app', style: DripTheme.meta),
              value: maintenance,
              activeColor: DripTheme.cosmicTeal,
              onChanged: (v) async {
                await FirebaseFirestore.instance
                    .collection('admin_config')
                    .doc('app')
                    .set({'maintenanceMode': v}, SetOptions(merge: true));
                await _audit('maintenance_mode', 'value=$v');
              },
            ),
            const SizedBox(height: 16),
            const Text('ANNOUNCEMENT', style: DripTheme.technical),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: announcement,
              maxLines: 3,
              style: const TextStyle(color: DripTheme.warmWhite),
              decoration: const InputDecoration(hintText: 'Shown in-app when set'),
              onFieldSubmitted: (v) async {
                await FirebaseFirestore.instance
                    .collection('admin_config')
                    .doc('app')
                    .set({'announcement': v}, SetOptions(merge: true));
                await _audit('announcement', v);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Deploy firestore.rules so only admins can write admin_config and read ai_usage.',
              style: DripTheme.meta,
            ),
          ],
        );
      },
    );
  }
}
