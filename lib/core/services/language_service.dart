import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  // Get current language from SharedPreferences
  static Future<Locale> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en'; // Default to English
    return Locale(languageCode);
  }

  // Save selected language
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Get language name
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      case 'hi':
        return 'हिन्दी';
      default:
        return 'English';
    }
  }

  // Get language flag emoji (for UI)
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'vi':
        return '🇻🇳';
      case 'ko':
        return '🇰🇷';
      case 'ja':
        return '🇯🇵';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'zh':
        return '🇨🇳';
      case 'ru':
        return '🇷🇺';
      case 'es':
        return '🇪🇸';
      case 'pt':
        return '🇵🇹';
      case 'hi':
        return '🇮🇳';
      default:
        return '🇬🇧';
    }
  }
}

