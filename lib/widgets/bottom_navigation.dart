import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home_outlined, 'label': 'Home', 'route': '/'},
      {
        'icon': Icons.book_outlined,
        'label': 'Study',
        'route': '/study-materials'
      },
      {'icon': Icons.description_outlined, 'label': 'Tests', 'route': '/tests'},
      {
        'icon': Icons.settings_outlined,
        'label': 'Settings',
        'route': '/settings'
      },
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
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, item['route'] as String);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, color: Colors.indigo),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.indigo[800]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
