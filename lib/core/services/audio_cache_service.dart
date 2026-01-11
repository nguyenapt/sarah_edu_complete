import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioCacheService {
  static const String _cacheDirectoryName = 'audio_cache';
  Directory? _cacheDirectory;

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDocDir.path, _cacheDirectoryName));
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    _cacheDirectory = cacheDir;
    return cacheDir;
  }

  /// Generate cache key from text and voice config
  String generateCacheKey(String text, String voiceConfigString) {
    final combined = '$text|$voiceConfigString';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cached audio if exists
  Future<Uint8List?> getCachedAudio(String cacheKey) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(path.join(cacheDir.path, '$cacheKey.mp3'));
      
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
      
      return null;
    } catch (e) {
      // Cache error, return null to regenerate
      return null;
    }
  }

  /// Save audio to cache
  Future<void> saveAudio(String cacheKey, Uint8List audioBytes) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File(path.join(cacheDir.path, '$cacheKey.mp3'));
      await cacheFile.writeAsBytes(audioBytes);
    } catch (e) {
      // Cache error, ignore (audio will be regenerated next time)
    }
  }

  /// Clear all cached audio
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        _cacheDirectory = null;
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get cache size (optional, for debugging)
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

