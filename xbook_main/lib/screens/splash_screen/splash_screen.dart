import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'abstract_background_painter.dart';
import 'loading_dots.dart';
import '../../utils/constants.dart';
import 'dart:convert';

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
      await _updateSessionClaimAndNavigate();
    } else {
      await _signInAnonymously();
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await SupabaseService().signInAnonymously();
      await _updateSessionClaimAndNavigate();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in anonymously: $error')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _updateSessionClaimAndNavigate() async {
    try {
      final response =
          await SupabaseService().updateSessionCustomClaim(AppDomain);

      if (response['data'] != null && response['data']['status'] == 'error') {
        if (mounted) {
          _showErrorDialog(response['data']['message'] ?? 'An error occurred');
        }
      } else {
        _navigateToHome();
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog('Failed to update session claim: $error');
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateSessionClaimAndNavigate();
              },
            ),
          ],
        );
      },
    );
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
