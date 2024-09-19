import 'package:flutter/material.dart';

class QuickAccess extends StatelessWidget {
  final Function(String) onItemTap;
  const QuickAccess({Key? key, required this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quickAccessMenu = [
      {'name': 'Daily Quiz', 'icon': Icons.help_outline},
      {'name': 'Syllabus', 'icon': Icons.description_outlined},
      {'name': 'Strategy', 'icon': Icons.track_changes_outlined},
      {'name': 'Notes', 'icon': Icons.edit_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: quickAccessMenu.map((item) {
              return GestureDetector(
                onTap: () => onItemTap(item['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.indigo[50]!, Colors.indigo[100]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData,
                          color: Colors.indigo[600], size: 20),
                      const SizedBox(height: 4),
                      Text(
                        item['name'] as String,
                        style:
                            TextStyle(fontSize: 12, color: Colors.indigo[800]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
