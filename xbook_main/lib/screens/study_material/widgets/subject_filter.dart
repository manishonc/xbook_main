import 'package:flutter/material.dart';
import '../../../models/subject.dart';

class SubjectFilter extends StatefulWidget {
  final String selectedSubject;
  final Function(String) onSubjectSelected;
  final List<Subject> subjects;

  const SubjectFilter({
    Key? key,
    required this.selectedSubject,
    required this.onSubjectSelected,
    required this.subjects,
  }) : super(key: key);

  @override
  _SubjectFilterState createState() => _SubjectFilterState();
}

class _SubjectFilterState extends State<SubjectFilter> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelectedSubject());
  }

  @override
  void didUpdateWidget(SubjectFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubject != widget.selectedSubject) {
      _scrollToSelectedSubject();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedSubject() {
    final index = widget.subjects
        .indexWhere((s) => s.subjectName == widget.selectedSubject);
    if (index != -1) {
      final itemPosition = index * 100.0; // Approximate width of each item
      _scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 50, // Fixed height for the filter
      child: widget.subjects.isEmpty
          ? Center(child: Text('Loading subjects...'))
          : ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.subjects.length,
              itemBuilder: (context, index) {
                final subject = widget.subjects[index];
                final isSelected =
                    widget.selectedSubject == subject.subjectName;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(
                      '${subject.emoji} ${subject.subjectName}',
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        widget.onSubjectSelected(subject.subjectName);
                      }
                    },
                    selectedColor: Colors.indigo,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    shadowColor: Colors.indigo.withOpacity(0.1),
                    showCheckmark: false,
                  ),
                );
              },
            ),
    );
  }
}
