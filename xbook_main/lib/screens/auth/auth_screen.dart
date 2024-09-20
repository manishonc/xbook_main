import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final session = await SupabaseService().getSession();
    if (session != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await SupabaseService().signInAnonymously();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in anonymously: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to XBook',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signInAnonymously(context),
                child: const Text('Login as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
