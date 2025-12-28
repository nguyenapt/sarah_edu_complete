import 'multilanguage_content.dart';

enum PlacementTestCategory {
  vocabulary,
  grammar,
  reading,
  listening;

  static PlacementTestCategory fromString(String value) {
    return PlacementTestCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => PlacementTestCategory.vocabulary,
    );
  }

  @override
  String toString() {
    return name;
  }
}

enum PlacementTestType {
  singleChoice,
  multipleChoice,
  fillBlank;

  static PlacementTestType fromString(String value) {
    // Normalize value: convert snake_case to camelCase
    String normalizedValue = value;
    if (value.contains('_')) {
      final parts = value.split('_');
      normalizedValue = parts[0] +
          parts.sublist(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
    }

    return PlacementTestType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == normalizedValue.toLowerCase(),
      orElse: () => PlacementTestType.singleChoice,
    );
  }

  @override
  String toString() {
    return name;
  }
}

enum PlacementTestLevel {
  a1,
  a2,
  b1,
  b2,
  c1;

  static PlacementTestLevel fromString(String value) {
    return PlacementTestLevel.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
      orElse: () => PlacementTestLevel.a1,
    );
  }

  @override
  String toString() {
    return name.toUpperCase();
  }

  /// Get numeric value for level calculation
  int get numericValue {
    switch (this) {
      case PlacementTestLevel.a1:
        return 1;
      case PlacementTestLevel.a2:
        return 2;
      case PlacementTestLevel.b1:
        return 3;
      case PlacementTestLevel.b2:
        return 4;
      case PlacementTestLevel.c1:
        return 5;
    }
  }
}

/// Model cho câu hỏi placement test
class PlacementTestQuestion {
  final String id;
  final PlacementTestCategory category;
  final PlacementTestLevel level;
  final PlacementTestType type;
  final Map<String, dynamic>? question; // Multi-language: Map<String, String>
  final List<String> options;
  final List<String> correctAnswers;
  final Map<String, dynamic>? explanation; // Multi-language: Map<String, String>
  final int points;
  final String difficulty;

  PlacementTestQuestion({
    required this.id,
    required this.category,
    required this.level,
    required this.type,
    this.question,
    required this.options,
    required this.correctAnswers,
    this.explanation,
    required this.points,
    required this.difficulty,
  });

  /// Get question text theo language code
  String getQuestion(String languageCode) {
    return MultilanguageContent.getText(question, languageCode);
  }

  /// Get explanation text theo language code
  String getExplanation(String languageCode) {
    return MultilanguageContent.getText(explanation, languageCode);
  }

  factory PlacementTestQuestion.fromMap(Map<String, dynamic> map, String id) {
    // Question - multi-language
    Map<String, dynamic>? questionData;
    if (map['question'] != null) {
      if (map['question'] is Map) {
        questionData = map['question'] as Map<String, dynamic>;
      } else {
        questionData = {'en': map['question'].toString()};
      }
    }

    // Options - luôn là List<String> (tiếng Anh)
    List<String> optionsList = [];
    if (map['options'] != null) {
      final options = map['options'] as List<dynamic>;
      optionsList = options.map((option) => option.toString()).toList();
    }

    // CorrectAnswers - luôn là List<String> (tiếng Anh)
    List<String> correctAnswersList = [];
    if (map['correctAnswers'] != null) {
      final correctAnswers = map['correctAnswers'] as List<dynamic>;
      correctAnswersList = correctAnswers.map((answer) => answer.toString()).toList();
    }

    // Explanation - multi-language
    Map<String, dynamic>? explanationData;
    if (map['explanation'] != null) {
      if (map['explanation'] is Map) {
        explanationData = map['explanation'] as Map<String, dynamic>;
      } else {
        explanationData = {'en': map['explanation'].toString()};
      }
    }

    return PlacementTestQuestion(
      id: id,
      category: PlacementTestCategory.fromString(map['category'] ?? 'vocabulary'),
      level: PlacementTestLevel.fromString(map['level'] ?? 'A1'),
      type: PlacementTestType.fromString(map['type'] ?? 'single_choice'),
      question: questionData,
      options: optionsList,
      correctAnswers: correctAnswersList,
      explanation: explanationData,
      points: map['points'] ?? 5,
      difficulty: map['difficulty'] ?? 'easy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.toString(),
      'level': level.toString(),
      'type': type.toString(),
      'question': question,
      'options': options,
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'points': points,
      'difficulty': difficulty,
    };
  }
}

/// Model cho kết quả placement test
class PlacementTestResult {
  final String? userId; // null nếu là guest
  final PlacementTestLevel assessedLevel;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final Map<PlacementTestCategory, int> categoryScores; // Số câu đúng theo category
  final Map<PlacementTestCategory, int> categoryTotals; // Tổng số câu theo category
  final DateTime completedAt;
  final int? timeSpentSeconds; // Thời gian làm bài (giây)

  PlacementTestResult({
    this.userId,
    required this.assessedLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.categoryScores,
    required this.categoryTotals,
    required this.completedAt,
    this.timeSpentSeconds,
  });

  factory PlacementTestResult.fromMap(Map<String, dynamic> map) {
    // Parse category scores
    Map<PlacementTestCategory, int> catScores = {};
    if (map['categoryScores'] != null) {
      final scores = map['categoryScores'] as Map<String, dynamic>;
      scores.forEach((key, value) {
        catScores[PlacementTestCategory.fromString(key)] = value as int;
      });
    }

    // Parse category totals
    Map<PlacementTestCategory, int> catTotals = {};
    if (map['categoryTotals'] != null) {
      final totals = map['categoryTotals'] as Map<String, dynamic>;
      totals.forEach((key, value) {
        catTotals[PlacementTestCategory.fromString(key)] = value as int;
      });
    }

    return PlacementTestResult(
      userId: map['userId'],
      assessedLevel: PlacementTestLevel.fromString(map['assessedLevel'] ?? 'A1'),
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      scorePercentage: (map['scorePercentage'] ?? 0.0).toDouble(),
      categoryScores: catScores,
      categoryTotals: catTotals,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
      timeSpentSeconds: map['timeSpentSeconds'],
    );
  }

  Map<String, dynamic> toMap() {
    // Convert category maps to string keys
    Map<String, int> catScoresMap = {};
    categoryScores.forEach((key, value) {
      catScoresMap[key.toString()] = value;
    });

    Map<String, int> catTotalsMap = {};
    categoryTotals.forEach((key, value) {
      catTotalsMap[key.toString()] = value;
    });

    return {
      'userId': userId,
      'assessedLevel': assessedLevel.toString(),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'scorePercentage': scorePercentage,
      'categoryScores': catScoresMap,
      'categoryTotals': catTotalsMap,
      'completedAt': completedAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }
}

/// Model cho câu trả lời của user trong placement test
class PlacementTestAnswer {
  final String questionId;
  final List<String> selectedAnswers;
  final bool isCorrect;
  final DateTime answeredAt;

  PlacementTestAnswer({
    required this.questionId,
    required this.selectedAnswers,
    required this.isCorrect,
    required this.answeredAt,
  });

  factory PlacementTestAnswer.fromMap(Map<String, dynamic> map) {
    return PlacementTestAnswer(
      questionId: map['questionId'] ?? '',
      selectedAnswers: List<String>.from(map['selectedAnswers'] ?? []),
      isCorrect: map['isCorrect'] ?? false,
      answeredAt: map['answeredAt'] != null
          ? DateTime.parse(map['answeredAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswers': selectedAnswers,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}

