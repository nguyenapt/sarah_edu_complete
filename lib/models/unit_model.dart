import 'multilanguage_content.dart';

class UnitModel {
  final String id;
  final String levelId;
  final Map<String, dynamic>? title; // Multi-language: Map<String, String>
  final Map<String, dynamic>? description; // Multi-language: Map<String, String>
  final int order;
  final int estimatedTime; // minutes
  final List<String> lessons;
  final List<String> prerequisites; // Unit IDs cần hoàn thành trước

  UnitModel({
    required this.id,
    required this.levelId,
    this.title,
    this.description,
    required this.order,
    required this.estimatedTime,
    this.lessons = const [],
    this.prerequisites = const [],
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    return MultilanguageContent.getText(title, languageCode);
  }

  /// Get description theo language code
  String getDescription(String languageCode) {
    return MultilanguageContent.getText(description, languageCode);
  }

  factory UnitModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Hỗ trợ cả String (backward compatible) và Map<String, String> (multi-language)
    Map<String, dynamic>? titleData;
    if (data['title'] != null) {
      if (data['title'] is Map) {
        titleData = data['title'] as Map<String, dynamic>;
      } else {
        titleData = {'en': data['title'].toString()};
      }
    }

    Map<String, dynamic>? descriptionData;
    if (data['description'] != null) {
      if (data['description'] is Map) {
        descriptionData = data['description'] as Map<String, dynamic>;
      } else {
        descriptionData = {'en': data['description'].toString()};
      }
    }

    return UnitModel(
      id: id,
      levelId: data['levelId'] ?? '',
      title: titleData,
      description: descriptionData,
      order: data['order'] ?? 0,
      estimatedTime: data['estimatedTime'] ?? 0,
      lessons: List<String>.from(data['lessons'] ?? []),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'levelId': levelId,
      'title': title,
      'description': description,
      'order': order,
      'estimatedTime': estimatedTime,
      'lessons': lessons,
      'prerequisites': prerequisites,
    };
  }
}


