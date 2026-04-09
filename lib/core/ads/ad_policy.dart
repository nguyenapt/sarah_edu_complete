enum AdEvent {
  /// After finishing an exercise/lesson flow (natural break).
  exerciseCompleted,

  /// When user is on placement test result and leaving (natural break).
  placementResultLeaving,
}

class AdPolicy {
  AdPolicy({
    required Duration minInterstitialInterval,
  }) : _minInterstitialInterval = minInterstitialInterval;

  final Duration _minInterstitialInterval;

  String? _currentRouteName;
  DateTime? _lastInterstitialAt;
  bool _appOpenShownThisColdStart = false;

  void setCurrentRouteName(String? routeName) {
    _currentRouteName = routeName;
  }

  void markInterstitialShown() {
    _lastInterstitialAt = DateTime.now();
  }

  void markAppOpenShown() {
    _appOpenShownThisColdStart = true;
  }

  bool get appOpenAlreadyShown => _appOpenShownThisColdStart;

  bool get isNoAdsZone {
    final name = _currentRouteName ?? '';
    if (name.contains('Welcome')) return true;
    if (name.contains('Login') || name.contains('Register')) return true;
    if (name.contains('PlacementTestScreen')) return true;
    if (name.contains('ExerciseScreen')) return true;
    return false;
  }

  bool canShowInterstitial(AdEvent event) {
    if (isNoAdsZone) return false;
    final last = _lastInterstitialAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= _minInterstitialInterval;
  }

  bool canShowAppOpen() {
    if (appOpenAlreadyShown) return false;
    if (isNoAdsZone) return false;
    return true;
  }
}

