class DummyData {
  static final List<Map<String, dynamic>> subjects = [
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
  ];

  static final Map<String, List<Map<String, String>>> studyMaterials = {
    'Math': [
      {
        'title': 'Algebra Basics',
        'description': 'Introduction to algebraic concepts'
      },
      {
        'title': 'Geometry Fundamentals',
        'description': 'Essential geometric principles'
      },
    ],
    'Science': [
      {
        'title': 'Scientific Method',
        'description': 'Understanding the scientific process'
      },
      {
        'title': 'Basic Elements',
        'description': 'Introduction to the periodic table'
      },
    ],
    // Add more subjects and their study materials here
  };
}
