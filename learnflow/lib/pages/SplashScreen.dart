// lib/pages/SplashScreen.dart  [FIXED — ใช้ authStateChanges แทน currentUser]

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
    _decideNavigation();
  }

  // FIX: ใช้ authStateChanges stream เพื่อรอให้ Firebase restore session จริงๆ
  // currentUser อาจยัง null อยู่แม้มี session ถ้าตรวจเร็วเกินไปหลัง cold start
  Future<void> _decideNavigation() async {
    // รอ animation + Firebase init อย่างน้อย 2 วินาที
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // ใช้ firstWhere บน authStateChanges เพื่อรอ Firebase emit state จริง
    // timeout 3 วินาที ถ้า Firebase ช้ากว่านั้น ถือว่า logged out
    User? user;
    try {
      user = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      user = null;
    }

    if (!mounted) return;

    if (user != null) {
      // มี session อยู่ → ข้ามหน้า login ไปที่ home เลย
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // ไม่มี session → ไป onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D9E60),
              Color(0xFF1DBA78),
              Color(0xFF25D48A),
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScale,
            child: FadeTransition(
              opacity: _logoFade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/LeranFlow_logo.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 52,
                    height: 52,
                    child: _GradientSpinner(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Spinner ──────────────────────────────────────────────────────────────────

class _GradientSpinner extends StatefulWidget {
  const _GradientSpinner();

  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.rotate(
        angle: _controller.value * 2 * pi,
        child: CustomPaint(
          painter: _GradientSpinnerPainter(),
          size: const Size(52, 52),
        ),
      ),
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      colors: const [
        Colors.white,
        Color(0xFFDDDDDD),
        Color(0xFFAAAAAA),
        Color(0xFF777777),
        Color(0xFF444444),
        Color(0xFF111111),
        Colors.transparent,
        Colors.white,
      ],
      stops: const [0.0, 0.12, 0.30, 0.50, 0.68, 0.82, 0.92, 1.0],
    );

    final paint = Paint()
      ..shader    = gradient.createShader(rect)
      ..style     = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
