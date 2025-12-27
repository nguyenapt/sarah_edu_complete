import 'package:shared_preferences/shared_preferences.dart';

class WelcomeService {
  static const String _keyHasSeenWelcome = 'has_seen_welcome';

  /// Kiểm tra xem user đã xem welcome screens chưa
  static Future<bool> hasSeenWelcome() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenWelcome) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Đánh dấu user đã xem welcome screens
  static Future<void> setHasSeenWelcome(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenWelcome, value);
    } catch (e) {
      // Ignore error
    }
  }

  /// Reset welcome status (dùng cho testing)
  static Future<void> resetWelcomeStatus() async {
    await setHasSeenWelcome(false);
  }
}

