import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import 'widgets/subject_filter.dart';
import '../../data/dummy_data.dart';
import 'package:flutter/services.dart';

class StudyMaterialScreen extends StatefulWidget {
  const StudyMaterialScreen({Key? key}) : super(key: key);

  @override
  _StudyMaterialScreenState createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen> {
  late PageController _pageController;
  late String _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = DummyData.subjects[0]['name'];
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSubjectSelected(String subject) {
    setState(() {
      _selectedSubject = subject;
      final index = DummyData.subjects.indexWhere((s) => s['name'] == subject);
      _pageController.jumpToPage(index);
    });
  }

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
            SubjectFilter(
              selectedSubject: _selectedSubject,
              onSubjectSelected: _onSubjectSelected,
              subjects:
                  DummyData.subjects.map((s) => s['name'] as String).toList(),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: DummyData.subjects.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedSubject = DummyData.subjects[index]['name'];
                  });
                },
                itemBuilder: (context, index) {
                  final subject = DummyData.subjects[index]['name'];
                  final materials = DummyData.studyMaterials[subject] ?? [];
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: materials.length + 1,
                    itemBuilder: (context, materialIndex) {
                      if (materialIndex == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            subject,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        );
                      }
                      final material = materials[materialIndex - 1];
                      return _buildStudyMaterialItem(
                        material['title']!,
                        material['description']!,
                        Icons.book,
                      );
                    },
                  );
                },
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
