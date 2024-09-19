import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import '../../widgets/subject_filter.dart'; // Add this import

class StudyMaterialScreen extends StatelessWidget {
  const StudyMaterialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.indigo),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Study Material',
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            const SubjectFilter(), // Remove padding and attach directly below AppBar
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Study Materials',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add your study material content here
                  // For example:
                  _buildStudyMaterialItem(
                    'UPSC Syllabus',
                    'Comprehensive syllabus for UPSC exam',
                    Icons.book,
                  ),
                  _buildStudyMaterialItem(
                    'Current Affairs',
                    'Latest updates and news for UPSC preparation',
                    Icons.newspaper,
                  ),
                  _buildStudyMaterialItem(
                    'Previous Year Questions',
                    'Practice with past UPSC exam questions',
                    Icons.history_edu,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterialItem(
      String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle tap on study material item
        },
      ),
    );
  }
}
