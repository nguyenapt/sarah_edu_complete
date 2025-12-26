import 'multilanguage_content.dart';

class LevelModel {
  final String id; // A1, A2, B1, B2, C1, C2
  final Map<String, dynamic>? name; // Multi-language: Map<String, String>
  final Map<String, dynamic>? description; // Multi-language: Map<String, String>
  final int order;
  final int totalUnits;
  final int estimatedHours;
  final String? iconUrl;

  LevelModel({
    required this.id,
    this.name,
    this.description,
    required this.order,
    required this.totalUnits,
    required this.estimatedHours,
    this.iconUrl,
  });

  /// Get name theo language code
  String getName(String languageCode) {
    return MultilanguageContent.getText(name, languageCode);
  }

  /// Get description theo language code
  String getDescription(String languageCode) {
    return MultilanguageContent.getText(description, languageCode);
  }

  factory LevelModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Hỗ trợ cả String (backward compatible) và Map<String, String> (multi-language)
    Map<String, dynamic>? nameData;
    if (data['name'] != null) {
      if (data['name'] is Map) {
        nameData = data['name'] as Map<String, dynamic>;
      } else {
        // Convert String to Map với key 'en' (default)
        nameData = {'en': data['name'].toString()};
      }
    }

    Map<String, dynamic>? descriptionData;
    if (data['description'] != null) {
      if (data['description'] is Map) {
        descriptionData = data['description'] as Map<String, dynamic>;
      } else {
        // Convert String to Map với key 'en' (default)
        descriptionData = {'en': data['description'].toString()};
      }
    }

    return LevelModel(
      id: id,
      name: nameData,
      description: descriptionData,
      order: data['order'] ?? 0,
      totalUnits: data['totalUnits'] ?? 0,
      estimatedHours: data['estimatedHours'] ?? 0,
      iconUrl: data['iconUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'order': order,
      'totalUnits': totalUnits,
      'estimatedHours': estimatedHours,
      'iconUrl': iconUrl,
    };
  }
}


