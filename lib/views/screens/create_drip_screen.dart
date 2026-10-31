import 'package:flutter/material.dart';
import 'generator_screen.dart';

class CreateDripScreen extends StatefulWidget {
  const CreateDripScreen({super.key});

  @override
  State<CreateDripScreen> createState() => _CreateDripScreenState();
}

class _CreateDripScreenState extends State<CreateDripScreen> {
  final _prompt = TextEditingController(text: 'Isabella in a luxury dress, rooftop at sunset, cinematic shot...');
  String _style = 'Cinema';
  String _res = '4K';
  String _dur = '15s';

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Your Drip', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF12161A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _prompt,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Describe the scene...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _chip('Cinema', _style, (v) => setState(() => _style = v), Icons.movie_outlined),
              const SizedBox(width: 8),
              _chip('4K', _res, (v) => setState(() => _res = v), Icons.hd_outlined),
              const SizedBox(width: 8),
              _chip('15s', _dur, (v) => setState(() => _dur = v), Icons.timer_outlined),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5C0),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GeneratorScreen())),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Generate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF12161A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5C0)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generating your scene...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      SizedBox(height: 2),
                      Text('This may take 30-60 seconds', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String current, ValueChanged<String> onTap, IconData icon) {
    final selected = current == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF00E5C0).withOpacity(0.15) : const Color(0xFF12161A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? const Color(0xFF00E5C0) : Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: selected ? const Color(0xFF00E5C0) : Colors.white54),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: selected ? const Color(0xFF00E5C0) : Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
