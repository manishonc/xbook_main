import 'package:flutter/material.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/home_screen.dart';
// import '../screens/study/study_screen.dart';
// import '../screens/tests/tests_screen.dart';

class BottomNavigation extends StatelessWidget {
  final String currentRoute;

  const BottomNavigation({Key? key, required this.currentRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home_outlined, 'label': 'Home', 'route': '/home'},
      {
        'icon': Icons.book_outlined,
        'label': 'Study',
        'route': '/study-materials'
      },
      {'icon': Icons.description_outlined, 'label': 'Tests', 'route': '/tests'},
      {'icon': Icons.person_outlined, 'label': 'Profile', 'route': '/profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final isActive = currentRoute == item['route'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isActive) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          _getPageForRoute(item['route'] as String),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              },
              child: Container(
                height: 56, // Adjust this value to increase/decrease tab height
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isActive ? Colors.indigo : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.indigo[800] : Colors.grey,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getPageForRoute(String route) {
    switch (route) {
      case '/home':
        return const HomeScreen();
      case '/study-materials':
        // return StudyScreen();
        return const Scaffold(body: Center(child: Text('Study Screen')));
      case '/tests':
        // return TestsScreen();
        return const Scaffold(body: Center(child: Text('Tests Screen')));
      case '/profile':
        return const ProfilePage();
      default:
        return const Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
