import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Centralized AdMob IDs configuration.
///
/// - Debug/Profile: uses Google test ad unit ids.
/// - Release: uses your production ids (fill in below).
///
/// NOTE: Ads are gated elsewhere (web disabled).
class AdMobIds {
  /// Optionally set via build-time flag:
  /// `--dart-define=ADS_TEST=true`
  static const bool _adsTestFromDefine =
      bool.fromEnvironment('ADS_TEST', defaultValue: false);

  static bool get useTestIds => kDebugMode || _adsTestFromDefine;

  static bool _isPlaceholder(String id) =>
      id.isEmpty || id.startsWith('YOUR_') || id.contains('YOUR_');

  static String _pickUnitId({
    required String testId,
    required String androidProd,
    required String iosProd,
  }) {
    if (useTestIds) return testId;
    final prod = byPlatform(android: androidProd, ios: iosProd);
    // Safety: nếu chưa điền prod ids mà build release, fallback sang test để tránh "không thấy ads".
    if (_isPlaceholder(prod)) return testId;
    return prod;
  }

  /// Android/iOS AdMob App IDs (for manifest/plist).
  /// These are NOT ad unit ids.
  static String get appIdAndroid => useTestIds
      ? 'ca-app-pub-3414812429495926~5132623977'
      : 'YOUR_ANDROID_ADMOB_APP_ID';

  static String get appIdIOS => useTestIds
      ? 'ca-app-pub-3940256099942544~1458002511'
      : 'YOUR_IOS_ADMOB_APP_ID';

  static String get bannerHome => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/6300978111',
        androidProd: 'ca-app-pub-3414812429495926/8379500773',
        iosProd: 'YOUR_IOS_BANNER_HOME',
      );

  static String get nativeHome => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/2247696110',
        androidProd: 'ca-app-pub-3414812429495926/2171418715',
        iosProd: 'YOUR_IOS_NATIVE_HOME',
      );

  static String get nativePractice => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/2247696110',
        androidProd: 'ca-app-pub-3414812429495926/2171418715',
        iosProd: 'YOUR_IOS_NATIVE_PRACTICE',
      );

  static String get nativeVocabList => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/2247696110',
        androidProd: 'ca-app-pub-3414812429495926/2171418715',
        iosProd: 'YOUR_IOS_NATIVE_VOCAB_LIST',
      );

  static String get interstitialBreak => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/1033173712',
        androidProd: 'ca-app-pub-3414812429495926/1616884943',
        iosProd: 'YOUR_IOS_INTERSTITIAL_BREAK',
      );

  static String get appOpen => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/3419835294',
        androidProd: 'ca-app-pub-3414812429495926/1019885509',
        iosProd: 'YOUR_IOS_APP_OPEN',
      );

  static String get rewarded => _pickUnitId(
        testId: 'ca-app-pub-3940256099942544/5224354917',
        androidProd: 'ca-app-pub-3414812429495926/9303803274',
        iosProd: 'YOUR_IOS_REWARDED',
      );

  static String byPlatform({
    required String android,
    required String ios,
  }) {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    // Fallback to android id for non-mobile platforms (should be gated out).
    return android;
  }
}

