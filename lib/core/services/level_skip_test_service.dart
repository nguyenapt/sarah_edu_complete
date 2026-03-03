import 'package:flutter/foundation.dart' show debugPrint;
import '../../models/placement_test_model.dart';
import '../../models/level_skip_test_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/level_progression_service.dart';

class LevelSkipTestService {
  final FirestoreService _firestoreService = FirestoreService();
  final LevelProgressionService _levelProgressionService = LevelProgressionService();

  /// Load questions cho level cụ thể từ Firestore collection levelSkipTests
  Future<List<PlacementTestQuestion>> loadLevelSkipTestQuestions(
    String targetLevel,
  ) async {
    try {
      // Thử load từ Firestore collection levelSkipTests
      final questions = await _firestoreService.loadLevelSkipTestQuestions(targetLevel);
      if (questions.isNotEmpty) {
        return questions;
      }
      
      // Nếu không có, throw exception
      throw Exception('No questions found for level $targetLevel');
    } catch (e) {
      throw Exception('Error loading level skip test questions: $e');
    }
  }

  /// Kiểm tra xem user đã test hôm nay chưa (1 lần/ngày)
  Future<bool> checkDailyLimit(String userId) async {
    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final attempt = await _firestoreService.getLevelSkipTestAttempt(userId, dateString);
      
      // Nếu đã có attempt hôm nay và count >= 1, return true (đã đạt limit)
      return attempt != null && attempt.count >= 1;
    } catch (e) {
      debugPrint('Error checking daily limit: $e');
      return false; // Nếu có lỗi, cho phép test (fail-safe)
    }
  }

  /// Ghi nhận lần test (tăng count trong ngày)
  Future<void> recordAttempt(String userId) async {
    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await _firestoreService.saveLevelSkipTestAttempt(userId, dateString);
    } catch (e) {
      debugPrint('Error recording attempt: $e');
      // Không throw để không ảnh hưởng đến flow chính
    }
  }

  /// Tính điểm từ questions và answers (≥80% = pass)
  LevelSkipTestResult calculateScore(
    List<PlacementTestQuestion> questions,
    List<PlacementTestAnswer> answers,
    String targetLevel,
    String? userId,
  ) {
    if (questions.isEmpty || answers.isEmpty) {
      return LevelSkipTestResult(
        userId: userId,
        targetLevel: targetLevel,
        totalQuestions: 0,
        correctAnswers: 0,
        scorePercentage: 0.0,
        passed: false,
        completedAt: DateTime.now(),
      );
    }

    final correctCount = answers.where((a) => a.isCorrect).length;
    final scorePercentage = (correctCount / answers.length) * 100.0;
    final passed = scorePercentage >= 80.0;

    return LevelSkipTestResult(
      userId: userId,
      targetLevel: targetLevel,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      scorePercentage: scorePercentage,
      passed: passed,
      completedAt: DateTime.now(),
    );
  }

  /// Unlock level bằng cách gọi LevelProgressionService.levelUp()
  Future<void> unlockLevel(String userId, String targetLevel) async {
    try {
      await _levelProgressionService.levelUp(userId, targetLevel);
    } catch (e) {
      throw Exception('Error unlocking level: $e');
    }
  }

  /// Lấy level tiếp theo dựa trên current level
  /// Ví dụ: A1 -> A2, A2 -> B1, B1 -> B2, B2 -> C1, C1 -> C2
  String? getNextLevel(String? currentLevel) {
    if (currentLevel == null) return null;
    
    const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levelOrder.indexOf(currentLevel.toUpperCase());
    
    if (currentIndex < 0 || currentIndex >= levelOrder.length - 1) {
      return null; // Không có level tiếp theo
    }
    
    return levelOrder[currentIndex + 1];
  }
}
