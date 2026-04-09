import 'package:flutter/foundation.dart';

class CacheMetrics {
  static int catalogMemoryHits = 0;
  static int catalogDiskHits = 0;
  static int catalogNetworkFetches = 0;

  static int progressMemoryHits = 0;
  static int progressDiskHits = 0;
  static int progressNetworkFetches = 0;

  static void logSummary() {
    debugPrint(
      'CacheMetrics catalog: mem=$catalogMemoryHits disk=$catalogDiskHits net=$catalogNetworkFetches',
    );
    debugPrint(
      'CacheMetrics progress: mem=$progressMemoryHits disk=$progressDiskHits net=$progressNetworkFetches',
    );
  }
}

