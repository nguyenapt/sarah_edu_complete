import 'multilanguage_content.dart';

class TheoryContent {
  final Map<String, dynamic>? title; // Multi-language: Map<String, String>
  final Map<String, dynamic>? description; // Multi-language: Map<String, String>
  final List<Example> examples;
  final Map<String, dynamic>? usage; // Multi-language: Map<String, String>
  final GrammarForms? forms;

  TheoryContent({
    this.title,
    this.description,
    this.examples = const [],
    this.usage,
    this.forms,
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    return MultilanguageContent.getText(title, languageCode);
  }

  /// Get description theo language code
  String getDescription(String languageCode) {
    return MultilanguageContent.getText(description, languageCode);
  }

  /// Get usage theo language code
  String getUsage(String languageCode) {
    return MultilanguageContent.getText(usage, languageCode);
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

    Map<String, dynamic>? usageData;
    if (map['usage'] != null) {
      if (map['usage'] is Map) {
        usageData = map['usage'] as Map<String, dynamic>;
      } else {
        usageData = {'en': map['usage'].toString()};
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'examples': examples.map((e) => e.toMap()).toList(),
      'usage': usage,
      'forms': forms?.toMap(),
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
  final Map<String, dynamic>? affirmative; // Multi-language: Map<String, String>
  final Map<String, dynamic>? negative; // Multi-language: Map<String, String>
  final Map<String, dynamic>? interrogative; // Multi-language: Map<String, String>

  GrammarForms({
    this.affirmative,
    this.negative,
    this.interrogative,
  });

  /// Get affirmative theo language code
  String getAffirmative(String languageCode) {
    return MultilanguageContent.getText(affirmative, languageCode);
  }

  /// Get negative theo language code
  String getNegative(String languageCode) {
    return MultilanguageContent.getText(negative, languageCode);
  }

  /// Get interrogative theo language code
  String getInterrogative(String languageCode) {
    return MultilanguageContent.getText(interrogative, languageCode);
  }

  factory GrammarForms.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? affirmativeData;
    if (map['affirmative'] != null) {
      if (map['affirmative'] is Map) {
        affirmativeData = map['affirmative'] as Map<String, dynamic>;
      } else {
        affirmativeData = {'en': map['affirmative'].toString()};
      }
    }

    Map<String, dynamic>? negativeData;
    if (map['negative'] != null) {
      if (map['negative'] is Map) {
        negativeData = map['negative'] as Map<String, dynamic>;
      } else {
        negativeData = {'en': map['negative'].toString()};
      }
    }

    Map<String, dynamic>? interrogativeData;
    if (map['interrogative'] != null) {
      if (map['interrogative'] is Map) {
        interrogativeData = map['interrogative'] as Map<String, dynamic>;
      } else {
        interrogativeData = {'en': map['interrogative'].toString()};
      }
    }

    return GrammarForms(
      affirmative: affirmativeData,
      negative: negativeData,
      interrogative: interrogativeData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'affirmative': affirmative,
      'negative': negative,
      'interrogative': interrogative,
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


