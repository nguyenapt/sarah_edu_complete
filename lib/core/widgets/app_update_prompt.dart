import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_update_remote_config.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';

/// Hiển thị dialog nhắc cập nhật dựa trên Firestore `appSettings/appUpdate`.
class AppUpdateCoordinator {
  AppUpdateCoordinator._();

  static bool _dialogShowing = false;
  static DateTime? _lastCheckStarted;

  static const _resumeMinGap = Duration(seconds: 30);
  static const _prefsDismissToken = 'app_update_soft_dismiss_token';

  static String _softDismissToken(AppUpdateRemoteConfig c) {
    return '${c.latestBuild ?? 0}|${c.latestVersion ?? ''}';
  }

  static Future<bool> _shouldSkipOptional(AppUpdateRemoteConfig c) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsDismissToken);
    return saved != null && saved == _softDismissToken(c);
  }

  static Future<void> _saveOptionalDismissed(AppUpdateRemoteConfig c) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsDismissToken, _softDismissToken(c));
  }

  static Widget _updateIcon(BuildContext context) {
    return Icon(
      Icons.system_update_rounded,
      size: 32,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  static String _titleFallback({required TargetPlatform platform}) {
    return platform == TargetPlatform.iOS ? 'Update available' : 'Có bản cập nhật';
  }

  static String _messageFallback({required AppUpdateUrgency urgency}) {
    if (urgency == AppUpdateUrgency.forced) {
      return 'Vui lòng cập nhật để tiếp tục sử dụng ứng dụng.';
    }
    return 'Có phiên bản mới. Bạn nên cập nhật để có trải nghiệm tốt hơn.';
  }

  /// [fromResume]: true khi app quay lại foreground (có throttle nhẹ).
  static Future<void> checkAndPrompt(
    BuildContext context, {
    bool fromResume = false,
  }) async {
    if (kIsWeb) return;
    if (_dialogShowing) return;
    if (!context.mounted) return;
    if (fromResume &&
        _lastCheckStarted != null &&
        DateTime.now().difference(_lastCheckStarted!) < _resumeMinGap) {
      return;
    }
    _lastCheckStarted = DateTime.now();

    final outcome = await AppUpdateService.instance.check(
      bypassCache: fromResume,
    );
    if (!context.mounted) return;
    if (outcome.urgency == AppUpdateUrgency.none) return;

    if (outcome.urgency == AppUpdateUrgency.optional) {
      if (await _shouldSkipOptional(outcome.config)) return;
    }
    if (!context.mounted) return;

    _dialogShowing = true;
    try {
      final titleText = outcome.config.updateTitle?.trim();
      final messageText = outcome.config.updateMessage?.trim();

      if (outcome.urgency == AppUpdateUrgency.forced) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: _updateIcon(ctx),
              title: Text(
                (titleText != null && titleText.isNotEmpty)
                    ? titleText
                    : _titleFallback(platform: defaultTargetPlatform),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                (messageText != null && messageText.isNotEmpty)
                    ? messageText
                    : _messageFallback(urgency: outcome.urgency),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final ok = await AppUpdateService.instance.tryAndroidImmediateUpdate();
                    if (!ctx.mounted) return;
                    if (!ok) {
                      await AppUpdateService.instance.openStore(
                        outcome.config,
                        defaultTargetPlatform,
                      );
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cập nhật ngay'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: _updateIcon(ctx),
              title: Text(
                (titleText != null && titleText.isNotEmpty)
                    ? titleText
                    : _titleFallback(platform: defaultTargetPlatform),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                (messageText != null && messageText.isNotEmpty)
                    ? messageText
                    : _messageFallback(urgency: outcome.urgency),
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _saveOptionalDismissed(outcome.config);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Để sau',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final started = await AppUpdateService.instance.tryAndroidFlexibleUpdate();
                    if (!ctx.mounted) return;
                    if (!started) {
                      await AppUpdateService.instance.openStore(
                        outcome.config,
                        defaultTargetPlatform,
                      );
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cập nhật ngay'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      _dialogShowing = false;
    }
  }
}

