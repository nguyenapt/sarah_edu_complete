/// Helper class để xử lý multi-language content từ Firestore
class MultilanguageContent {
  /// Get text theo language code, fallback về English nếu không có
  static String getText(
    Map<String, dynamic>? content,
    String languageCode, {
    String? fallbackLanguage,
  }) {
    if (content == null) return '';

    // Try current language
    if (content[languageCode] != null) {
      return content[languageCode].toString();
    }

    // Try fallback language (default: English)
    final fbLang = fallbackLanguage ?? 'en';
    if (content[fbLang] != null) {
      return content[fbLang].toString();
    }

    // Try Vietnamese as second fallback
    if (content['vi'] != null) {
      return content['vi'].toString();
    }

    // Return first available value
    if (content.isNotEmpty) {
      return content.values.first.toString();
    }

    return '';
  }

  /// Get text với multiple fallbacks
  static String getTextWithFallbacks(
    Map<String, dynamic>? content,
    String languageCode,
    List<String> fallbackLanguages,
  ) {
    if (content == null) return '';

    // Try current language
    if (content[languageCode] != null) {
      return content[languageCode].toString();
    }

    // Try fallback languages in order
    for (final lang in fallbackLanguages) {
      if (content[lang] != null) {
        return content[lang].toString();
      }
    }

    // Return first available value
    if (content.isNotEmpty) {
      return content.values.first.toString();
    }

    return '';
  }

  /// Check if content has translation for language
  static bool hasTranslation(Map<String, dynamic>? content, String languageCode) {
    if (content == null) return false;
    return content.containsKey(languageCode) && content[languageCode] != null;
  }

  /// Get all available languages in content
  static List<String> getAvailableLanguages(Map<String, dynamic>? content) {
    if (content == null) return [];
    return content.keys.toList();
  }
}

