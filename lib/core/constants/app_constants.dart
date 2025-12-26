class AppConstants {
  // Levels
  static const List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  
  // Level Colors
  static const Map<String, int> levelColors = {
    'A1': 0xFF4CAF50, // Green
    'A2': 0xFF8BC34A, // Light Green
    'B1': 0xFF2196F3, // Blue
    'B2': 0xFF03A9F4, // Light Blue
    'C1': 0xFFFF9800, // Orange
    'C2': 0xFFF44336, // Red
  };

  // XP per exercise
  static const int xpPerExercise = 10;
  static const int xpPerUnit = 100;
  static const int xpPerLevel = 1000;

  // Streak
  static const int maxStreakDays = 365;

  // Exercise types
  static const List<String> exerciseTypes = [
    'single_choice',
    'multiple_choice',
    'fill_blank',
    'matching',
    'listening',
    'speaking',
  ];

  // Lesson types
  static const List<String> lessonTypes = [
    'grammar',
    'vocabulary',
    'listening',
    'speaking',
    'reading',
    'writing',
  ];

  // Difficulty levels
  static const List<String> difficulties = ['easy', 'medium', 'hard'];

  // Weak point threshold (accuracy < 70% is considered weak)
  static const double weakPointThreshold = 0.7;

  // Cache duration (in hours)
  static const int cacheDurationHours = 24;
}


