import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/placement_test_model.dart';

class PlacementStorageService {
  static const String _keyPlacementTestResult = 'placement_test_result';

  /// Lưu kết quả placement test vào local storage (cho guest user)
  static Future<void> savePlacementTestResult(PlacementTestResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultJson = jsonEncode(result.toMap());
      await prefs.setString(_keyPlacementTestResult, resultJson);
    } catch (e) {
      throw Exception('Error saving placement test result: $e');
    }
  }

  /// Load kết quả placement test từ local storage
  static Future<PlacementTestResult?> loadPlacementTestResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultJson = prefs.getString(_keyPlacementTestResult);
      
      if (resultJson == null) return null;
      
      final resultMap = jsonDecode(resultJson) as Map<String, dynamic>;
      return PlacementTestResult.fromMap(resultMap);
    } catch (e) {
      return null;
    }
  }

  /// Xóa kết quả placement test từ local storage (sau khi sync lên Firestore)
  static Future<void> clearPlacementTestResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPlacementTestResult);
    } catch (e) {
      // Ignore error
    }
  }

  /// Kiểm tra xem có kết quả placement test trong local storage không
  static Future<bool> hasPlacementTestResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyPlacementTestResult);
    } catch (e) {
      return false;
    }
  }
}

