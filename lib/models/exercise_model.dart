enum ExerciseType {
  singleChoice,
  multipleChoice,
  fillBlank,
  matching,
  listening,
  speaking,
  buttonSingleChoice;

  static ExerciseType fromString(String value) {
    // Normalize value: convert snake_case to camelCase
    String normalizedValue = value;
    if (value.contains('_')) {
      final parts = value.split('_');
      normalizedValue = parts[0] + 
          parts.sublist(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
    }
    
    return ExerciseType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == normalizedValue.toLowerCase(),
      orElse: () => ExerciseType.singleChoice,
    );
  }

  @override
  String toString() {
    return name;
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => Difficulty.easy,
    );
  }

  @override
  String toString() {
    return name;
  }
}

// Content cho Single Choice và Multiple Choice
class ChoiceContent {
  final List<String> options;
  final List<String> correctAnswers; // Cho multiple choice

  ChoiceContent({
    required this.options,
    required this.correctAnswers,
  });

  factory ChoiceContent.fromMap(Map<String, dynamic> map) {
    // Options - luôn là List<String> (tiếng Anh)
    List<String> optionsList = [];
    if (map['options'] != null) {
      final options = map['options'] as List<dynamic>;
      optionsList = options.map((option) {
        if (option is Map) {
          // Nếu là Map, lấy giá trị 'en' hoặc giá trị đầu tiên
          final optionMap = option as Map<String, dynamic>;
          return optionMap['en']?.toString() ?? 
                 optionMap.values.first.toString();
        }
        return option.toString();
      }).toList();
    }

    // CorrectAnswers - luôn là List<String> (tiếng Anh)
    List<String> correctAnswersList = [];
    if (map['correctAnswers'] != null) {
      final correctAnswers = map['correctAnswers'] as List<dynamic>;
      correctAnswersList = correctAnswers.map((answer) {
        if (answer is Map) {
          // Nếu là Map, lấy giá trị 'en' hoặc giá trị đầu tiên
          final answerMap = answer as Map<String, dynamic>;
          return answerMap['en']?.toString() ?? 
                 answerMap.values.first.toString();
        }
        return answer.toString();
      }).toList();
    }

    return ChoiceContent(
      options: optionsList,
      correctAnswers: correctAnswersList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'options': options,
      'correctAnswers': correctAnswers,
    };
  }
}

// Content cho Fill Blank
class FillBlankContent {
  final String text; // Text với ___ để điền
  final List<BlankItem> blanks;

  FillBlankContent({
    required this.text,
    required this.blanks,
  });

  factory FillBlankContent.fromMap(Map<String, dynamic> map) {
    // Text - luôn là String (tiếng Anh)
    String textValue = '';
    if (map['text'] != null) {
      if (map['text'] is Map) {
        final textMap = map['text'] as Map<String, dynamic>;
        textValue = textMap['en']?.toString() ?? 
                   textMap.values.first.toString();
      } else {
        textValue = map['text'].toString();
      }
    }

    // Parse blanks - hỗ trợ cả format cũ (blanks array) và format mới (correctAnswers array)
    List<BlankItem> blanksList = [];
    
    // Format mới: có correctAnswers array (ưu tiên nếu có cả 2)
    if (map['correctAnswers'] != null) {
      final correctAnswers = map['correctAnswers'] as List<dynamic>;
      for (int i = 0; i < correctAnswers.length; i++) {
        blanksList.add(BlankItem(
          position: i,
          correctAnswer: correctAnswers[i].toString(),
          hints: [],
        ));
      }
    } else if (map['blanks'] != null) {
      // Format cũ: có blanks array
      blanksList = (map['blanks'] as List<dynamic>)
          .map((e) => BlankItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return FillBlankContent(
      text: textValue,
      blanks: blanksList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'blanks': blanks.map((e) => e.toMap()).toList(),
    };
  }
}

class BlankItem {
  final int position;
  final String correctAnswer;
  final List<String> hints;

  BlankItem({
    required this.position,
    required this.correctAnswer,
    this.hints = const [],
  });

  factory BlankItem.fromMap(Map<String, dynamic> map) {
    // CorrectAnswer - luôn là String (tiếng Anh)
    String correctAnswerValue = '';
    if (map['correctAnswer'] != null) {
      if (map['correctAnswer'] is Map) {
        final answerMap = map['correctAnswer'] as Map<String, dynamic>;
        correctAnswerValue = answerMap['en']?.toString() ?? 
                           answerMap.values.first.toString();
      } else {
        correctAnswerValue = map['correctAnswer'].toString();
      }
    }

    // Hints - luôn là List<String> (tiếng Anh)
    List<String> hintsList = [];
    if (map['hints'] != null) {
      final hints = map['hints'] as List<dynamic>;
      hintsList = hints.map((hint) {
        if (hint is Map) {
          final hintMap = hint as Map<String, dynamic>;
          return hintMap['en']?.toString() ?? 
                 hintMap.values.first.toString();
        }
        return hint.toString();
      }).toList();
    }

    return BlankItem(
      position: map['position'] ?? 0,
      correctAnswer: correctAnswerValue,
      hints: hintsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'correctAnswer': correctAnswer,
      'hints': hints,
    };
  }
}

// Content cho Matching
class MatchingContent {
  final List<String> leftItems;
  final List<String> rightItems;
  final List<MatchingPair> correctPairs;

  MatchingContent({
    required this.leftItems,
    required this.rightItems,
    required this.correctPairs,
  });

  factory MatchingContent.fromMap(Map<String, dynamic> map) {
    // LeftItems - luôn là List<String> (tiếng Anh)
    List<String> leftItemsList = [];
    if (map['leftItems'] != null) {
      final leftItems = map['leftItems'] as List<dynamic>;
      leftItemsList = leftItems.map((item) {
        if (item is Map) {
          final itemMap = item as Map<String, dynamic>;
          return itemMap['en']?.toString() ?? 
                 itemMap.values.first.toString();
        }
        return item.toString();
      }).toList();
    }

    // RightItems - luôn là List<String> (tiếng Anh)
    List<String> rightItemsList = [];
    if (map['rightItems'] != null) {
      final rightItems = map['rightItems'] as List<dynamic>;
      rightItemsList = rightItems.map((item) {
        if (item is Map) {
          final itemMap = item as Map<String, dynamic>;
          return itemMap['en']?.toString() ?? 
                 itemMap.values.first.toString();
        }
        return item.toString();
      }).toList();
    }

    return MatchingContent(
      leftItems: leftItemsList,
      rightItems: rightItemsList,
      correctPairs: (map['correctPairs'] as List<dynamic>?)
              ?.map((e) => MatchingPair.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leftItems': leftItems,
      'rightItems': rightItems,
      'correctPairs': correctPairs.map((e) => e.toMap()).toList(),
    };
  }
}

class MatchingPair {
  final String left;
  final String right;

  MatchingPair({
    required this.left,
    required this.right,
  });

  factory MatchingPair.fromMap(Map<String, dynamic> map) {
    // Left và Right - luôn là String (tiếng Anh)
    String leftValue = '';
    if (map['left'] != null) {
      if (map['left'] is Map) {
        final leftMap = map['left'] as Map<String, dynamic>;
        leftValue = leftMap['en']?.toString() ?? 
                  leftMap.values.first.toString();
      } else {
        leftValue = map['left'].toString();
      }
    }

    String rightValue = '';
    if (map['right'] != null) {
      if (map['right'] is Map) {
        final rightMap = map['right'] as Map<String, dynamic>;
        rightValue = rightMap['en']?.toString() ?? 
                   rightMap.values.first.toString();
      } else {
        rightValue = map['right'].toString();
      }
    }

    return MatchingPair(
      left: leftValue,
      right: rightValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'right': right,
    };
  }
}

// Content cho Listening
class ListeningContent {
  final String audioUrl;
  final String transcript;

  ListeningContent({
    required this.audioUrl,
    required this.transcript,
  });

  factory ListeningContent.fromMap(Map<String, dynamic> map) {
    return ListeningContent(
      audioUrl: map['audioUrl'] ?? '',
      transcript: map['transcript'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audioUrl': audioUrl,
      'transcript': transcript,
    };
  }
}

// Content cho Button Single Choice
class ButtonSingleChoiceContent {
  final List<String> options;
  final List<String> correctAnswers;

  ButtonSingleChoiceContent({
    required this.options,
    required this.correctAnswers,
  });

  factory ButtonSingleChoiceContent.fromMap(Map<String, dynamic> map) {
    // Options - luôn là List<String> (tiếng Anh)
    List<String> optionsList = [];
    if (map['options'] != null) {
      final options = map['options'] as List<dynamic>;
      optionsList = options.map((option) {
        if (option is Map) {
          final optionMap = option as Map<String, dynamic>;
          return optionMap['en']?.toString() ?? 
                 optionMap.values.first.toString();
        }
        return option.toString();
      }).toList();
    }

    // CorrectAnswers - luôn là List<String> (tiếng Anh)
    List<String> correctAnswersList = [];
    if (map['correctAnswers'] != null) {
      final correctAnswers = map['correctAnswers'] as List<dynamic>;
      correctAnswersList = correctAnswers.map((answer) {
        if (answer is Map) {
          final answerMap = answer as Map<String, dynamic>;
          return answerMap['en']?.toString() ?? 
                 answerMap.values.first.toString();
        }
        return answer.toString();
      }).toList();
    }

    return ButtonSingleChoiceContent(
      options: optionsList,
      correctAnswers: correctAnswersList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'options': options,
      'correctAnswers': correctAnswers,
    };
  }
}

// Group Question - cho exercise có nhiều câu hỏi
class GroupQuestion {
  final String question; // Question với placeholder {0}, {1}, {2}...
  final ExerciseType type;
  final dynamic content; // ButtonSingleChoiceContent, ChoiceContent, etc.
  final int point;
  final int? timeLimit;
  final Difficulty difficulty;
  final Map<String, dynamic>? explanation; // Multi-language
  final String? imageUrl;
  final String? audioUrl;

  GroupQuestion({
    required this.question,
    required this.type,
    required this.content,
    required this.point,
    this.timeLimit,
    required this.difficulty,
    this.explanation,
    this.imageUrl,
    this.audioUrl,
  });

  /// Get explanation theo language code
  String? getExplanation(String languageCode) {
    if (explanation == null) return null;
    if (explanation is Map<String, dynamic>) {
      final expMap = explanation as Map<String, dynamic>;
      if (languageCode != null && expMap.containsKey(languageCode)) {
        return expMap[languageCode]?.toString();
      }
      return expMap['en']?.toString() ?? 
             (expMap.values.isNotEmpty ? expMap.values.first.toString() : null);
    }
    return explanation.toString();
  }

  factory GroupQuestion.fromMap(Map<String, dynamic> map, {String? languageCode}) {
    final type = ExerciseType.fromString(map['type'] ?? 'button_single_choice');
    dynamic content;

    switch (type) {
      case ExerciseType.buttonSingleChoice:
        final contentData = map['content'] ?? {};
        content = ButtonSingleChoiceContent.fromMap(contentData);
        break;
      case ExerciseType.singleChoice:
      case ExerciseType.multipleChoice:
        content = ChoiceContent.fromMap(map['content'] ?? {});
        break;
      case ExerciseType.fillBlank:
        final contentData = map['content'] ?? {};
        content = FillBlankContent.fromMap(contentData);
        break;
      default:
        content = null;
    }

    // Question - luôn là String
    String questionText = '';
    if (map['question'] != null) {
      if (map['question'] is Map<String, dynamic>) {
        final questionMap = map['question'] as Map<String, dynamic>;
        if (languageCode != null && questionMap.containsKey(languageCode)) {
          questionText = questionMap[languageCode].toString();
        } else {
          questionText = questionMap['en']?.toString() ?? 
                        (questionMap.values.isNotEmpty 
                          ? questionMap.values.first.toString() 
                          : '');
        }
      } else {
        questionText = map['question'].toString();
      }
    }

    // Explanation
    Map<String, dynamic>? explanationData;
    if (map['explanation'] != null) {
      if (map['explanation'] is Map) {
        explanationData = Map<String, dynamic>.from(map['explanation']);
      } else {
        explanationData = {'en': map['explanation'].toString()};
      }
    }

    return GroupQuestion(
      question: questionText,
      type: type,
      content: content,
      point: map['point'] ?? 0,
      timeLimit: map['timeLimit'],
      difficulty: Difficulty.fromString(map['difficulty'] ?? 'easy'),
      explanation: explanationData,
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> contentMap = {};
    if (content is ButtonSingleChoiceContent) {
      contentMap = (content as ButtonSingleChoiceContent).toMap();
    } else if (content is ChoiceContent) {
      contentMap = (content as ChoiceContent).toMap();
    }

    return {
      'question': question,
      'type': type.toString(),
      'content': contentMap,
      'point': point,
      'timeLimit': timeLimit,
      'difficulty': difficulty.toString(),
      'explanation': explanation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
}

// Content cho Speaking
class SpeakingContent {
  final String prompt;
  final List<String> expectedKeywords;

  SpeakingContent({
    required this.prompt,
    this.expectedKeywords = const [],
  });

  factory SpeakingContent.fromMap(Map<String, dynamic> map) {
    // Prompt - luôn là String (tiếng Anh)
    String promptValue = '';
    if (map['prompt'] != null) {
      if (map['prompt'] is Map) {
        final promptMap = map['prompt'] as Map<String, dynamic>;
        promptValue = promptMap['en']?.toString() ?? 
                    promptMap.values.first.toString();
      } else {
        promptValue = map['prompt'].toString();
      }
    }

    // ExpectedKeywords - luôn là List<String> (tiếng Anh)
    List<String> keywordsList = [];
    if (map['expectedKeywords'] != null) {
      final keywords = map['expectedKeywords'] as List<dynamic>;
      keywordsList = keywords.map((keyword) {
        if (keyword is Map) {
          final keywordMap = keyword as Map<String, dynamic>;
          return keywordMap['en']?.toString() ?? 
                 keywordMap.values.first.toString();
        }
        return keyword.toString();
      }).toList();
    }

    return SpeakingContent(
      prompt: promptValue,
      expectedKeywords: keywordsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'expectedKeywords': expectedKeywords,
    };
  }
}

class ExerciseModel {
  final String id;
  final String lessonId;
  final String unitId;
  final String levelId;
  final ExerciseType type;
  final String question;
  final dynamic content; // ChoiceContent, FillBlankContent, etc.
  final int points;
  final int? timeLimit; // seconds
  final Difficulty difficulty;
  final String? explanation;
  final List<GroupQuestion>? groupQuestions; // Cho exercise có nhiều câu hỏi
  final String? imageUrl;
  final String? audioUrl;
  final Map<String, dynamic>? title; // Multi-language: Map<String, String>

  ExerciseModel({
    required this.id,
    required this.lessonId,
    required this.unitId,
    required this.levelId,
    required this.type,
    required this.question,
    required this.content,
    this.points = 10,
    this.timeLimit,
    required this.difficulty,
    this.explanation,
    this.groupQuestions,
    this.imageUrl,
    this.audioUrl,
    this.title,
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    if (title == null) return '';
    if (title is Map<String, dynamic>) {
      final titleMap = title as Map<String, dynamic>;
      if (languageCode != null && titleMap.containsKey(languageCode)) {
        return titleMap[languageCode]?.toString() ?? '';
      }
      return titleMap['en']?.toString() ?? 
             (titleMap.values.isNotEmpty ? titleMap.values.first.toString() : '');
    }
    return title.toString();
  }

  factory ExerciseModel.fromFirestore(
    Map<String, dynamic> data, 
    String id, {
    String? languageCode,
  }) {
    final type = ExerciseType.fromString(data['type'] ?? 'single_choice');
    dynamic content;

    switch (type) {
      case ExerciseType.singleChoice:
      case ExerciseType.multipleChoice:
        content = ChoiceContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.fillBlank:
        content = FillBlankContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.matching:
        content = MatchingContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.listening:
        content = ListeningContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.speaking:
        content = SpeakingContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.buttonSingleChoice:
        content = ButtonSingleChoiceContent.fromMap(data['content'] ?? {});
        break;
    }

    // Group Questions
    List<GroupQuestion>? groupQuestionsData;
    if (data['groupQuestions'] != null) {
      final groupQuestionsList = data['groupQuestions'] as List<dynamic>;
      groupQuestionsData = groupQuestionsList
          .map((e) => GroupQuestion.fromMap(e as Map<String, dynamic>, languageCode: languageCode))
          .toList();
    }

    // Question - luôn là String
    // Hỗ trợ cả String và Map<String, dynamic> (multilanguage) từ Firestore
    // Ưu tiên lấy theo language đã chọn, nếu không có thì fallback sang 'en'
    String questionText = '';
    if (data['question'] != null) {
      if (data['question'] is Map<String, dynamic>) {
        final questionMap = data['question'] as Map<String, dynamic>;
        // Ưu tiên lấy theo language đã chọn, nếu không có thì fallback sang 'en'
        if (languageCode != null && questionMap.containsKey(languageCode)) {
          questionText = questionMap[languageCode].toString();
        } else {
          questionText = questionMap['en']?.toString() ?? 
                        (questionMap.values.isNotEmpty 
                          ? questionMap.values.first.toString() 
                          : '');
        }
      } else {
        questionText = data['question'].toString();
      }
    }

    // Explanation - luôn là String
    // Hỗ trợ cả String và Map<String, dynamic> (multilanguage) từ Firestore
    // Ưu tiên lấy theo language đã chọn, nếu không có thì fallback sang 'en'
    String? explanationText;
    if (data['explanation'] != null) {
      if (data['explanation'] is Map<String, dynamic>) {
        final explanationMap = data['explanation'] as Map<String, dynamic>;
        // Ưu tiên lấy theo language đã chọn, nếu không có thì fallback sang 'en'
        if (languageCode != null && explanationMap.containsKey(languageCode)) {
          explanationText = explanationMap[languageCode].toString();
        } else {
          explanationText = explanationMap['en']?.toString() ?? 
                           (explanationMap.values.isNotEmpty 
                             ? explanationMap.values.first.toString() 
                             : null);
        }
      } else {
        explanationText = data['explanation'].toString();
      }
    }

    // Title - multi-language
    Map<String, dynamic>? titleData;
    if (data['title'] != null) {
      if (data['title'] is Map) {
        titleData = Map<String, dynamic>.from(data['title']);
      } else {
        titleData = {'en': data['title'].toString()};
      }
    }

    return ExerciseModel(
      id: id,
      lessonId: data['lessonId'] ?? '',
      unitId: data['unitId'] ?? '',
      levelId: data['levelId'] ?? '',
      type: type,
      question: questionText,
      content: content,
      points: data['points'] ?? 10,
      timeLimit: data['timeLimit'],
      difficulty: Difficulty.fromString(data['difficulty'] ?? 'easy'),
      explanation: explanationText,
      groupQuestions: groupQuestionsData,
      imageUrl: data['imageUrl'],
      audioUrl: data['audioUrl'],
      title: titleData,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> contentMap = {};
    
    if (content is ChoiceContent) {
      contentMap = (content as ChoiceContent).toMap();
    } else if (content is FillBlankContent) {
      contentMap = (content as FillBlankContent).toMap();
    } else if (content is MatchingContent) {
      contentMap = (content as MatchingContent).toMap();
    } else if (content is ListeningContent) {
      contentMap = (content as ListeningContent).toMap();
    } else if (content is SpeakingContent) {
      contentMap = (content as SpeakingContent).toMap();
    } else if (content is ButtonSingleChoiceContent) {
      contentMap = (content as ButtonSingleChoiceContent).toMap();
    }

    return {
      'lessonId': lessonId,
      'unitId': unitId,
      'levelId': levelId,
      'type': type.toString(),
      'question': question,
      'content': contentMap,
      'points': points,
      'timeLimit': timeLimit,
      'difficulty': difficulty.toString(),
      'explanation': explanation,
      'groupQuestions': groupQuestions?.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'title': title,
    };
  }
}


