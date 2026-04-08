import 'multilanguage_content.dart';

class UsageItem {
  final Map<String, dynamic>? en; // {title: String, example: String}
  final Map<String, dynamic>? vi; // {title: String, example: String}

  UsageItem({
    this.en,
    this.vi,
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    if (languageCode == 'vi' && vi != null) {
      return vi!['title']?.toString() ?? '';
    }
    return en?['title']?.toString() ?? '';
  }

  /// Get example theo language code
  String getExample(String languageCode) {
    if (languageCode == 'vi' && vi != null) {
      return vi!['example']?.toString() ?? '';
    }
    return en?['example']?.toString() ?? '';
  }

  factory UsageItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? enData;
    if (map['en'] != null) {
      if (map['en'] is Map) {
        enData = Map<String, dynamic>.from(map['en']);
      } else {
        // Nếu là String, tạo Map với 'example' key
        enData = {'example': map['en'].toString()};
      }
    }

    Map<String, dynamic>? viData;
    if (map['vi'] != null) {
      if (map['vi'] is Map) {
        viData = Map<String, dynamic>.from(map['vi']);
      } else {
        // Nếu là String, tạo Map với 'example' key
        viData = {'example': map['vi'].toString()};
      }
    }

    return UsageItem(
      en: enData,
      vi: viData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'en': en,
      'vi': vi,
    };
  }
}

class TheoryContent {
  final Map<String, dynamic>? title; // Multi-language: Map<String, String>
  final Map<String, dynamic>? description; // Multi-language: Map<String, String>
  final List<Example> examples;
  final List<UsageItem>? usage; // Array of UsageItem
  final GrammarForms? forms;
  final VocabularyContent? vocabulary;

  TheoryContent({
    this.title,
    this.description,
    this.examples = const [],
    this.usage,
    this.forms,
    this.vocabulary,
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    return MultilanguageContent.getText(title, languageCode);
  }

  /// Get description theo language code
  String getDescription(String languageCode) {
    return MultilanguageContent.getText(description, languageCode);
  }

  /// Get usage items
  List<UsageItem> getUsageItems() {
    return usage ?? [];
  }

  factory TheoryContent.fromMap(Map<String, dynamic> map) {
    // Hỗ trợ cả String (backward compatible) và Map<String, String> (multi-language)
    Map<String, dynamic>? titleData;
    if (map['title'] != null) {
      if (map['title'] is Map) {
        titleData = map['title'] as Map<String, dynamic>;
      } else {
        titleData = {'en': map['title'].toString()};
      }
    }

    Map<String, dynamic>? descriptionData;
    if (map['description'] != null) {
      if (map['description'] is Map) {
        descriptionData = map['description'] as Map<String, dynamic>;
      } else {
        descriptionData = {'en': map['description'].toString()};
      }
    }

    // Usage: hỗ trợ cả List (new format) và Map/String (old format)
    List<UsageItem>? usageData;
    if (map['usage'] != null) {
      try {
        if (map['usage'] is List) {
          usageData = (map['usage'] as List<dynamic>)
              .map((e) {
                if (e is Map) {
                  return UsageItem.fromMap(e as Map<String, dynamic>);
                } else {
                  // Nếu item trong list là String
                  return UsageItem(
                    en: {'example': e.toString()},
                  );
                }
              })
              .toList();
        } else if (map['usage'] is Map) {
          // Old format: Map -> convert to List with one UsageItem
          final usageMap = map['usage'] as Map<String, dynamic>;
          usageData = [UsageItem.fromMap(usageMap)];
        } else {
          // Old format: String -> convert to List with one UsageItem
          usageData = [
            UsageItem(
              en: {'example': map['usage'].toString()},
            )
          ];
        }
      } catch (e) {
        // Nếu có lỗi khi parse, bỏ qua usage để không crash app
        usageData = null;
      }
    }

    return TheoryContent(
      title: titleData,
      description: descriptionData,
      examples: (map['examples'] as List<dynamic>?)
              ?.map((e) => Example.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      usage: usageData,
      forms: map['forms'] != null
          ? GrammarForms.fromMap(map['forms'] as Map<String, dynamic>)
          : null,
      vocabulary: map['vocabulary'] != null
          ? VocabularyContent.fromMap(map['vocabulary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'examples': examples.map((e) => e.toMap()).toList(),
      'usage': usage?.map((e) => e.toMap()).toList(),
      'forms': forms?.toMap(),
      'vocabulary': vocabulary?.toMap(),
    };
  }
}

class Example {
  final String sentence; // Tiếng Anh - không cần multi-language
  final Map<String, dynamic>? explanation; // Multi-language: Map<String, String>
  final String? audioUrl;

  Example({
    required this.sentence,
    this.explanation,
    this.audioUrl,
  });

  /// Get explanation theo language code
  String getExplanation(String languageCode) {
    return MultilanguageContent.getText(explanation, languageCode);
  }

  factory Example.fromMap(Map<String, dynamic> map) {
    // Sentence luôn là String (tiếng Anh)
    String sentenceText = '';
    if (map['sentence'] != null) {
      if (map['sentence'] is Map) {
        // Nếu là Map, lấy giá trị 'en' hoặc giá trị đầu tiên
        final sentenceMap = map['sentence'] as Map<String, dynamic>;
        sentenceText = sentenceMap['en']?.toString() ?? 
                      sentenceMap.values.first.toString();
      } else {
        sentenceText = map['sentence'].toString();
      }
    }

    // Explanation là multi-language
    Map<String, dynamic>? explanationData;
    if (map['explanation'] != null) {
      if (map['explanation'] is Map) {
        explanationData = map['explanation'] as Map<String, dynamic>;
      } else {
        explanationData = {'en': map['explanation'].toString()};
      }
    }

    return Example(
      sentence: sentenceText,
      explanation: explanationData,
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentence': sentence,
      'explanation': explanation,
      'audioUrl': audioUrl,
    };
  }
}

class GrammarForms {
  final List<String>? statement; // Array of strings
  final List<String>? negative; // Array of strings
  final List<String>? question; // Array of strings

  GrammarForms({
    this.statement,
    this.negative,
    this.question,
  });

  /// Get statement forms
  List<String> getStatement() {
    return statement ?? [];
  }

  /// Get negative forms
  List<String> getNegative() {
    return negative ?? [];
  }

  /// Get question forms
  List<String> getQuestion() {
    return question ?? [];
  }

  factory GrammarForms.fromMap(Map<String, dynamic> map) {
    // Hỗ trợ backward compatible: nếu là Map (old format) hoặc List (new format)
    List<String>? statementData;
    if (map['statement'] != null) {
      if (map['statement'] is List) {
        statementData = (map['statement'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (map['statement'] is Map) {
        // Old format: Map -> convert to List with first value
        final statementMap = map['statement'] as Map<String, dynamic>;
        statementData = [statementMap.values.first.toString()];
      } else {
        statementData = [map['statement'].toString()];
      }
    } else if (map['affirmative'] != null) {
      // Backward compatible với old field name
      if (map['affirmative'] is List) {
        statementData = (map['affirmative'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (map['affirmative'] is Map) {
        final affirmativeMap = map['affirmative'] as Map<String, dynamic>;
        statementData = [affirmativeMap.values.first.toString()];
      } else {
        statementData = [map['affirmative'].toString()];
      }
    }

    List<String>? negativeData;
    if (map['negative'] != null) {
      if (map['negative'] is List) {
        negativeData = (map['negative'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (map['negative'] is Map) {
        final negativeMap = map['negative'] as Map<String, dynamic>;
        negativeData = [negativeMap.values.first.toString()];
      } else {
        negativeData = [map['negative'].toString()];
      }
    }

    List<String>? questionData;
    if (map['question'] != null) {
      if (map['question'] is List) {
        questionData = (map['question'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (map['question'] is Map) {
        final questionMap = map['question'] as Map<String, dynamic>;
        questionData = [questionMap.values.first.toString()];
      } else {
        questionData = [map['question'].toString()];
      }
    } else if (map['interrogative'] != null) {
      // Backward compatible với old field name
      if (map['interrogative'] is List) {
        questionData = (map['interrogative'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else if (map['interrogative'] is Map) {
        final interrogativeMap = map['interrogative'] as Map<String, dynamic>;
        questionData = [interrogativeMap.values.first.toString()];
      } else {
        questionData = [map['interrogative'].toString()];
      }
    }

    return GrammarForms(
      statement: statementData,
      negative: negativeData,
      question: questionData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statement': statement,
      'negative': negative,
      'question': question,
    };
  }
}

class LessonModel {
  final String id;
  final String unitId;
  final String levelId;
  final Map<String, dynamic>? title; // Multi-language: Map<String, String>
  final LessonType type;
  final TheoryContent? theory;
  final List<String> exercises;
  final int order;

  LessonModel({
    required this.id,
    required this.unitId,
    required this.levelId,
    this.title,
    required this.type,
    this.theory,
    this.exercises = const [],
    required this.order,
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    return MultilanguageContent.getText(title, languageCode);
  }

  factory LessonModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Hỗ trợ cả String (backward compatible) và Map<String, String> (multi-language)
    Map<String, dynamic>? titleData;
    if (data['title'] != null) {
      if (data['title'] is Map) {
        titleData = data['title'] as Map<String, dynamic>;
      } else {
        titleData = {'en': data['title'].toString()};
      }
    }

    return LessonModel(
      id: id,
      unitId: data['unitId'] ?? '',
      levelId: data['levelId'] ?? '',
      title: titleData,
      type: LessonType.fromString(data['type'] ?? 'grammar'),
      theory: data['content'] != null &&
              data['content']['theory'] != null
          ? TheoryContent.fromMap(data['content']['theory'])
          : null,
      exercises: List<String>.from(
          data['content']?['exercises'] ?? []),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'unitId': unitId,
      'levelId': levelId,
      'title': title,
      'type': type.toString(),
      'content': {
        'theory': theory?.toMap(),
        'exercises': exercises,
      },
      'order': order,
    };
  }
}

// Vocabulary Content Classes
class TopicVocabularyItem {
  final String word;
  final String partOfSpeech; // v, n, adj, adv, etc.
  final Map<String, dynamic>? definitions; // Multi-language: Map<String, String>
  final List<String> examples;
  final String? audioUrl;
  final String? imageUrl;
  /// IPA / phiên âm (optional — hiển thị pill trên flashcard).
  final String? phonetic;

  TopicVocabularyItem({
    required this.word,
    required this.partOfSpeech,
    this.definitions,
    this.examples = const [],
    this.audioUrl,
    this.imageUrl,
    this.phonetic,
  });

  /// Get definition theo language code
  String getDefinition(String languageCode) {
    return MultilanguageContent.getText(definitions, languageCode);
  }

  factory TopicVocabularyItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? definitionsData;
    if (map['definitions'] != null) {
      if (map['definitions'] is Map) {
        definitionsData = map['definitions'] as Map<String, dynamic>;
      } else {
        definitionsData = {'en': map['definitions'].toString()};
      }
    }

    List<String> examplesList = [];
    if (map['examples'] != null) {
      if (map['examples'] is List) {
        examplesList = (map['examples'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        examplesList = [map['examples'].toString()];
      }
    }

    return TopicVocabularyItem(
      word: map['word']?.toString() ?? '',
      partOfSpeech: map['partOfSpeech']?.toString() ?? '',
      definitions: definitionsData,
      examples: examplesList,
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      phonetic: map['phonetic']?.toString() ?? map['ipa']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'partOfSpeech': partOfSpeech,
      'definitions': definitions,
      'examples': examples,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (phonetic != null) 'phonetic': phonetic,
    };
  }
}

class PhrasalVerbItem {
  final String verb;
  final Map<String, dynamic>? definition; // Multi-language: Map<String, String>
  final List<String> examples;

  PhrasalVerbItem({
    required this.verb,
    this.definition,
    this.examples = const [],
  });

  /// Get definition theo language code
  String getDefinition(String languageCode) {
    return MultilanguageContent.getText(definition, languageCode);
  }

  factory PhrasalVerbItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? definitionData;
    if (map['definition'] != null) {
      if (map['definition'] is Map) {
        definitionData = map['definition'] as Map<String, dynamic>;
      } else {
        definitionData = {'en': map['definition'].toString()};
      }
    }

    List<String> examplesList = [];
    if (map['examples'] != null) {
      if (map['examples'] is List) {
        examplesList = (map['examples'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        examplesList = [map['examples'].toString()];
      }
    }

    return PhrasalVerbItem(
      verb: map['verb']?.toString() ?? '',
      definition: definitionData,
      examples: examplesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verb': verb,
      'definition': definition,
      'examples': examples,
    };
  }
}

class PrepositionalPhraseItem {
  final String phrase;
  final Map<String, dynamic>? definition; // Multi-language: Map<String, String>
  final List<String> examples;

  PrepositionalPhraseItem({
    required this.phrase,
    this.definition,
    this.examples = const [],
  });

  /// Get definition theo language code
  String getDefinition(String languageCode) {
    return MultilanguageContent.getText(definition, languageCode);
  }

  factory PrepositionalPhraseItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? definitionData;
    if (map['definition'] != null) {
      if (map['definition'] is Map) {
        definitionData = map['definition'] as Map<String, dynamic>;
      } else {
        definitionData = {'en': map['definition'].toString()};
      }
    }

    List<String> examplesList = [];
    if (map['examples'] != null) {
      if (map['examples'] is List) {
        examplesList = (map['examples'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        examplesList = [map['examples'].toString()];
      }
    }

    return PrepositionalPhraseItem(
      phrase: map['phrase']?.toString() ?? '',
      definition: definitionData,
      examples: examplesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phrase': phrase,
      'definition': definition,
      'examples': examples,
    };
  }
}

class WordFormationItem {
  final String baseWord;
  final List<String> relatedForms;
  final List<String> examples;

  WordFormationItem({
    required this.baseWord,
    this.relatedForms = const [],
    this.examples = const [],
  });

  factory WordFormationItem.fromMap(Map<String, dynamic> map) {
    List<String> relatedFormsList = [];
    if (map['relatedForms'] != null) {
      if (map['relatedForms'] is List) {
        relatedFormsList = (map['relatedForms'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        relatedFormsList = [map['relatedForms'].toString()];
      }
    }

    List<String> examplesList = [];
    if (map['examples'] != null) {
      if (map['examples'] is List) {
        examplesList = (map['examples'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } else {
        examplesList = [map['examples'].toString()];
      }
    }

    return WordFormationItem(
      baseWord: map['baseWord']?.toString() ?? '',
      relatedForms: relatedFormsList,
      examples: examplesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseWord': baseWord,
      'relatedForms': relatedForms,
      'examples': examples,
    };
  }
}

class WordPatternItem {
  final String category; // adjective, verb, noun
  final String pattern;
  final String example;

  WordPatternItem({
    required this.category,
    required this.pattern,
    required this.example,
  });

  factory WordPatternItem.fromMap(Map<String, dynamic> map) {
    return WordPatternItem(
      category: map['category']?.toString() ?? '',
      pattern: map['pattern']?.toString() ?? '',
      example: map['example']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'pattern': pattern,
      'example': example,
    };
  }
}

class VocabularyContent {
  final List<TopicVocabularyItem>? topicVocabulary;
  final List<PhrasalVerbItem>? phrasalVerbs;
  final List<PrepositionalPhraseItem>? prepositionalPhrases;
  final List<WordFormationItem>? wordFormation;
  final List<WordPatternItem>? wordPatterns;

  VocabularyContent({
    this.topicVocabulary,
    this.phrasalVerbs,
    this.prepositionalPhrases,
    this.wordFormation,
    this.wordPatterns,
  });

  factory VocabularyContent.fromMap(Map<String, dynamic>? map) {
    if (map == null) return VocabularyContent();

    List<TopicVocabularyItem>? topicVocabularyList;
    if (map['topicVocabulary'] != null) {
      topicVocabularyList = (map['topicVocabulary'] as List<dynamic>)
          .map((e) => TopicVocabularyItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    List<PhrasalVerbItem>? phrasalVerbsList;
    if (map['phrasalVerbs'] != null) {
      phrasalVerbsList = (map['phrasalVerbs'] as List<dynamic>)
          .map((e) => PhrasalVerbItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    List<PrepositionalPhraseItem>? prepositionalPhrasesList;
    if (map['prepositionalPhrases'] != null) {
      prepositionalPhrasesList = (map['prepositionalPhrases'] as List<dynamic>)
          .map((e) => PrepositionalPhraseItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    List<WordFormationItem>? wordFormationList;
    if (map['wordFormation'] != null) {
      wordFormationList = (map['wordFormation'] as List<dynamic>)
          .map((e) => WordFormationItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    List<WordPatternItem>? wordPatternsList;
    if (map['wordPatterns'] != null) {
      wordPatternsList = (map['wordPatterns'] as List<dynamic>)
          .map((e) => WordPatternItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return VocabularyContent(
      topicVocabulary: topicVocabularyList,
      phrasalVerbs: phrasalVerbsList,
      prepositionalPhrases: prepositionalPhrasesList,
      wordFormation: wordFormationList,
      wordPatterns: wordPatternsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (topicVocabulary != null)
        'topicVocabulary': topicVocabulary!.map((e) => e.toMap()).toList(),
      if (phrasalVerbs != null)
        'phrasalVerbs': phrasalVerbs!.map((e) => e.toMap()).toList(),
      if (prepositionalPhrases != null)
        'prepositionalPhrases':
            prepositionalPhrases!.map((e) => e.toMap()).toList(),
      if (wordFormation != null)
        'wordFormation': wordFormation!.map((e) => e.toMap()).toList(),
      if (wordPatterns != null)
        'wordPatterns': wordPatterns!.map((e) => e.toMap()).toList(),
    };
  }
}

enum LessonType {
  grammar,
  vocabulary,
  listening,
  speaking,
  reading,
  writing;

  static LessonType fromString(String value) {
    return LessonType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => LessonType.grammar,
    );
  }

  @override
  String toString() {
    return name;
  }
}


