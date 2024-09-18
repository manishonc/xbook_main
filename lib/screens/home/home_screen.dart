import 'package:flutter/material.dart';
import '../../utils/auth_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthUtils.handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to XBook!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement book browsing functionality
              },
              child: const Text('Browse Books'),
            ),
          ],
        ),
      ),
    );
  }
}
