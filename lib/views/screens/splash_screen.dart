import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'auth_gate.dart';

const _teal = Color(0xFF00FFAA);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  Timer? _timer;
  bool _videoReady = false;
  bool _showContinue = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Button appears after 6s even if the video is missing or fails.
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _showContinue = true);
    });
    _initVideo();
  }

  Future<void> _initVideo() async {
    final c = VideoPlayerController.asset('assets/videos/dripvision_splash.mp4');
    _controller = c;
    try {
      await c.initialize();
      if (!mounted) return;
      await c.setLooping(false);
      await c.play();
      setState(() => _videoReady = true);
    } catch (_) {
      // Video asset missing or broken: splash still works without it.
    }
  }

  void _continue() {
    if (_navigated) return; // prevents double navigation
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Widget _progressBar() {
    final c = _controller;
    if (c == null || !_videoReady) {
      return const LinearProgressIndicator(color: _teal, backgroundColor: Colors.white24);
    }
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: c,
      builder: (context, v, _) {
        final total = v.duration.inMilliseconds;
        final fraction = total == 0
            ? 0.0
            : (v.position.inMilliseconds / total).clamp(0.0, 1.0).toDouble();
        return LinearProgressIndicator(
          value: fraction,
          minHeight: 6,
          color: _teal,
          backgroundColor: Colors.white24,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFF121416),
      body: Stack(
        children: [
          if (c != null && _videoReady)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              ),
            ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'DRIPVISION',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: _teal,
                    shadows: [Shadow(blurRadius: 20, color: _teal)],
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.water_drop, size: 72, color: _teal),
              ],
            ),
          ),
          Positioned(
            bottom: 140,
            left: 40,
            right: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: _progressBar(),
            ),
          ),
          if (_showContinue)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _continue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Color(0x6600FFAA), blurRadius: 20),
                      ],
                    ),
                    child: const Text(
                      'Tap to continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}