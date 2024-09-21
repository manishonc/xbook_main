class Subject {
  final String id;
  final DateTime createdAt;
  final String subjectName;
  final String emoji;

  Subject({
    required this.id,
    required this.createdAt,
    required this.subjectName,
    required this.emoji,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      subjectName: json['subject_name'] as String,
      emoji: json['emoji'] as String,
    );
  }
}
