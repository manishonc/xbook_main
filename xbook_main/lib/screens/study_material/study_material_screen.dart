import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import 'widgets/subject_filter.dart';
import '../../models/subject.dart';
import '../../services/supabase_service.dart';

class StudyMaterialScreen extends StatefulWidget {
  const StudyMaterialScreen({Key? key}) : super(key: key);

  @override
  _StudyMaterialScreenState createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen> {
  late PageController _pageController;
  String _selectedSubject = ''; // Initialize with an empty string
  List<Subject> _subjects = [];
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await supabaseService.getSubjects();
      setState(() {
        _subjects = subjects;
        _selectedSubject = subjects.isNotEmpty ? subjects[0].subjectName : '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading subjects: $e');
      setState(() {
        _isLoading = false;
      });
      // Handle error (e.g., show a snackbar)
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSubjectSelected(String subject) {
    setState(() {
      _selectedSubject = subject;
      final index = _subjects.indexWhere((s) => s.subjectName == subject);
      if (index != -1) {
        _pageController.jumpToPage(index);
      }
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SubjectFilter(
                    selectedSubject: _selectedSubject,
                    onSubjectSelected: _onSubjectSelected,
                    subjects: _subjects,
                  ),
                  Expanded(
                    child: _subjects.isEmpty
                        ? Center(child: Text('No subjects available'))
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: _subjects.length,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedSubject = _subjects[index].subjectName;
                              });
                            },
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              return ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: 1,
                                itemBuilder: (context, materialIndex) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      subject.subjectName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
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
