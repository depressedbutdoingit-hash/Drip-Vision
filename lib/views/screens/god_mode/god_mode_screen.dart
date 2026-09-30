import 'package:cloud_firestore/cloud_firestore.dart';
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
        body: Center(child: CircularProgressIndicator(color: DripTheme.cosmicTeal)),
      );
    }
    if (!_allowed) {
      return Scaffold(
        backgroundColor: DripTheme.voidBlack,
        appBar: AppBar(title: const Text('DENIED')),
        body: const Center(
          child: Text(
            'You are not authorized to access God Mode.',
            style: TextStyle(color: DripTheme.muted),
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
            Text('DRIPVISION // GOD MODE',
                style: TextStyle(fontSize: 12, letterSpacing: 2)),
            Text('SYSTEM CONTROL',
                style: TextStyle(fontSize: 9, letterSpacing: 2, color: DripTheme.muted)),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: DripTheme.cosmicTeal,
          labelColor: DripTheme.cosmicTeal,
          unselectedLabelColor: DripTheme.muted,
          labelStyle: const TextStyle(fontSize: 10, letterSpacing: 1),
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
      builder: (context, snap) {
        final users = snap.data?.docs.length ?? 0;
        final admins = snap.data?.docs
                .where((d) => (d.data()['role'] ?? '') == 'admin')
                .length ??
            0;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('PLATFORM',
                style: TextStyle(fontSize: 10, letterSpacing: 2, color: DripTheme.muted)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'USERS', value: '$users')),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'ADMINS', value: '$admins')),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Revenue and API cost charts require server-side aggregation '
              '(Cloud Functions + RevenueCat webhooks). Structure is ready.',
              style: TextStyle(color: DripTheme.muted, height: 1.4, fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DripTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, letterSpacing: 2, color: DripTheme.muted)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w300, color: DripTheme.warmWhite)),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: GodModeService.usersStream(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: DripTheme.cosmicTeal));
        }
        final docs = snap.data!.docs;
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final role = (d['role'] ?? 'customer').toString();
            final email = (d['email'] ?? docs[i].id).toString();
            final tokens = d['tokenBalance'] ?? 0;
            return ListTile(
              title: Text(email, style: const TextStyle(fontSize: 13)),
              subtitle: Text('role: $role  ·  tokens: $tokens',
                  style: const TextStyle(fontSize: 11, color: DripTheme.muted)),
              trailing: role == 'admin'
                  ? const Icon(Icons.shield, color: DripTheme.cosmicTeal, size: 18)
                  : IconButton(
                      icon: const Icon(Icons.add, color: DripTheme.chrome),
                      tooltip: '+100 tokens',
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(docs[i].id)
                            .update({
                          'tokenBalance': FieldValue.increment(100),
                        });
                      },
                    ),
            );
          },
        );
      },
    );
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
                'AI usage log empty or rules not deployed yet.\n'
                'Write usage from Cloud Functions to collection ai_usage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DripTheme.muted, height: 1.4),
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No usage events yet', style: TextStyle(color: DripTheme.muted)),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            return ListTile(
              dense: true,
              title: Text('${d['type'] ?? 'event'} · ${d['tokens'] ?? 0} tok',
                  style: const TextStyle(fontSize: 12)),
              subtitle: Text('${d['uid'] ?? ''} · ${d['provider'] ?? ''}',
                  style: const TextStyle(fontSize: 10, color: DripTheme.muted)),
            );
          },
        );
      },
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab();

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
              subtitle: const Text('Remote flag in admin_config/app'),
              value: maintenance,
              activeColor: DripTheme.cosmicTeal,
              onChanged: (v) {
                FirebaseFirestore.instance
                    .collection('admin_config')
                    .doc('app')
                    .set({'maintenanceMode': v}, SetOptions(merge: true));
              },
            ),
            const SizedBox(height: 12),
            const Text('ANNOUNCEMENT',
                style: TextStyle(fontSize: 10, letterSpacing: 2, color: DripTheme.muted)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: announcement,
              maxLines: 3,
              style: const TextStyle(color: DripTheme.warmWhite),
              decoration: const InputDecoration(hintText: 'Shown in-app when set'),
              onFieldSubmitted: (v) {
                FirebaseFirestore.instance
                    .collection('admin_config')
                    .doc('app')
                    .set({'announcement': v}, SetOptions(merge: true));
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Deploy firestore.rules so only admin claim/role can write admin_config.',
              style: TextStyle(color: DripTheme.muted, fontSize: 12, height: 1.4),
            ),
          ],
        );
      },
    );
  }
}
