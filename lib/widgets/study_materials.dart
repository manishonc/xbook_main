import 'package:flutter/material.dart';

class StudyMaterials extends StatelessWidget {
  const StudyMaterials({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studyMaterials = [
      {'name': 'General Studies', 'icon': Icons.book_outlined},
      {'name': 'Current Affairs', 'icon': Icons.trending_up_outlined},
      {'name': 'Previous Year Papers', 'icon': Icons.description_outlined},
      {'name': 'Optional Subjects', 'icon': Icons.school_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Materials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[800],
          ),
        ),
        const SizedBox(height: 12),
        ...studyMaterials.map((material) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: ListTile(
              leading: Icon(material['icon'] as IconData, color: Colors.indigo),
              title: Text(
                material['name'] as String,
                style: const TextStyle(color: Colors.indigo),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.indigo),
            ),
          );
        }).toList(),
      ],
    );
  }
}
