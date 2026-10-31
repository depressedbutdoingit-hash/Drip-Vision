import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class CreateDripScreen extends ConsumerStatefulWidget {
  const CreateDripScreen({super.key});

  @override
  ConsumerState<CreateDripScreen> createState() => _CreateDripScreenState();
}

class _CreateDripScreenState extends ConsumerState<CreateDripScreen> {
  final _prompt = TextEditingController(
    text: 'Isabella in a luxury dress, rooftop at sunset, cinematic shot',
  );
  String _style = 'Cinema';
  String _res = '4K';
  String _dur = '15s';
  bool _loading = false;
  String? _result;
  String? _image;
  String? _error;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final text = _prompt.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _image = null;
    });
    try {
      final openRouter = ref.read(openRouterProvider);
      final ai = ref.read(aiGenerationServiceProvider);
      final script = await openRouter.generateText(
        'Write a short cinematic scene description for: $text. Style: $_style. Duration: $_dur.',
      );
      final image = await ai.generateImage(
        prompt: '$text, $_style, professional cinematography, $_res',
        quality: 'standard',
      );
      setState(() {
        _result = script;
        _image = image;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.play_arrow),
              label: Text(_loading ? 'Generating...' : 'Generate', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (_image != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _image!.startsWith('http')
                  ? Image.network(_image!, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Image.asset(_image!, height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF12161A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_result!, style: const TextStyle(color: Colors.white, height: 1.4)),
            ),
          ],
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
