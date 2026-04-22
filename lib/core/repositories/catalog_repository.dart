import 'package:flutter/foundation.dart';

import '../../models/exercise_model.dart';
import '../../models/lesson_model.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../cache/cache_policy.dart';
import '../cache/hive_cache_store.dart';
import '../cache/cache_metrics.dart';
import '../services/firestore_service.dart';
import '../services/unit_group_service.dart';

/// Catalog = data ít thay đổi: levels/units/lessons/exercises.
/// Áp dụng stale-while-revalidate: trả cache nhanh, refresh nền.
class CatalogRepository {
  CatalogRepository({
    FirestoreService? firestore,
    CachePolicy policy = CachePolicy.defaultPolicy,
  })  : _firestore = firestore ?? FirestoreService(),
        _policy = policy;

  final FirestoreService _firestore;
  final CachePolicy _policy;

  List<LevelModel>? _levelsAll;
  List<UnitModel>? _unitsAll;
  final Map<String, UnitModel> _unitById = {};
  final Map<String, LessonModel> _lessonById = {};
  final Map<String, List<LessonModel>> _lessonsByUnitId = {};
  final Map<String, List<ExerciseModel>> _exercisesByLessonId = {};

  static const _kLevelsAll = 'catalog_levels_all';
  static const _kUnitsAll = 'catalog_units_all';
  static String _kLessonsByUnit(String unitId) => 'catalog_lessons_by_unit__$unitId';
  static String _kLesson(String lessonId) => 'catalog_lesson__$lessonId';
  static String _kUnit(String unitId) => 'catalog_unit__$unitId';
  static String _kExercisesByLesson(String lessonId) =>
      'catalog_exercises_by_lesson__$lessonId';

  Future<List<LevelModel>> getLevels({
    void Function(List<LevelModel> fresh)? onFresh,
  }) async {
    final mem = _levelsAll;
    if (mem != null && mem.isNotEmpty) {
      CacheMetrics.catalogMemoryHits++;
      _refreshLevelsIfNeeded(onFresh);
      return mem;
    }

    final cached = _readLevelsFromDisk();
    if (cached != null && cached.isNotEmpty) {
      CacheMetrics.catalogDiskHits++;
      _levelsAll = cached;
      _refreshLevelsIfNeeded(onFresh);
      return cached;
    }

    CacheMetrics.catalogNetworkFetches++;
    final fresh = await _firestore.getLevels();
    _levelsAll = fresh;
    await _writeLevelsToDisk(fresh);
    return fresh;
  }

  void _refreshLevelsIfNeeded(void Function(List<LevelModel> fresh)? onFresh) {
    final fetchedAt = HiveCacheStore.getFetchedAt(_kLevelsAll);
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore.getLevels().then((fresh) async {
      _levelsAll = fresh;
      await _writeLevelsToDisk(fresh);
      if (onFresh != null) onFresh(fresh);
      debugPrint('CatalogRepository: refreshed levels');
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh levels failed: $e');
    });
  }

  List<LevelModel>? _readLevelsFromDisk() {
    return HiveCacheStore.getJson<List<LevelModel>>(
      _kLevelsAll,
      decode: (json) {
        final list = (json as List).cast<Map>();
        return list
            .map((m) => LevelModel.fromFirestore(
                  Map<String, dynamic>.from(m['data'] as Map),
                  m['id'] as String,
                ))
            .toList();
      },
    );
  }

  Future<void> _writeLevelsToDisk(List<LevelModel> levels) async {
    final json = levels
        .map((l) => {
              'id': l.id,
              'data': l.toFirestore(),
            })
        .toList();
    await HiveCacheStore.putJson(_kLevelsAll, json: json);
  }

  Future<List<UnitModel>> getAllUnits({
    void Function(List<UnitModel> fresh)? onFresh,
  }) async {
    final mem = _unitsAll;
    if (mem != null && mem.isNotEmpty) {
      CacheMetrics.catalogMemoryHits++;
      _refreshUnitsIfNeeded(onFresh);
      return mem;
    }
    final cached = _readUnitsFromDisk();
    if (cached != null && cached.isNotEmpty) {
      CacheMetrics.catalogDiskHits++;
      _unitsAll = cached;
      for (final u in cached) {
        _unitById[u.id] = u;
      }
      _refreshUnitsIfNeeded(onFresh);
      return cached;
    }
    CacheMetrics.catalogNetworkFetches++;
    final fresh = await _firestore.getAllUnits();
    _unitsAll = fresh;
    for (final u in fresh) {
      _unitById[u.id] = u;
    }
    await _writeUnitsToDisk(fresh);
    return fresh;
  }

  void _refreshUnitsIfNeeded(void Function(List<UnitModel> fresh)? onFresh) {
    final fetchedAt = HiveCacheStore.getFetchedAt(_kUnitsAll);
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore.getAllUnits().then((fresh) async {
      _unitsAll = fresh;
      for (final u in fresh) {
        _unitById[u.id] = u;
      }
      await _writeUnitsToDisk(fresh);
      if (onFresh != null) onFresh(fresh);
      debugPrint('CatalogRepository: refreshed units');
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh units failed: $e');
    });
  }

  List<UnitModel>? _readUnitsFromDisk() {
    return HiveCacheStore.getJson<List<UnitModel>>(
      _kUnitsAll,
      decode: (json) {
        final list = (json as List).cast<Map>();
        return list
            .map((m) => UnitModel.fromFirestore(
                  Map<String, dynamic>.from(m['data'] as Map),
                  m['id'] as String,
                ))
            .toList();
      },
    );
  }

  Future<void> _writeUnitsToDisk(List<UnitModel> units) async {
    final json = units
        .map((u) => {
              'id': u.id,
              'data': u.toFirestore(),
            })
        .toList();
    await HiveCacheStore.putJson(_kUnitsAll, json: json);
  }

  Future<UnitModel?> getUnit(
    String unitId, {
    void Function(UnitModel? fresh)? onFresh,
  }) async {
    final mem = _unitById[unitId];
    if (mem != null) {
      CacheMetrics.catalogMemoryHits++;
      _refreshUnitIfNeeded(unitId, onFresh);
      return mem;
    }
    final cached = HiveCacheStore.getJson<UnitModel>(
      _kUnit(unitId),
      decode: (json) => UnitModel.fromFirestore(
        Map<String, dynamic>.from(json as Map),
        unitId,
      ),
    );
    if (cached != null) {
      CacheMetrics.catalogDiskHits++;
      _unitById[unitId] = cached;
      _refreshUnitIfNeeded(unitId, onFresh);
      return cached;
    }
    CacheMetrics.catalogNetworkFetches++;
    final fresh = await _firestore.getUnit(unitId);
    if (fresh != null) {
      _unitById[unitId] = fresh;
      await HiveCacheStore.putJson(_kUnit(unitId), json: fresh.toFirestore());
    }
    return fresh;
  }

  void _refreshUnitIfNeeded(
    String unitId,
    void Function(UnitModel? fresh)? onFresh,
  ) {
    final fetchedAt = HiveCacheStore.getFetchedAt(_kUnit(unitId));
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore.getUnit(unitId).then((fresh) async {
      if (fresh != null) {
        _unitById[unitId] = fresh;
        await HiveCacheStore.putJson(_kUnit(unitId), json: fresh.toFirestore());
      }
      if (onFresh != null) onFresh(fresh);
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh unit failed: $e');
    });
  }

  Future<List<LessonModel>> getLessonsByUnit(
    String unitId, {
    void Function(List<LessonModel> fresh)? onFresh,
  }) async {
    final mem = _lessonsByUnitId[unitId];
    if (mem != null && mem.isNotEmpty) {
      CacheMetrics.catalogMemoryHits++;
      _refreshLessonsByUnitIfNeeded(unitId, onFresh);
      return mem;
    }
    final cached = HiveCacheStore.getJson<List<LessonModel>>(
      _kLessonsByUnit(unitId),
      decode: (json) {
        final list = (json as List).cast<Map>();
        return list
            .map((m) => LessonModel.fromFirestore(
                  Map<String, dynamic>.from(m['data'] as Map),
                  m['id'] as String,
                ))
            .toList();
      },
    );
    if (cached != null && cached.isNotEmpty) {
      CacheMetrics.catalogDiskHits++;
      _lessonsByUnitId[unitId] = cached;
      for (final l in cached) {
        _lessonById[l.id] = l;
      }
      _refreshLessonsByUnitIfNeeded(unitId, onFresh);
      return cached;
    }
    CacheMetrics.catalogNetworkFetches++;
    final fresh = await _firestore.getLessonsByUnit(unitId);
    _lessonsByUnitId[unitId] = fresh;
    for (final l in fresh) {
      _lessonById[l.id] = l;
    }
    await _writeLessonsByUnitToDisk(unitId, fresh);
    return fresh;
  }

  void _refreshLessonsByUnitIfNeeded(
    String unitId,
    void Function(List<LessonModel> fresh)? onFresh,
  ) {
    final key = _kLessonsByUnit(unitId);
    final fetchedAt = HiveCacheStore.getFetchedAt(key);
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore.getLessonsByUnit(unitId).then((fresh) async {
      _lessonsByUnitId[unitId] = fresh;
      for (final l in fresh) {
        _lessonById[l.id] = l;
      }
      await _writeLessonsByUnitToDisk(unitId, fresh);
      if (onFresh != null) onFresh(fresh);
      debugPrint('CatalogRepository: refreshed lessonsByUnit($unitId)');
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh lessonsByUnit failed: $e');
    });
  }

  Future<void> _writeLessonsByUnitToDisk(
    String unitId,
    List<LessonModel> lessons,
  ) async {
    final json = lessons
        .map((l) => {
              'id': l.id,
              'data': l.toFirestore(),
            })
        .toList();
    await HiveCacheStore.putJson(_kLessonsByUnit(unitId), json: json);
  }

  Future<LessonModel?> getLesson(
    String lessonId, {
    void Function(LessonModel? fresh)? onFresh,
  }) async {
    final mem = _lessonById[lessonId];
    if (mem != null) {
      CacheMetrics.catalogMemoryHits++;
      _refreshLessonIfNeeded(lessonId, onFresh);
      return mem;
    }
    final cached = HiveCacheStore.getJson<LessonModel>(
      _kLesson(lessonId),
      decode: (json) => LessonModel.fromFirestore(
        Map<String, dynamic>.from(json as Map),
        lessonId,
      ),
    );
    if (cached != null) {
      CacheMetrics.catalogDiskHits++;
      _lessonById[lessonId] = cached;
      _refreshLessonIfNeeded(lessonId, onFresh);
      return cached;
    }
    CacheMetrics.catalogNetworkFetches++;
    final fresh = await _firestore.getLesson(lessonId);
    if (fresh != null) {
      _lessonById[lessonId] = fresh;
      await HiveCacheStore.putJson(_kLesson(lessonId), json: fresh.toFirestore());
    }
    return fresh;
  }

  void _refreshLessonIfNeeded(
    String lessonId,
    void Function(LessonModel? fresh)? onFresh,
  ) {
    final key = _kLesson(lessonId);
    final fetchedAt = HiveCacheStore.getFetchedAt(key);
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore.getLesson(lessonId).then((fresh) async {
      if (fresh != null) {
        _lessonById[lessonId] = fresh;
        await HiveCacheStore.putJson(key, json: fresh.toFirestore());
      }
      if (onFresh != null) onFresh(fresh);
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh lesson failed: $e');
    });
  }

  Future<List<ExerciseModel>> getExercisesByLesson(
    String lessonId, {
    String? languageCode,
    void Function(List<ExerciseModel> fresh)? onFresh,
  }) async {
    final mem = _exercisesByLessonId[lessonId];
    if (mem != null && mem.isNotEmpty) {
      CacheMetrics.catalogMemoryHits++;
      _refreshExercisesByLessonIfNeeded(lessonId, languageCode, onFresh);
      return mem;
    }
    final cached = HiveCacheStore.getJson<List<ExerciseModel>>(
      _kExercisesByLesson(lessonId),
      decode: (json) {
        final list = (json as List).whereType<Map>().toList();
        return list
            .map((m) {
              final rawData = m['data'];
              final data = rawData is Map
                  ? rawData.map((k, v) => MapEntry(k.toString(), v))
                  : <String, dynamic>{};
              return ExerciseModel.fromFirestore(
                data,
                (m['id'] ?? '').toString(),
                languageCode: languageCode,
              );
            })
            .toList();
      },
    );
    if (cached != null && cached.isNotEmpty) {
      CacheMetrics.catalogDiskHits++;
      _exercisesByLessonId[lessonId] = cached;
      _refreshExercisesByLessonIfNeeded(lessonId, languageCode, onFresh);
      return cached;
    }
    CacheMetrics.catalogNetworkFetches++;
    final fresh =
        await _firestore.getExercisesByLesson(lessonId, languageCode: languageCode);
    _exercisesByLessonId[lessonId] = fresh;
    await _writeExercisesByLessonToDisk(lessonId, fresh);
    return fresh;
  }

  void _refreshExercisesByLessonIfNeeded(
    String lessonId,
    String? languageCode,
    void Function(List<ExerciseModel> fresh)? onFresh,
  ) {
    final key = _kExercisesByLesson(lessonId);
    final fetchedAt = HiveCacheStore.getFetchedAt(key);
    final isFresh = fetchedAt != null &&
        _policy.isFresh(fetchedAt: fetchedAt, ttl: _policy.catalogTtl);
    if (isFresh) return;
    _firestore
        .getExercisesByLesson(lessonId, languageCode: languageCode)
        .then((fresh) async {
      _exercisesByLessonId[lessonId] = fresh;
      await _writeExercisesByLessonToDisk(lessonId, fresh);
      if (onFresh != null) onFresh(fresh);
      debugPrint('CatalogRepository: refreshed exercisesByLesson($lessonId)');
    }).catchError((e) {
      debugPrint('CatalogRepository: refresh exercisesByLesson failed: $e');
    });
  }

  Future<void> _writeExercisesByLessonToDisk(
    String lessonId,
    List<ExerciseModel> exercises,
  ) async {
    final json = exercises
        .map((e) => {
              'id': e.id,
              'data': e.toFirestore(),
            })
        .toList();
    await HiveCacheStore.putJson(_kExercisesByLesson(lessonId), json: json);
  }

  Future<List<ExerciseModel>> getExercisesByUnit(
    String unitId, {
    String? languageCode,
  }) async {
    final lessons = await getLessonsByUnit(unitId);
    if (lessons.isEmpty) {
      final fallback =
          await _firestore.getExercisesByUnits([unitId], languageCode: languageCode);
      fallback.sort((a, b) => UnitGroupService.compareExerciseIds(a.id, b.id));
      return fallback;
    }

    final lessonOrderById = <String, int>{};
    final allExercises = <ExerciseModel>[];

    for (final lesson in lessons) {
      lessonOrderById[lesson.id] = lesson.order;
      final lessonExercises = await getExercisesByLesson(
        lesson.id,
        languageCode: languageCode,
      );
      allExercises.addAll(lessonExercises);
    }

    allExercises.sort((a, b) {
      final aLessonOrder = lessonOrderById[a.lessonId] ?? 1 << 20;
      final bLessonOrder = lessonOrderById[b.lessonId] ?? 1 << 20;
      if (aLessonOrder != bLessonOrder) {
        return aLessonOrder.compareTo(bLessonOrder);
      }
      return UnitGroupService.compareExerciseIds(a.id, b.id);
    });

    return allExercises;
  }
}

