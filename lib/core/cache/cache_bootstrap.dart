import 'hive_cache_store.dart';

class CacheBootstrap {
  static Future<void> init() async {
    await HiveCacheStore.init();
  }
}

