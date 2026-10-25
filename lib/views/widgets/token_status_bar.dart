import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';

class TokenStatusBar extends StatelessWidget {
  const TokenStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 28,
            child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final tokens = data['tokenBalance'] ?? 0;
        final tier = (data['subscriptionTier'] ?? 'free').toString();

        String tierLabel;
        Color tierColor;
        switch (tier.toLowerCase()) {
          case 'director':
          case 'pro':
            tierLabel = 'Director';
            tierColor = DripTheme.teal;
            break;
          case 'studio':
          case 'unlimited':
          case 'full production':
            tierLabel = 'Full Production';
            tierColor = const Color(0xFFFFD700);
            break;
          case 'starter':
          case 'first take':
          case 'scene':
            tierLabel = 'First Take';
            tierColor = DripTheme.silver;
            break;
          default:
            tierLabel = 'Free';
            tierColor = DripTheme.silver;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DripTheme.gunmetal,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tierColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.token, size: 16, color: tierColor),
              const SizedBox(width: 6),
              Text(
                '$tokens',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 14,
                color: Colors.white24,
              ),
              const SizedBox(width: 10),
              Text(
                tierLabel,
                style: TextStyle(color: tierColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}