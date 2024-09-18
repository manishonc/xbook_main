import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';
import '../services/supabase_service.dart';

class SecureWidget extends StatelessWidget {
  final Widget child;

  const SecureWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.data == true) {
          return child;
        } else {
          return const AuthScreen();
        }
      },
    );
  }

  Future<bool> _checkAuth() async {
    final session = await supabaseService.getSession();
    return session != null;
  }
}
