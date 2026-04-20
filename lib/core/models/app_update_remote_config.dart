/// Payload từ Firestore `appSettings/appUpdate`.
///
/// Keys expected (snake_case, theo ảnh):
/// - min_build, latest_build
/// - min_supported_version, latest_version
/// - store_android_url
/// - (optional) store_ios_url
/// - update_title, update_message
class AppUpdateRemoteConfig {
  final int? minBuild;
  final int? latestBuild;
  final String? minSupportedVersion;
  final String? latestVersion;
  final String? storeAndroidUrl;
  final String? storeIosUrl;
  final String? updateTitle;
  final String? updateMessage;

  const AppUpdateRemoteConfig({
    this.minBuild,
    this.latestBuild,
    this.minSupportedVersion,
    this.latestVersion,
    this.storeAndroidUrl,
    this.storeIosUrl,
    this.updateTitle,
    this.updateMessage,
  });

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory AppUpdateRemoteConfig.fromMap(Map<String, dynamic> map) {
    return AppUpdateRemoteConfig(
      minBuild: _parseInt(map['min_build'] ?? map['minBuild']),
      latestBuild: _parseInt(map['latest_build'] ?? map['latestBuild']),
      minSupportedVersion: map['min_supported_version']?.toString() ??
          map['minSupportedVersion']?.toString(),
      latestVersion: map['latest_version']?.toString() ?? map['latestVersion']?.toString(),
      storeAndroidUrl:
          map['store_android_url']?.toString() ?? map['storeAndroidUrl']?.toString(),
      storeIosUrl: map['store_ios_url']?.toString() ?? map['storeIosUrl']?.toString(),
      updateTitle: map['update_title']?.toString() ?? map['updateTitle']?.toString(),
      updateMessage: map['update_message']?.toString() ?? map['updateMessage']?.toString(),
    );
  }
}

enum AppUpdateUrgency { none, optional, forced }

class AppUpdateCheckOutcome {
  final AppUpdateUrgency urgency;
  final AppUpdateRemoteConfig config;

  const AppUpdateCheckOutcome({
    required this.urgency,
    required this.config,
  });

  static const AppUpdateCheckOutcome none = AppUpdateCheckOutcome(
    urgency: AppUpdateUrgency.none,
    config: AppUpdateRemoteConfig(),
  );
}

