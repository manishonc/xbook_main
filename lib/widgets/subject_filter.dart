import 'package:flutter/material.dart';

class SubjectFilter extends StatefulWidget {
  const SubjectFilter({Key? key}) : super(key: key);

  @override
  _SubjectFilterState createState() => _SubjectFilterState();
}

class _SubjectFilterState extends State<SubjectFilter> {
  final List<Map<String, String>> _subjects = [
    {'name': 'Math', 'emoji': '🔢'},
    {'name': 'Science', 'emoji': '🔬'},
    {'name': 'History', 'emoji': '📜'},
    {'name': 'Geography', 'emoji': '🌍'},
    {'name': 'English', 'emoji': '📚'},
    {'name': 'Physics', 'emoji': '⚛️'},
    {'name': 'Chemistry', 'emoji': '🧪'},
    {'name': 'Biology', 'emoji': '🧬'},
    {'name': 'Economics', 'emoji': '💹'},
    {'name': 'Political Science', 'emoji': '🏛️'},
    // Add more subjects as needed
  ];

  String _selectedSubject = 'Math';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set background color to white
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 8.0), // Add padding here
        child: Row(
          children: _subjects.map((subject) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text('${subject['emoji']} ${subject['name']}'),
                selected: _selectedSubject == subject['name'],
                onSelected: (bool selected) {
                  setState(() {
                    _selectedSubject =
                        selected ? subject['name']! : _selectedSubject;
                  });
                },
                selectedColor: Colors.indigo,
                backgroundColor: Colors.white, // Set background color to white
                showCheckmark: false, // Remove the check icon
                labelStyle: TextStyle(
                  color: _selectedSubject == subject['name']
                      ? Colors.white
                      : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Fully rounded
                ),
                elevation: 2, // Minimal elevation
                shadowColor:
                    Colors.indigo.withOpacity(0.1), // Less solid shadow
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
