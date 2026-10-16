import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/dripvision_splash.mp4')
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _controller.play();
          _controller.setLooping(false);
        });
      })
      ..addListener(() {
        if (_controller.value.isInitialized && _controller.value.isPlaying) {
          setState(() {});
        }
        if (_controller.value.isInitialized &&
            _controller.value.position.inSeconds >= 6) {
          setState(() => _showContinueButton = true);
        }
      });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
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
          // Video background
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Color(0xFF00FFAA))),

          // Logo + droplet animation overlay
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'DripVision',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FFAA),
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Color(0xFF00FFAA),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00FFAA), width: 3),
                  ),
                  child: const Center(
                    child: Text('D', style: TextStyle(color: Colors.white, fontSize: 40)),
                  ),
                ),
              ],
            ),
          ),

          // Loading bar
          Positioned(
            bottom: 120,
            left: 40,
            right: 40,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: _controller.value.isInitialized
                        ? (_controller.value.position.inSeconds / 33 * 100).clamp(0, 100)
                        : 0,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FFAA),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ),

          // Tap to continue
          if (_showContinueButton)
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
                      color: const Color(0xFF00FFAA),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00FFAA).withOpacity(0.4), blurRadius: 20),
                      ],
                    ),
                    child: const Text(
                      'Tap to continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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