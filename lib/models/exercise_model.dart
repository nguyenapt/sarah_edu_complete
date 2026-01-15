import 'dart:convert';
import 'voice_config.dart';

enum ExerciseType {
  singleChoice,
  multipleChoice,
  fillBlank,
  matching,
  listening,
  speaking,
  buttonSingleChoice,
  crossword,
  sequentialQuestions,
  wordMatching,
  definitionMatching,
  wordFormationExercise,
  wordPatternExercise;

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
  final List<dynamic> rightItems; // Có thể là List<String> hoặc List<Map<String, String>>
  final List<MatchingPair> correctPairs;

  MatchingContent({
    required this.leftItems,
    required this.rightItems,
    required this.correctPairs,
  });

  /// Lấy right item theo language code
  String getRightItem(int index, String languageCode) {
    if (index < 0 || index >= rightItems.length) return '';
    final item = rightItems[index];
    if (item is Map) {
      final itemMap = item as Map<String, dynamic>;
      return itemMap[languageCode]?.toString() ?? 
             itemMap['en']?.toString() ?? 
             (itemMap.values.isNotEmpty ? itemMap.values.first.toString() : '');
    }
    return item.toString();
  }

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

    // RightItems - hỗ trợ multi-language (có thể là List<String> hoặc List<Map<String, String>>)
    List<dynamic> rightItemsList = [];
    if (map['rightItems'] != null) {
      final rightItems = map['rightItems'] as List<dynamic>;
      rightItemsList = rightItems.map((item) {
        if (item is Map) {
          // Giữ nguyên Map để hỗ trợ multi-language
          return item as Map<String, dynamic>;
        }
        // Nếu là String, giữ nguyên
        return item;
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
  final dynamic right; // Có thể là String hoặc Map<String, String> cho multi-language

  MatchingPair({
    required this.left,
    required this.right,
  });

  /// Lấy right value theo language code
  String getRight(String languageCode) {
    if (right is Map) {
      final rightMap = right as Map<String, dynamic>;
      return rightMap[languageCode]?.toString() ?? 
             rightMap['en']?.toString() ?? 
             (rightMap.values.isNotEmpty ? rightMap.values.first.toString() : '');
    }
    return right.toString();
  }

  factory MatchingPair.fromMap(Map<String, dynamic> map) {
    // Left - luôn là String (tiếng Anh)
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

    // Right - hỗ trợ multi-language (có thể là String hoặc Map<String, String>)
    dynamic rightValue;
    if (map['right'] != null) {
      if (map['right'] is Map) {
        // Giữ nguyên Map để hỗ trợ multi-language
        rightValue = map['right'] as Map<String, dynamic>;
      } else {
        // Nếu là String, giữ nguyên
        rightValue = map['right'].toString();
      }
    } else {
      rightValue = '';
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

// Content cho Crossword
class CrosswordWord {
  final int number;              // Số thứ tự (1, 2, 3...)
  final String direction;        // "across" hoặc "down"
  final int startRow;            // Row bắt đầu (0-indexed)
  final int startCol;            // Col bắt đầu (0-indexed)
  final String clue;             // Clue text (String, KHÔNG multi-language)
  final String answer;           // Đáp án (Uppercase, no spaces)
  final int length;              // Độ dài của từ

  CrosswordWord({
    required this.number,
    required this.direction,
    required this.startRow,
    required this.startCol,
    required this.clue,
    required this.answer,
    required this.length,
  });

  factory CrosswordWord.fromMap(Map<String, dynamic> map) {
    return CrosswordWord(
      number: map['number'] ?? 0,
      direction: map['direction'] ?? 'across',
      startRow: map['startRow'] ?? 0,
      startCol: map['startCol'] ?? 0,
      clue: map['clue']?.toString() ?? '',
      answer: map['answer']?.toString().toUpperCase() ?? '',
      length: map['length'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'direction': direction,
      'startRow': startRow,
      'startCol': startCol,
      'clue': clue,
      'answer': answer,
      'length': length,
    };
  }
}

class CrosswordContent {
  final int rows;
  final int cols;
  final List<CrosswordWord> words;
  final List<List<int?>> grid; // Matrix: null = block, int = word number tại ô bắt đầu

  CrosswordContent({
    required this.rows,
    required this.cols,
    required this.words,
    required this.grid,
  });

  factory CrosswordContent.fromMap(Map<String, dynamic> map) {
    // Parse grid
    // Firestore không hỗ trợ nested arrays, nên grid được serialize thành JSON string
    List<List<int?>> gridList = [];
    if (map['grid'] != null) {
      if (map['grid'] is String) {
        // Grid là JSON string, parse lại
        try {
          final gridJson = map['grid'] as String;
          final gridData = jsonDecode(gridJson) as List<dynamic>;
          gridList = gridData.map((row) {
            if (row is List) {
              return row.map((cell) {
                final cellValue = cell is int ? cell : int.tryParse(cell.toString());
                // Convert -1 (từ Firestore) thành null
                if (cellValue == -1) return null;
                return cellValue;
              }).toList();
            }
            return <int?>[];
          }).toList();
        } catch (e) {
          // Fallback: nếu parse JSON fail, giữ nguyên format cũ (nested array)
          final gridData = map['grid'] as List<dynamic>;
          gridList = gridData.map((row) {
            if (row is List) {
              return row.map((cell) {
                if (cell == null) return null;
                final cellValue = cell is int ? cell : int.tryParse(cell.toString());
                if (cellValue == -1) return null;
                return cellValue;
              }).toList();
            }
            return <int?>[];
          }).toList();
        }
      } else {
        // Fallback: format cũ (nested array) - để backward compatibility
        final gridData = map['grid'] as List<dynamic>;
        gridList = gridData.map((row) {
          if (row is List) {
            return row.map((cell) {
              if (cell == null) return null;
              final cellValue = cell is int ? cell : int.tryParse(cell.toString());
              if (cellValue == -1) return null;
              return cellValue;
            }).toList();
          }
          return <int?>[];
        }).toList();
      }
    }

    // Parse words
    List<CrosswordWord> wordsList = [];
    if (map['words'] != null) {
      final wordsData = map['words'] as List<dynamic>;
      wordsList = wordsData
          .map((word) => CrosswordWord.fromMap(word as Map<String, dynamic>))
          .toList();
    }

    return CrosswordContent(
      rows: map['rows'] ?? 0,
      cols: map['cols'] ?? 0,
      words: wordsList,
      grid: gridList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rows': rows,
      'cols': cols,
      'grid': grid,
      'words': words.map((w) => w.toMap()).toList(),
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
      case ExerciseType.crossword:
        final contentData = map['content'] ?? {};
        content = CrosswordContent.fromMap(contentData);
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
    } else if (content is FillBlankContent) {
      contentMap = (content as FillBlankContent).toMap();
    } else if (content is CrosswordContent) {
      contentMap = (content as CrosswordContent).toMap();
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

// Vocabulary Exercise Content Classes
class WordMatchPair {
  final String word;
  final Map<String, dynamic>? definition; // Multi-language: Map<String, String>
  final String? audioUrl;

  WordMatchPair({
    required this.word,
    this.definition,
    this.audioUrl,
  });

  /// Get definition theo language code
  String getDefinition(String languageCode) {
    if (definition == null) return '';
    if (definition is Map<String, dynamic>) {
      final defMap = definition as Map<String, dynamic>;
      if (languageCode != null && defMap.containsKey(languageCode)) {
        return defMap[languageCode]?.toString() ?? '';
      }
      return defMap['en']?.toString() ?? 
             (defMap.values.isNotEmpty ? defMap.values.first.toString() : '');
    }
    return definition.toString();
  }

  factory WordMatchPair.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? definitionData;
    if (map['definition'] != null) {
      if (map['definition'] is Map) {
        definitionData = map['definition'] as Map<String, dynamic>;
      } else {
        definitionData = {'en': map['definition'].toString()};
      }
    }

    return WordMatchPair(
      word: map['word']?.toString() ?? '',
      definition: definitionData,
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'definition': definition,
      if (audioUrl != null) 'audioUrl': audioUrl,
    };
  }
}

class WordMatchingContent {
  final List<WordMatchPair> pairs;
  final bool shuffleOptions;

  WordMatchingContent({
    required this.pairs,
    this.shuffleOptions = true,
  });

  factory WordMatchingContent.fromMap(Map<String, dynamic> map) {
    List<WordMatchPair> pairsList = [];
    if (map['pairs'] != null) {
      pairsList = (map['pairs'] as List<dynamic>)
          .map((e) => WordMatchPair.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return WordMatchingContent(
      pairs: pairsList,
      shuffleOptions: map['shuffleOptions'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pairs': pairs.map((e) => e.toMap()).toList(),
      'shuffleOptions': shuffleOptions,
    };
  }
}

class DefinitionMatchPair {
  final Map<String, dynamic>? definition; // Multi-language: Map<String, String>
  final String word;
  final String? example;

  DefinitionMatchPair({
    this.definition,
    required this.word,
    this.example,
  });

  /// Get definition theo language code
  String getDefinition(String languageCode) {
    if (definition == null) return '';
    if (definition is Map<String, dynamic>) {
      final defMap = definition as Map<String, dynamic>;
      if (languageCode != null && defMap.containsKey(languageCode)) {
        return defMap[languageCode]?.toString() ?? '';
      }
      return defMap['en']?.toString() ?? 
             (defMap.values.isNotEmpty ? defMap.values.first.toString() : '');
    }
    return definition.toString();
  }

  factory DefinitionMatchPair.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? definitionData;
    if (map['definition'] != null) {
      if (map['definition'] is Map) {
        definitionData = map['definition'] as Map<String, dynamic>;
      } else {
        definitionData = {'en': map['definition'].toString()};
      }
    }

    return DefinitionMatchPair(
      definition: definitionData,
      word: map['word']?.toString() ?? '',
      example: map['example'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'definition': definition,
      'word': word,
      if (example != null) 'example': example,
    };
  }
}

class DefinitionMatchingContent {
  final List<DefinitionMatchPair> pairs;

  DefinitionMatchingContent({
    required this.pairs,
  });

  factory DefinitionMatchingContent.fromMap(Map<String, dynamic> map) {
    List<DefinitionMatchPair> pairsList = [];
    if (map['pairs'] != null) {
      pairsList = (map['pairs'] as List<dynamic>)
          .map((e) => DefinitionMatchPair.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return DefinitionMatchingContent(
      pairs: pairsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pairs': pairs.map((e) => e.toMap()).toList(),
    };
  }
}

class WordFormationContent {
  final String sentence; // Câu có chỗ trống
  final String baseWord; // Từ gốc
  final String correctForm; // Dạng đúng (derived form)
  final List<String> options; // Các dạng có thể
  final String? explanation; // Giải thích

  WordFormationContent({
    required this.sentence,
    required this.baseWord,
    required this.correctForm,
    this.options = const [],
    this.explanation,
  });

  factory WordFormationContent.fromMap(Map<String, dynamic> map) {
    String sentenceText = '';
    if (map['sentence'] != null) {
      if (map['sentence'] is Map) {
        final sentenceMap = map['sentence'] as Map<String, dynamic>;
        sentenceText = sentenceMap['en']?.toString() ?? 
                      sentenceMap.values.first.toString();
      } else {
        sentenceText = map['sentence'].toString();
      }
    }

    List<String> optionsList = [];
    if (map['options'] != null) {
      if (map['options'] is List) {
        optionsList = (map['options'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        optionsList = [map['options'].toString()];
      }
    }

    String? explanationText;
    if (map['explanation'] != null) {
      if (map['explanation'] is Map) {
        final explanationMap = map['explanation'] as Map<String, dynamic>;
        explanationText = explanationMap['en']?.toString() ?? 
                        explanationMap.values.first.toString();
      } else {
        explanationText = map['explanation'].toString();
      }
    }

    return WordFormationContent(
      sentence: sentenceText,
      baseWord: map['baseWord']?.toString() ?? '',
      correctForm: map['correctForm']?.toString() ?? '',
      options: optionsList,
      explanation: explanationText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentence': sentence,
      'baseWord': baseWord,
      'correctForm': correctForm,
      'options': options,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class WordPatternContent {
  final String sentence; // Câu có chỗ trống
  final String word; // Từ cần điền giới từ
  final String correctPreposition; // Giới từ đúng
  final List<String> options; // Các giới từ có thể
  final String pattern; // Pattern (ví dụ: "good at")

  WordPatternContent({
    required this.sentence,
    required this.word,
    required this.correctPreposition,
    this.options = const [],
    required this.pattern,
  });

  factory WordPatternContent.fromMap(Map<String, dynamic> map) {
    String sentenceText = '';
    if (map['sentence'] != null) {
      if (map['sentence'] is Map) {
        final sentenceMap = map['sentence'] as Map<String, dynamic>;
        sentenceText = sentenceMap['en']?.toString() ?? 
                      sentenceMap.values.first.toString();
      } else {
        sentenceText = map['sentence'].toString();
      }
    }

    List<String> optionsList = [];
    if (map['options'] != null) {
      if (map['options'] is List) {
        optionsList = (map['options'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        optionsList = [map['options'].toString()];
      }
    }

    return WordPatternContent(
      sentence: sentenceText,
      word: map['word']?.toString() ?? '',
      correctPreposition: map['correctPreposition']?.toString() ?? '',
      options: optionsList,
      pattern: map['pattern']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentence': sentence,
      'word': word,
      'correctPreposition': correctPreposition,
      'options': options,
      'pattern': pattern,
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
  final Map<String, VoiceConfig>? speakerVoices; // Map speaker name -> VoiceConfig
  final VoiceConfig? defaultVoice; // Default voice for text without speaker name

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
    this.speakerVoices,
    this.defaultVoice,
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
      case ExerciseType.crossword:
        content = CrosswordContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.sequentialQuestions:
        // sequentialQuestions uses groupQuestions, content can be empty
        content = {};
        break;
      case ExerciseType.wordMatching:
        content = WordMatchingContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.definitionMatching:
        content = DefinitionMatchingContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.wordFormationExercise:
        content = WordFormationContent.fromMap(data['content'] ?? {});
        break;
      case ExerciseType.wordPatternExercise:
        content = WordPatternContent.fromMap(data['content'] ?? {});
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

    // Speaker Voices
    Map<String, VoiceConfig>? speakerVoicesData;
    if (data['speakerVoices'] != null) {
      final speakerVoicesMap = data['speakerVoices'] as Map<String, dynamic>;
      speakerVoicesData = speakerVoicesMap.map(
        (key, value) => MapEntry(key, VoiceConfig.fromMap(value as Map<String, dynamic>)),
      );
    }

    // Default Voice
    VoiceConfig? defaultVoiceData;
    if (data['defaultVoice'] != null) {
      defaultVoiceData = VoiceConfig.fromMap(data['defaultVoice'] as Map<String, dynamic>);
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
      speakerVoices: speakerVoicesData,
      defaultVoice: defaultVoiceData,
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
    } else if (content is CrosswordContent) {
      contentMap = (content as CrosswordContent).toMap();
    } else if (content is WordMatchingContent) {
      contentMap = (content as WordMatchingContent).toMap();
    } else if (content is DefinitionMatchingContent) {
      contentMap = (content as DefinitionMatchingContent).toMap();
    } else if (content is WordFormationContent) {
      contentMap = (content as WordFormationContent).toMap();
    } else if (content is WordPatternContent) {
      contentMap = (content as WordPatternContent).toMap();
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
      'speakerVoices': speakerVoices?.map((key, value) => MapEntry(key, value.toMap())),
      'defaultVoice': defaultVoice?.toMap(),
    };
  }
}


