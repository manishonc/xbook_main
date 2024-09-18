import 'package:flutter/material.dart';

class QuickLinks extends StatelessWidget {
  const QuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final quickLinks = [
      {
        'name': 'Mock Tests',
        'icon': Icons.description_outlined,
        'route': "/mock-tests"
      },
      {
        'name': 'Exam Calendar',
        'icon': Icons.calendar_today_outlined,
        'route': "/exam-calendar"
      },
      {
        'name': 'Performance',
        'icon': Icons.trending_up_outlined,
        'route': "/performance"
      },
      {'name': 'My Profile', 'icon': Icons.person_outline, 'route': "/profile"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: quickLinks.map((link) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, link['route'] as String);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.indigo[50]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(link['icon'] as IconData,
                        size: 40, color: Colors.indigo),
                    const SizedBox(height: 8),
                    Text(
                      link['name'] as String,
                      style: TextStyle(fontSize: 14, color: Colors.indigo[800]),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
