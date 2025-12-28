import 'dart:convert';
import 'dart:math';
import '../../models/placement_test_model.dart';
import '../../core/services/firestore_service.dart';
import 'package:flutter/services.dart' show rootBundle;

class PlacementTestService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Load questions từ Firestore hoặc local JSON file
  Future<List<PlacementTestQuestion>> loadQuestions() async {
    try {
      // Thử load từ Firestore trước
      final questions = await _firestoreService.loadPlacementTestQuestions();
      if (questions.isNotEmpty) {
        return questions;
      }
    } catch (e) {
      // Nếu Firestore fail, load từ local JSON
      print('Failed to load from Firestore, loading from local JSON: $e');
    }

    // Load từ local JSON file
    return await _loadQuestionsFromLocal();
  }

  /// Load questions từ local JSON file
  Future<List<PlacementTestQuestion>> _loadQuestionsFromLocal() async {
    try {
      final String jsonString =
          await rootBundle.loadString('placement_test_questions.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final Map<String, dynamic> placementTestData =
          jsonData['placementTest'] as Map<String, dynamic>;

      return placementTestData.entries.map((entry) {
        return PlacementTestQuestion.fromMap(
          entry.value as Map<String, dynamic>,
          entry.key,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error loading questions from local JSON: $e');
    }
  }

  /// Tạo adaptive test sequence (30 câu: 20 câu xác định level + 10 câu tinh chỉnh)
  List<PlacementTestQuestion> createAdaptiveTestSequence(
    List<PlacementTestQuestion> allQuestions,
    List<PlacementTestAnswer> previousAnswers,
  ) {
    List<PlacementTestQuestion> selectedQuestions = [];
    List<PlacementTestQuestion> availableQuestions = List.from(allQuestions);

    // Phase 1: 10 câu đầu - A1-A2 (xác định cơ bản)
    final phase1Questions = availableQuestions
        .where((q) =>
            q.level == PlacementTestLevel.a1 || q.level == PlacementTestLevel.a2)
        .toList();
    phase1Questions.shuffle();
    selectedQuestions.addAll(phase1Questions.take(10));
    availableQuestions.removeWhere((q) => selectedQuestions.contains(q));

    // Phase 2: 10 câu tiếp - Adaptive dựa trên kết quả phase 1
    if (previousAnswers.length >= 10) {
      final phase1Correct = previousAnswers
          .take(10)
          .where((a) => a.isCorrect)
          .length;
      final phase1Score = phase1Correct / 10.0;

      List<PlacementTestQuestion> phase2Questions;
      if (phase1Score >= 0.8) {
        // >80% đúng → tăng lên B1-B2
        phase2Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.b1 ||
                q.level == PlacementTestLevel.b2)
            .toList();
      } else if (phase1Score >= 0.5) {
        // 50-80% đúng → giữ A2-B1
        phase2Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.a2 ||
                q.level == PlacementTestLevel.b1)
            .toList();
      } else {
        // <50% đúng → giữ A1-A2
        phase2Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.a1 ||
                q.level == PlacementTestLevel.a2)
            .toList();
      }

      phase2Questions.shuffle();
      selectedQuestions.addAll(phase2Questions.take(10));
      availableQuestions.removeWhere((q) => selectedQuestions.contains(q));
    } else {
      // Nếu chưa có đủ 10 câu trả lời, chọn ngẫu nhiên A2-B1
      final phase2Questions = availableQuestions
          .where((q) =>
              q.level == PlacementTestLevel.a2 ||
              q.level == PlacementTestLevel.b1)
          .toList();
      phase2Questions.shuffle();
      selectedQuestions.addAll(phase2Questions.take(10));
      availableQuestions.removeWhere((q) => selectedQuestions.contains(q));
    }

    // Phase 3: 10 câu cuối - Tinh chỉnh dựa trên performance tổng thể
    if (previousAnswers.length >= 20) {
      final overallScore = previousAnswers
          .where((a) => a.isCorrect)
          .length /
          previousAnswers.length;

      // Tính trung bình level của câu đúng
      double avgCorrectLevel = 0;
      int correctCount = 0;
      for (int i = 0; i < previousAnswers.length; i++) {
        if (previousAnswers[i].isCorrect && i < selectedQuestions.length) {
          avgCorrectLevel +=
              selectedQuestions[i].level.numericValue.toDouble();
          correctCount++;
        }
      }
      if (correctCount > 0) {
        avgCorrectLevel /= correctCount;
      }

      // Chọn câu hỏi dựa trên performance
      List<PlacementTestQuestion> phase3Questions;
      if (overallScore >= 0.7 && avgCorrectLevel >= 3.0) {
        // Performance tốt → B2-C1
        phase3Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.b2 ||
                q.level == PlacementTestLevel.c1)
            .toList();
      } else if (overallScore >= 0.5) {
        // Performance trung bình → B1-B2
        phase3Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.b1 ||
                q.level == PlacementTestLevel.b2)
            .toList();
      } else {
        // Performance thấp → A2-B1
        phase3Questions = availableQuestions
            .where((q) =>
                q.level == PlacementTestLevel.a2 ||
                q.level == PlacementTestLevel.b1)
            .toList();
      }

      phase3Questions.shuffle();
      selectedQuestions.addAll(phase3Questions.take(10));
    } else {
      // Nếu chưa có đủ 20 câu trả lời, chọn ngẫu nhiên từ các level
      availableQuestions.shuffle();
      selectedQuestions.addAll(availableQuestions.take(10));
    }

    return selectedQuestions.take(30).toList();
  }

  /// Tính toán cấp độ dựa trên kết quả test
  PlacementTestLevel calculateLevel(
    List<PlacementTestQuestion> questions,
    List<PlacementTestAnswer> answers,
    int timeSpentSeconds,
  ) {
    if (questions.isEmpty || answers.isEmpty) {
      return PlacementTestLevel.a1;
    }

    // 1. Base Score: % câu đúng (weight: 40%)
    final correctCount = answers.where((a) => a.isCorrect).length;
    final baseScore = (correctCount / answers.length) * 100.0;

    // 2. Difficulty Score: Trung bình level của câu đúng (weight: 30%)
    double difficultyScore = 0;
    int correctDifficultyCount = 0;
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      if (answers[i].isCorrect) {
        difficultyScore += questions[i].level.numericValue * 20.0; // Scale to 0-100
        correctDifficultyCount++;
      }
    }
    if (correctDifficultyCount > 0) {
      difficultyScore /= correctDifficultyCount;
    }

    // 3. Category Balance: Điểm đều giữa các category (weight: 20%)
    final categoryScores = <PlacementTestCategory, int>{};
    final categoryTotals = <PlacementTestCategory, int>{};
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      final category = questions[i].category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + 1;
      if (answers[i].isCorrect) {
        categoryScores[category] = (categoryScores[category] ?? 0) + 1;
      }
    }
    double categoryBalance = 0;
    if (categoryTotals.isNotEmpty) {
      double minCategoryScore = 100;
      for (final category in categoryTotals.keys) {
        final score = (categoryScores[category] ?? 0) /
            categoryTotals[category]! *
            100.0;
        if (score < minCategoryScore) {
          minCategoryScore = score;
        }
      }
      categoryBalance = minCategoryScore;
    }

    // 4. Time Bonus: Thời gian hoàn thành (weight: 10%)
    // Giả sử thời gian lý tưởng là 30 phút (1800 giây) cho 30 câu
    const idealTimeSeconds = 1800;
    double timeBonus = 100.0;
    if (timeSpentSeconds > idealTimeSeconds) {
      // Nếu làm lâu hơn, giảm điểm
      timeBonus = max(0, 100.0 - ((timeSpentSeconds - idealTimeSeconds) / 60.0));
    }

    // Tính tổng điểm
    final totalScore = (baseScore * 0.4) +
        (difficultyScore * 0.3) +
        (categoryBalance * 0.2) +
        (timeBonus * 0.1);

    // Mapping Level
    if (totalScore >= 86) {
      return PlacementTestLevel.c1;
    } else if (totalScore >= 71) {
      return PlacementTestLevel.b2;
    } else if (totalScore >= 51) {
      return PlacementTestLevel.b1;
    } else if (totalScore >= 31) {
      return PlacementTestLevel.a2;
    } else {
      return PlacementTestLevel.a1;
    }
  }

  /// Tạo PlacementTestResult từ questions và answers
  PlacementTestResult createResult(
    List<PlacementTestQuestion> questions,
    List<PlacementTestAnswer> answers,
    int timeSpentSeconds,
    String? userId,
  ) {
    final assessedLevel = calculateLevel(questions, answers, timeSpentSeconds);
    final correctCount = answers.where((a) => a.isCorrect).length;
    final scorePercentage = (correctCount / answers.length) * 100.0;

    // Tính category scores
    final categoryScores = <PlacementTestCategory, int>{};
    final categoryTotals = <PlacementTestCategory, int>{};
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      final category = questions[i].category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + 1;
      if (answers[i].isCorrect) {
        categoryScores[category] = (categoryScores[category] ?? 0) + 1;
      }
    }

    return PlacementTestResult(
      userId: userId,
      assessedLevel: assessedLevel,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      scorePercentage: scorePercentage,
      categoryScores: categoryScores,
      categoryTotals: categoryTotals,
      completedAt: DateTime.now(),
      timeSpentSeconds: timeSpentSeconds,
    );
  }
}

