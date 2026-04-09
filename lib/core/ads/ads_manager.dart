import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_policy.dart';
import 'ads_factory.dart';
import 'platform/ad_platform_gate.dart';

class AdsManager {
  AdsManager({
    required AdsFactory factory,
    required AdPolicy policy,
  })  : _factory = factory,
        _policy = policy;

  final AdsFactory _factory;
  final AdPolicy _policy;

  bool _initialized = false;
  InterstitialAd? _interstitial;
  AppOpenAd? _appOpen;
  RewardedAd? _rewarded;

  bool get adsSupported => AdPlatformGate.adsSupported;

  Future<void> init() async {
    if (!adsSupported) return;
    if (_initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // Keep app stable if plugin isn't available.
    }
    unawaited(preloadInterstitial());
    unawaited(preloadAppOpen());
    unawaited(preloadRewarded());
  }

  void onRouteChanged(Route<dynamic>? route) {
    final name = route?.settings.name ?? route?.runtimeType.toString();
    _policy.setCurrentRouteName(name);
  }

  Future<void> preloadInterstitial() async {
    if (!adsSupported) return;
    if (_interstitial != null) return;
    final ad = await _factory
        .createInterstitialLoader(adUnitId: _factory.interstitialBreakUnitId)
        .load();
    if (ad == null) {
      debugPrint('AdsManager: interstitial not ready, will retry in 25s');
      Future<void>.delayed(const Duration(seconds: 25), () {
        if (_interstitial != null || !adsSupported) return;
        unawaited(preloadInterstitial());
      });
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        unawaited(preloadInterstitial());
      },
    );
    _interstitial = ad;
  }

  Future<void> maybeShowInterstitial(AdEvent event) async {
    if (!adsSupported) return;
    if (!_policy.canShowInterstitial(event)) return;
    final ad = _interstitial;
    if (ad == null) {
      unawaited(preloadInterstitial());
      return;
    }
    _policy.markInterstitialShown();
    _interstitial = null;
    await ad.show();
  }

  Future<void> preloadAppOpen() async {
    if (!adsSupported) return;
    if (_appOpen != null) return;
    final ad = await _factory
        .createAppOpenLoader(adUnitId: _factory.appOpenUnitId)
        .load();
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpen = null;
        unawaited(preloadAppOpen());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _appOpen = null;
        unawaited(preloadAppOpen());
      },
    );
    _appOpen = ad;
  }

  Future<void> preloadRewarded() async {
    if (!adsSupported) return;
    if (_rewarded != null) return;
    final ad =
        await _factory.createRewardedLoader(adUnitId: _factory.rewardedUnitId).load();
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        unawaited(preloadRewarded());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        unawaited(preloadRewarded());
      },
    );
    _rewarded = ad;
  }

  /// Rewarded ad show helper. Returns true if ad shown.
  Future<bool> maybeShowRewarded({
    required void Function(RewardItem reward) onUserEarnedReward,
  }) async {
    if (!adsSupported) return false;
    final ad = _rewarded;
    if (ad == null) {
      unawaited(preloadRewarded());
      return false;
    }
    _rewarded = null;
    await ad.show(onUserEarnedReward: (ad, reward) {
      onUserEarnedReward(reward);
    });
    return true;
  }

  /// Cold start only: call once after first frame.
  Future<void> maybeShowAppOpen() async {
    if (!adsSupported) return;
    if (!_policy.canShowAppOpen()) return;
    final ad = _appOpen;
    if (ad == null) {
      unawaited(preloadAppOpen());
      return;
    }
    _policy.markAppOpenShown();
    _appOpen = null;
    await ad.show();
  }
}

