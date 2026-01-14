import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeModeKey = 'selected_theme_mode';
  
  // Get current theme mode from SharedPreferences
  static Future<String> getCurrentThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString(_themeModeKey) ?? 'system'; // Default to system
    return themeMode;
  }

  // Save selected theme mode
  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  // Convert string to ThemeMode
  static ThemeMode stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // Convert ThemeMode to string
  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}




