import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AdPlatformGate {
  static bool get adsSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

