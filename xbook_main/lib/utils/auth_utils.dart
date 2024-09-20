import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthUtils {
  static Future<void> handleLogout(BuildContext context) async {
    final SupabaseService supabaseService = SupabaseService();

    try {
      await supabaseService.signOut();
      // Use Navigator.of(context).pushReplacementNamed only if the widget is still mounted
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Handle any errors that occur during sign out
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }
}
