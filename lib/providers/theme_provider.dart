import 'package:flutter/material.dart';
import '../core/services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final themeModeString = await ThemeService.getCurrentThemeMode();
      _themeMode = ThemeService.stringToThemeMode(themeModeString);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.system;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(String mode) async {
    final newThemeMode = ThemeService.stringToThemeMode(mode);
    if (_themeMode == newThemeMode) return;

    await ThemeService.setThemeMode(mode);
    _themeMode = newThemeMode;
    notifyListeners();
  }

  String get currentThemeModeString => ThemeService.themeModeToString(_themeMode);
}


