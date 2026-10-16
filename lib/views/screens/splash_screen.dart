import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/dripvision_splash.mp4')
      ..initialize().then((_) {
        setState(() => _controller.play());
        _controller.setLooping(false);
      })
      ..addListener(() {
        if (_controller.value.isInitialized && _controller.value.position.inSeconds >= 6) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121416),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: VideoPlayer(_controller)))
              : const Center(child: CircularProgressIndicator(color: Color(0xFF00FFAA))),

          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('DRIPVISION', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF00FFAA))),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00FFAA), width: 3)),
                  child: const Center(child: Text('D', style: TextStyle(color: Colors.white, fontSize: 40))),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 120,
            left: 40,
            right: 40,
            child: Container(
              height: 6,
              color: Colors.white.withOpacity(0.3),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Container(
                  width: _controller.value.isInitialized ? (_controller.value.position.inSeconds / 33 * 100).clamp(0, 100) : 0,
                  height: 6,
                  color: const Color(0xFF00FFAA),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}