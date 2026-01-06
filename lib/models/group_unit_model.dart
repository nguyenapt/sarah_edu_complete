import 'multilanguage_content.dart';

class GroupUnitModel {
  final String id; // "A1_1_3"
  final int index;
  final String levelId;
  final int next;
  final int previous;
  final Map<String, dynamic>? title; // Multi-language: Map<String, String> (HTML formatted)
  final List<String> units; // ["unit_a1_1", "unit_a1_2", ...]

  GroupUnitModel({
    required this.id,
    required this.index,
    required this.levelId,
    required this.next,
    required this.previous,
    this.title,
    this.units = const [],
  });

  /// Get title theo language code
  String getTitle(String languageCode) {
    return MultilanguageContent.getText(title, languageCode);
  }

  factory GroupUnitModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Hỗ trợ cả String (backward compatible) và Map<String, String> (multi-language)
    Map<String, dynamic>? titleData;
    if (data['title'] != null) {
      if (data['title'] is Map) {
        titleData = data['title'] as Map<String, dynamic>;
      } else {
        titleData = {'en': data['title'].toString()};
      }
    }

    return GroupUnitModel(
      id: id,
      index: data['index'] ?? 0,
      levelId: data['levelId'] ?? '',
      next: data['next'] ?? 0,
      previous: data['previous'] ?? 0,
      title: titleData,
      units: List<String>.from(data['units'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'index': index,
      'levelId': levelId,
      'next': next,
      'previous': previous,
      'title': title,
      'units': units,
    };
  }
}

