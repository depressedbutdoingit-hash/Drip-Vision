import 'package:flutter/material.dart';
import 'plan_screen.dart';

class ProfilePremiumScreen extends StatelessWidget {
  const ProfilePremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gigi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Studio Owner', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5C0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('God Mode', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('247', 'Total Drips'),
              _stat('12', 'Characters'),
              _stat('98%', 'Continuity'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF12161A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5C0).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.diamond_outlined, color: Color(0xFF00E5C0)),
                    SizedBox(width: 8),
                    Text('Pro Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    Spacer(),
                    Text('\$19.99 / month', style: TextStyle(color: Color(0xFF00E5C0), fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                _plan('30 clips per month'),
                _plan('15 sec per clip'),
                _plan('Priority generation'),
                _plan('Advanced features'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E5C0)),
                      foregroundColor: const Color(0xFF00E5C0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlansScreen()),
                    ),
                    child: const Text('Manage Plan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _plan(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF00E5C0), size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
