import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class AdminPortalScreen extends StatelessWidget {
  const AdminPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'DRIPVISION ADMIN',
            style: TextStyle(
              color: DripTheme.nebulaCyan,
              shadows: [
                Shadow(color: DripTheme.cosmicTeal, blurRadius: 15),
              ],
            ),
          ),
          bottom: const TabBar(
            indicatorColor: DripTheme.cosmicTeal,
            labelColor: DripTheme.cosmicTeal,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.movie_filter), text: "Generations"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UsersTab(),
            _GenerationsTab(),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
          );
        }
        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i].data() as Map<String, dynamic>;
            final isAdmin = u['role'] == 'admin';
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin
                    ? DripTheme.nebulaCyan
                    : DripTheme.cosmicTeal.withOpacity(0.3),
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? DripTheme.voidBlack : Colors.white,
                  size: 18,
                ),
              ),
              title: Text(
                u['email'] ?? 'Anonymous',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Role: ${u['role']} | Tokens: ${u['tokenBalance']}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: DripTheme.nebulaCyan),
                onPressed: () {
                  FirebaseFirestore.instance.collection('users').doc(users[i].id).update({
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

class _GenerationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('generations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: DripTheme.cosmicTeal),
          );
        }
        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Container(
              decoration: BoxDecoration(
                color: DripTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        data['thumbnailUrl'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: DripTheme.surfaceLight),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['prompt'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
