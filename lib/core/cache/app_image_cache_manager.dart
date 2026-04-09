import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager extends CacheManager {
  AppImageCacheManager._()
      : super(
          Config(
            'app_image_cache_v1',
            stalePeriod: const Duration(days: 14),
            maxNrOfCacheObjects: 300,
          ),
        );

  static final AppImageCacheManager instance = AppImageCacheManager._();
}

