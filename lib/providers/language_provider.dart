import 'package:flutter/material.dart';
import '../core/services/language_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English
  bool _isLoading = true;

  Locale get locale => _locale;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      _locale = await LanguageService.getCurrentLanguage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _locale = const Locale('en');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    await LanguageService.setLanguage(languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }

  String get currentLanguageCode => _locale.languageCode;

  List<Map<String, String>> get availableLanguages => [
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
  ];
}

