import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheStore {
  static const String _boxName = 'app_cache_v1';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static bool get isReady => _box != null;

  static DateTime? getFetchedAt(String key) {
    final box = _box;
    if (box == null) return null;
    final raw = box.get('${key}__meta') as int?;
    if (raw == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true).toLocal();
  }

  static T? getJson<T>(
    String key, {
    required T Function(Object? json) decode,
  }) {
    final box = _box;
    if (box == null) return null;
    final raw = box.get(key) as String?;
    if (raw == null) return null;
    try {
      final jsonObj = jsonDecode(raw);
      return decode(jsonObj);
    } catch (e) {
      debugPrint('HiveCacheStore.getJson decode failed ($key): $e');
      return null;
    }
  }

  static Future<void> putJson(
    String key, {
    required Object json,
  }) async {
    final box = _box;
    if (box == null) return;
    await box.put(key, jsonEncode(json));
    await box.put('${key}__meta', DateTime.now().toUtc().millisecondsSinceEpoch);
  }

  static Future<void> delete(String key) async {
    final box = _box;
    if (box == null) return;
    await box.delete(key);
    await box.delete('${key}__meta');
  }
}

