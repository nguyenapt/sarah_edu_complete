import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

class AdsFactory {
  BannerAd createBanner({
    required AdSize size,
    required String adUnitId,
    AdRequest? request,
    BannerAdListener? listener,
  }) {
    return BannerAd(
      size: size,
      adUnitId: adUnitId,
      request: request ?? const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }

  InterstitialAdLoader createInterstitialLoader({
    required String adUnitId,
  }) {
    return InterstitialAdLoader(adUnitId: adUnitId);
  }

  AppOpenAdLoader createAppOpenLoader({
    required String adUnitId,
  }) {
    return AppOpenAdLoader(adUnitId: adUnitId);
  }

  RewardedAdLoader createRewardedLoader({
    required String adUnitId,
  }) {
    return RewardedAdLoader(adUnitId: adUnitId);
  }

  String get interstitialBreakUnitId => AdMobIds.interstitialBreak;
  String get appOpenUnitId => AdMobIds.appOpen;
  String get bannerHomeUnitId => AdMobIds.bannerHome;
  String get nativeHomeUnitId => AdMobIds.nativeHome;
  String get nativePracticeUnitId => AdMobIds.nativePractice;
  String get nativeVocabListUnitId => AdMobIds.nativeVocabList;
  String get rewardedUnitId => AdMobIds.rewarded;
}

/// [InterstitialAd.load] trả về [Future<void>] kết thúc khi native nhận lệnh load,
/// *trước* khi [onAdLoaded]/[onAdFailedToLoad] chạy — không được `return ad` sau `await load`.
class InterstitialAdLoader {
  InterstitialAdLoader({required this.adUnitId});
  final String adUnitId;

  Future<InterstitialAd?> load() {
    final completer = Completer<InterstitialAd?>();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loaded) {
          if (!completer.isCompleted) completer.complete(loaded);
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            '❌ Interstitial load failed: code=${err.code} domain=${err.domain} message=${err.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}

class AppOpenAdLoader {
  AppOpenAdLoader({required this.adUnitId});
  final String adUnitId;

  Future<AppOpenAd?> load() {
    final completer = Completer<AppOpenAd?>();
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (loaded) {
          if (!completer.isCompleted) completer.complete(loaded);
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            '❌ AppOpen load failed: code=${err.code} domain=${err.domain} message=${err.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}

class RewardedAdLoader {
  RewardedAdLoader({required this.adUnitId});
  final String adUnitId;

  Future<RewardedAd?> load() {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loaded) {
          if (!completer.isCompleted) completer.complete(loaded);
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            '❌ Rewarded load failed: code=${err.code} domain=${err.domain} message=${err.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}
