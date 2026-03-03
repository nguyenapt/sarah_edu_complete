import 'placement_test_model.dart';

/// Model cho kết quả level skip test
class LevelSkipTestResult {
  final String? userId; // null nếu là guest
  final String targetLevel; // Level mà user muốn unlock (A2, B1, B2, C1, C2)
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final bool passed; // ≥80% = true
  final DateTime completedAt;

  LevelSkipTestResult({
    this.userId,
    required this.targetLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.passed,
    required this.completedAt,
  });

  factory LevelSkipTestResult.fromMap(Map<String, dynamic> map) {
    return LevelSkipTestResult(
      userId: map['userId'],
      targetLevel: map['targetLevel'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      scorePercentage: (map['scorePercentage'] ?? 0.0).toDouble(),
      passed: map['passed'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetLevel': targetLevel,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'scorePercentage': scorePercentage,
      'passed': passed,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

/// Model để track số lần test trong ngày
class LevelSkipTestAttempt {
  final String userId;
  final String date; // Format: YYYY-MM-DD
  final int count; // Số lần test trong ngày
  final DateTime lastAttemptAt;

  LevelSkipTestAttempt({
    required this.userId,
    required this.date,
    required this.count,
    required this.lastAttemptAt,
  });

  factory LevelSkipTestAttempt.fromMap(Map<String, dynamic> map) {
    return LevelSkipTestAttempt(
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      count: map['count'] ?? 0,
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'count': count,
      'lastAttemptAt': lastAttemptAt.toIso8601String(),
    };
  }
}
