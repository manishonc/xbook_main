class UserProfile {
  final String name;
  final String email;
  final String targetExam;
  final String examYear;
  final String preferredLanguage;
  final String optionalSubject;
  final int studyStreak;
  final int testsCompleted;
  final int bookmarkedResources;

  UserProfile({
    required this.name,
    required this.email,
    required this.targetExam,
    required this.examYear,
    required this.preferredLanguage,
    required this.optionalSubject,
    required this.studyStreak,
    required this.testsCompleted,
    required this.bookmarkedResources,
  });

  // Static data for now
  static UserProfile staticProfile() {
    return UserProfile(
      name: 'Aarav Patel',
      email: 'aarav.patel@example.com',
      targetExam: 'UPSC Civil Services',
      examYear: '2024',
      preferredLanguage: 'English',
      optionalSubject: 'Sociology',
      studyStreak: 15,
      testsCompleted: 42,
      bookmarkedResources: 78,
    );
  }
}
