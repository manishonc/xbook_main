import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating loading time
    final session = await SupabaseService().getSession();
    if (session != null) {
      _navigateToHome();
    } else {
      await _signInAnonymously();
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await SupabaseService().signInAnonymously();
      _navigateToHome();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in anonymously: $error')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Abstract background
          CustomPaint(
            painter: AbstractBackgroundPainter(),
            child: Container(),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'UPSC Prep Po',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Gateway to UPSC Success',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 20),
                const LoadingDots(),
              ],
            ),
          ),
          // Version number
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              'Version 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AbstractBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background
    paint.color = const Color(0xFFEEF2FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Grid
    paint.color = const Color(0xFFE0E7FF);
    paint.strokeWidth = 0.5;
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }

    // Circles
    paint.color = const Color(0x33818CF8);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 50, paint);
    paint.color = const Color(0x1A4F46E5);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 100, paint);

    // Curves
    paint.color = const Color(0xFF6366F1);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.25,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.75, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);

    paint.color = const Color(0xFFA5B4FC);
    paint.strokeWidth = 3;
    path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({Key? key}) : super(key: key);

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 6).animate(controller);
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              transform:
                  Matrix4.translationValues(0, -_animations[index].value, 0),
            );
          },
        );
      }),
    );
  }
}
