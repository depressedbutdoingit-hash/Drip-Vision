import 'package:flutter/material.dart';
import 'studio_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const StudioHomeScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900&q=80',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
          // Glowing drips
          Positioned(top: -30, left: 50, child: _drip(36, 0.4)),
          Positioned(top: -16, right: 70, child: _drip(22, 0.28)),
          Positioned(top: 100, right: 10, child: _drip(16, 0.22)),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  _logo(),
                  const SizedBox(height: 10),
                  const Text(
                    'DripVision',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Where AI remembers the story',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5C0),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            onPressed: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const StudioHomeScreen()),
                            ),
                            child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            ),
                            onPressed: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const StudioHomeScreen()),
                            ),
                            child: const Text('Sign In'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00E5C0), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5C0).withOpacity(0.45), blurRadius: 16),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.water_drop, color: Color(0xFF00E5C0), size: 28),
    );
  }

  Widget _drip(double size, double opacity) {
    return Container(
      width: size,
      height: size * 1.5,
      decoration: BoxDecoration(
        color: const Color(0xFF00E5C0).withOpacity(opacity),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          topRight: Radius.circular(size),
          bottomLeft: Radius.circular(size * 0.4),
          bottomRight: Radius.circular(size * 0.4),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5C0).withOpacity(opacity), blurRadius: 20, spreadRadius: 2),
        ],
      ),
    );
  }
}
