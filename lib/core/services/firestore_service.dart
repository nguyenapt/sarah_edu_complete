import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../models/placement_test_model.dart';
import '../../models/progress_model.dart';
import '../../models/user_model.dart';
import '../../models/level_skip_test_model.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/utils/progress_comparator.dart';
import '../cache/cache_policy.dart';
import '../cache/hive_cache_store.dart';
import '../cache/cache_metrics.dart';
import 'level_progression_service.dart';
import 'stats_service.dart';
import 'group_unit_service.dart';
import 'weak_skill_service.dart';

/// Result của saveExerciseProgress
class SaveExerciseProgressResult {
  final bool levelUp;
  final String? oldLevel;
  final String? newLevel;

  SaveExerciseProgressResult({
    this.levelUp = false,
    this.oldLevel,
    this.newLevel,
  });
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, UserProgressModel> _progressMemCache = {};
  static final Map<String, DateTime> _progressMemFetchedAt = {};
  static const CachePolicy _cachePolicy = CachePolicy.defaultPolicy;

  // Levels
  Future<List<LevelModel>> getLevels() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.levelsCollection)
          .orderBy('order')
          .get();
      
      return snapshot.docs
          .map((doc) => LevelModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching levels: $e');
    }
  }

  Future<LevelModel?> getLevel(String levelId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.levelsCollection)
          .doc(levelId)
          .get();
      
      if (!doc.exists) return null;
      return LevelModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching level: $e');
    }
  }

  // Units
  Future<List<UnitModel>> getUnitsByLevel(String levelId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.unitsCollection)
          .where('levelId', isEqualTo: levelId)
          .orderBy('order')
          .get();
      
      return snapshot.docs
          .map((doc) => UnitModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching units: $e');
    }
  }

  // Get all units sorted by level order and unit order
  // Tối ưu: 1 query thay vì N+1 queries
  Future<List<UnitModel>> getAllUnits() async {
    try {
      // Load tất cả units trong 1 query (không filter theo levelId)
      final snapshot = await _firestore
          .collection(FirebaseConstants.unitsCollection)
          .orderBy('order')
          .get();
      
      final allUnits = snapshot.docs
          .map((doc) => UnitModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Lấy levels để sort theo level order
      final levels = await getLevels();
      final levelOrderMap = <String, int>{};
      for (int i = 0; i < levels.length; i++) {
        levelOrderMap[levels[i].id] = levels[i].order;
      }
      
      // Sort: theo level order trước, sau đó theo unit order
      allUnits.sort((a, b) {
        final aLevelOrder = levelOrderMap[a.levelId] ?? 999;
        final bLevelOrder = levelOrderMap[b.levelId] ?? 999;
        if (aLevelOrder != bLevelOrder) {
          return aLevelOrder.compareTo(bLevelOrder);
        }
        return a.order.compareTo(b.order);
      });
      
      return allUnits;
    } catch (e) {
      throw Exception('Error fetching all units: $e');
    }
  }

  Future<UnitModel?> getUnit(String unitId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.unitsCollection)
          .doc(unitId)
          .get();
      
      if (!doc.exists) return null;
      return UnitModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching unit: $e');
    }
  }

  // Lessons
  Future<List<LessonModel>> getLessonsByUnit(String unitId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.lessonsCollection)
          .where('unitId', isEqualTo: unitId)
          .orderBy('order')
          .get();
      
      return snapshot.docs
          .map((doc) => LessonModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.lessonsCollection)
          .doc(lessonId)
          .get();
      
      if (!doc.exists) return null;
      return LessonModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }

  /// Lấy lessons theo danh sách levelId và lesson type
  /// Firestore whereIn giới hạn 10 items, nên chia nhỏ query nếu cần
  Future<List<LessonModel>> getLessonsByLevelsAndType(
    List<String> levelIds,
    LessonType type,
  ) async {
    try {
      if (levelIds.isEmpty) return [];

      final allLessons = <LessonModel>[];
      const batchSize = 10;

      for (int i = 0; i < levelIds.length; i += batchSize) {
        final batch = levelIds.skip(i).take(batchSize).toList();

        final snapshot = await _firestore
            .collection(FirebaseConstants.lessonsCollection)
            .where('levelId', whereIn: batch)
            .where('type', isEqualTo: type.toString())
            .get();

        final lessons = snapshot.docs
            .map((doc) => LessonModel.fromFirestore(doc.data(), doc.id))
            .toList();

        allLessons.addAll(lessons);
      }

      return allLessons;
    } catch (e) {
      throw Exception('Error fetching lessons by levels and type: $e');
    }
  }

  // Exercises
  Future<List<ExerciseModel>> getExercisesByLesson(
    String lessonId, {
    String? languageCode,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.exercisesCollection)
          .where('lessonId', isEqualTo: lessonId)
          .get();
      
      return snapshot.docs
          .map((doc) => ExerciseModel.fromFirestore(
                doc.data(), 
                doc.id,
                languageCode: languageCode,
              ))
          .toList();
    } catch (e) {
      throw Exception('Error fetching exercises: $e');
    }
  }

  Future<ExerciseModel?> getExercise(
    String exerciseId, {
    String? languageCode,
  }) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.exercisesCollection)
          .doc(exerciseId)
          .get();
      
      if (!doc.exists) return null;
      return ExerciseModel.fromFirestore(
        doc.data()!, 
        doc.id,
        languageCode: languageCode,
      );
    } catch (e) {
      throw Exception('Error fetching exercise: $e');
    }
  }

  /// Lấy exercises từ nhiều units
  /// Firestore có giới hạn 10 items cho whereIn, nên chia nhỏ query nếu cần
  Future<List<ExerciseModel>> getExercisesByUnits(
    List<String> unitIds, {
    String? languageCode,
  }) async {
    try {
      if (unitIds.isEmpty) return [];

      final allExercises = <ExerciseModel>[];
      
      // Firestore whereIn có giới hạn 10 items, chia nhỏ nếu cần
      const batchSize = 10;
      for (int i = 0; i < unitIds.length; i += batchSize) {
        final batch = unitIds.skip(i).take(batchSize).toList();
        
        final snapshot = await _firestore
            .collection(FirebaseConstants.exercisesCollection)
            .where('unitId', whereIn: batch)
            .get();
        
        final exercises = snapshot.docs
            .map((doc) => ExerciseModel.fromFirestore(
                  doc.data(),
                  doc.id,
                  languageCode: languageCode,
                ))
            .toList();
        
        allExercises.addAll(exercises);
      }
      
      return allExercises;
    } catch (e) {
      throw Exception('Error fetching exercises by units: $e');
    }
  }

  // Placement Test Questions
  Future<List<PlacementTestQuestion>> loadPlacementTestQuestions({
    String? languageCode,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.placementTestCollection)
          .get();

      return snapshot.docs
          .map((doc) => PlacementTestQuestion.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching placement test questions: $e');
    }
  }

  // Save placement test result
  Future<void> savePlacementTestResult(
    String userId,
    PlacementTestResult result,
  ) async {
    try {
      await _firestore
          .collection('placementTestResults')
          .doc(userId)
          .set(result.toMap());
    } catch (e) {
      throw Exception('Error saving placement test result: $e');
    }
  }

  // Stream để real-time updates
  Stream<List<LevelModel>> streamLevels() {
    return _firestore
        .collection(FirebaseConstants.levelsCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LevelModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // User Progress Methods
  /// Lấy user progress từ Firestore
  Future<UserProgressModel?> getUserProgress(String userId) async {
    try {
      // 1) Memory cache
      final mem = _progressMemCache[userId];
      final memAt = _progressMemFetchedAt[userId];
      if (mem != null &&
          memAt != null &&
          _cachePolicy.isFresh(fetchedAt: memAt, ttl: _cachePolicy.progressTtl)) {
        CacheMetrics.progressMemoryHits++;
        return mem;
      }

      // 2) Disk cache (Hive)
      final diskKey = 'user_progress__$userId';
      final diskAt = HiveCacheStore.getFetchedAt(diskKey);
      final diskFresh = diskAt != null &&
          _cachePolicy.isFresh(fetchedAt: diskAt, ttl: _cachePolicy.progressTtl);
      if (diskFresh) {
        final cached = HiveCacheStore.getJson<UserProgressModel>(
          diskKey,
          decode: (json) =>
              UserProgressModel.fromMap(Map<String, dynamic>.from(json as Map)),
        );
        if (cached != null) {
          CacheMetrics.progressDiskHits++;
          _progressMemCache[userId] = cached;
          _progressMemFetchedAt[userId] = DateTime.now();
          // SWR: refresh nền để đồng bộ (không block UI)
          _refreshUserProgressInBackground(userId);
          return cached;
        }
      }

      CacheMetrics.progressNetworkFetches++;
      final doc = await _firestore
          .collection(FirebaseConstants.userProgressCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        // Tạo progress mới nếu chưa có
        final newProgress = UserProgressModel(
          userId: userId,
          weakPoints: WeakPoints(),
          lastUpdated: DateTime.now(),
        );
        await updateUserProgress(userId, newProgress);
        await _cacheUserProgress(userId, newProgress);
        return newProgress;
      }
      
      final fresh = UserProgressModel.fromFirestore(doc);
      await _cacheUserProgress(userId, fresh);
      return fresh;
    } catch (e) {
      throw Exception('Error fetching user progress: $e');
    }
  }

  static Future<void> invalidateUserProgressCache(String userId) async {
    _progressMemCache.remove(userId);
    _progressMemFetchedAt.remove(userId);
    await HiveCacheStore.delete('user_progress__$userId');
  }

  static Future<void> _cacheUserProgress(
    String userId,
    UserProgressModel progress,
  ) async {
    _progressMemCache[userId] = progress;
    _progressMemFetchedAt[userId] = DateTime.now();
    await HiveCacheStore.putJson(
      'user_progress__$userId',
      json: progress.toMap(),
    );
  }

  void _refreshUserProgressInBackground(String userId) {
    _firestore
        .collection(FirebaseConstants.userProgressCollection)
        .doc(userId)
        .get()
        .then((doc) async {
      if (!doc.exists) return;
      final fresh = UserProgressModel.fromFirestore(doc);
      await _cacheUserProgress(userId, fresh);
    }).catchError((_) {});
  }

  /// Update user progress lên Firestore
  Future<void> updateUserProgress(String userId, UserProgressModel progress) async {
    try {
      await _firestore
          .collection(FirebaseConstants.userProgressCollection)
          .doc(userId)
          .set(progress.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating user progress: $e');
    }
  }

  /// Update user level
  Future<void> updateUserLevel(String userId, String newLevel) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({'currentLevel': newLevel});
    } catch (e) {
      throw Exception('Error updating user level: $e');
    }
  }

  /// Get user từ Firestore
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  /// Update user stats (totalXP, streak, lastActiveDate)
  Future<void> updateUserStats(
    String userId,
    int totalXP,
    int streak,
    DateTime lastActiveDate,
  ) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
        'totalXP': totalXP,
        'streak': streak,
        'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      });
    } catch (e) {
      throw Exception('Error updating user stats: $e');
    }
  }

  /// Lưu exercise progress với logic chỉ lưu khi cao hơn
  /// Trả về SaveExerciseProgressResult để indicate nếu có level-up
  Future<SaveExerciseProgressResult> saveExerciseProgress(
    String userId,
    ExerciseModel exercise,
    bool isCorrect,
    int timeSpent, {
    int? correctCount,
    int? totalCount,
  }) async {
    try {
      print('📝 saveExerciseProgress called');
      print('userId: $userId');
      print('exercise.id: ${exercise.id}');
      print('exercise.lessonId: ${exercise.lessonId}');
      print('exercise.unitId: ${exercise.unitId}');
      print('exercise.levelId: ${exercise.levelId}');
      
      // Lấy progress hiện tại
      print('Fetching current progress...');
      final currentProgress = await getUserProgress(userId);
      if (currentProgress == null) {
        throw Exception('Failed to get user progress');
      }
      print('Current progress loaded. Highest: ${currentProgress.highestProgress?.exerciseId ?? "none"}');

      // Tính score (0.0 - 1.0)
      final score = isCorrect ? 1.0 : 0.0;

      final resolvedTotalCount = totalCount ?? 1;
      final resolvedCorrectCount =
          correctCount ?? (isCorrect ? resolvedTotalCount : 0);

      // Tạo ExerciseHistoryItem mới
      final newHistoryItem = ExerciseHistoryItem(
        exerciseId: exercise.id,
        lessonId: exercise.lessonId,
        unitId: exercise.unitId,
        level: exercise.levelId,
        score: score,
        completedAt: DateTime.now(),
        timeSpent: timeSpent,
        mistakes: [], // Có thể thêm logic để track mistakes sau
        correctCount: resolvedCorrectCount,
        totalCount: resolvedTotalCount,
        tagsSnapshot: TagsSnapshot(
          skillTypes: exercise.skillTypes,
          grammarTopics: exercise.grammarTopics,
        ),
      );

      // Thêm vào exerciseHistory
      final updatedHistory = [
        ...currentProgress.exerciseHistory,
        newHistoryItem,
      ];

      // Kiểm tra xem có cần cập nhật highestProgress không
      HighestProgress? updatedHighestProgress = currentProgress.highestProgress;
      final groupUnitService = GroupUnitService();

      if (currentProgress.highestProgress == null) {
        // Nếu chưa có highestProgress, tạo mới
        // Tìm groupId từ unit
        String? groupId;
        try {
          final groupUnit = await groupUnitService.getGroupUnitByUnitId(exercise.unitId);
          groupId = groupUnit?.id;
        } catch (e) {
          print('⚠️ Error finding groupId for unit ${exercise.unitId}: $e');
        }

        updatedHighestProgress = HighestProgress(
          levelId: exercise.levelId,
          unitId: exercise.unitId,
          lessonId: exercise.lessonId,
          exerciseId: exercise.id,
          groupId: groupId,
          updatedAt: DateTime.now(),
        );
      } else {
        // So sánh với highestProgress hiện tại
        // Lấy Unit và Lesson models để so sánh chính xác hơn
        final currentUnit = await getUnit(currentProgress.highestProgress!.unitId);
        final newUnit = await getUnit(exercise.unitId);
        final currentLesson = await getLesson(currentProgress.highestProgress!.lessonId);
        final newLesson = await getLesson(exercise.lessonId);

        final isHigher = ProgressComparator.isHigherThan(
          newLevelId: exercise.levelId,
          newUnitId: exercise.unitId,
          newLessonId: exercise.lessonId,
          newExerciseId: exercise.id,
          currentLevelId: currentProgress.highestProgress!.levelId,
          currentUnitId: currentProgress.highestProgress!.unitId,
          currentLessonId: currentProgress.highestProgress!.lessonId,
          currentExerciseId: currentProgress.highestProgress!.exerciseId,
          newUnit: newUnit,
          currentUnit: currentUnit,
          newLesson: newLesson,
          currentLesson: currentLesson,
        );

        if (isHigher) {
          // Tìm groupId từ unit mới
          String? groupId;
          try {
            final groupUnit = await groupUnitService.getGroupUnitByUnitId(exercise.unitId);
            groupId = groupUnit?.id;
          } catch (e) {
            print('⚠️ Error finding groupId for unit ${exercise.unitId}: $e');
            // Fallback: giữ nguyên groupId cũ nếu không tìm thấy
            groupId = currentProgress.highestProgress!.groupId;
          }

          // Cập nhật highestProgress
          updatedHighestProgress = HighestProgress(
            levelId: exercise.levelId,
            unitId: exercise.unitId,
            lessonId: exercise.lessonId,
            exerciseId: exercise.id,
            groupId: groupId,
            updatedAt: DateTime.now(),
          );
        }
      }

      final weakSkillService = WeakSkillService();
      final weakSkillStats = weakSkillService.buildStats(updatedHistory);

      // Cập nhật progress
      final updatedProgress = currentProgress.copyWith(
        exerciseHistory: updatedHistory,
        highestProgress: updatedHighestProgress,
        weakSkillStats: weakSkillStats,
        lastUpdated: DateTime.now(),
      );

      print('Updating progress to Firestore...');
      print('New highestProgress: ${updatedHighestProgress?.exerciseId ?? "none"}');
      print('Total history items: ${updatedHistory.length}');
      
      // Lưu lên Firestore
      await updateUserProgress(userId, updatedProgress);
      // Invalidate progress cache ngay sau khi ghi (để UI lần sau đọc dữ liệu mới).
      await invalidateUserProgressCache(userId);
      print('✅ Progress updated successfully in Firestore');

      // Tính toán và cập nhật stats (streak, XP)
      try {
        final statsService = StatsService();
        await statsService.updateUserStats(userId, isCorrect);
        print('✅ User stats (streak, XP) updated successfully');
      } catch (e) {
        print('⚠️ Error updating user stats: $e');
        // Không throw error để không ảnh hưởng đến việc lưu progress
      }

      // Check level completion và level-up
      final levelProgressionService = LevelProgressionService();
      final currentLevel = exercise.levelId;
      final isLevelCompleted = await levelProgressionService.checkLevelCompletion(
        userId,
        currentLevel,
      );

      if (isLevelCompleted) {
        // Get next level
        final nextLevel = levelProgressionService.getNextLevel(currentLevel);
        if (nextLevel != null) {
          print('🎉 Level $currentLevel completed! Leveling up to $nextLevel');
          
          // Level up
          await levelProgressionService.levelUp(userId, nextLevel);
          
          // Refresh user data trong AuthProvider (sẽ cần implement)
          // Có thể dùng callback hoặc event để notify UI
          
          return SaveExerciseProgressResult(
            levelUp: true,
            oldLevel: currentLevel,
            newLevel: nextLevel,
          );
        }
      }

      return SaveExerciseProgressResult(levelUp: false);
    } catch (e, stackTrace) {
      print('❌ Exception in saveExerciseProgress: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error saving exercise progress: $e');
    }
  }

  // Level Skip Test Methods
  /// Load level skip test questions từ Firestore collection levelSkipTests
  Future<List<PlacementTestQuestion>> loadLevelSkipTestQuestions(
    String targetLevel,
  ) async {
    try {
      // Normalize level to uppercase
      final normalizedLevel = targetLevel.toUpperCase();
      final collectionName = FirebaseConstants.levelSkipTestCollection;
      
      debugPrint('Querying collection: $collectionName for level: $normalizedLevel');
      
      // Thử query với where clause trước
      try {
        final snapshot = await _firestore
            .collection(collectionName)
            .where('level', isEqualTo: normalizedLevel)
            .get();

        debugPrint('Level Skip Test Query: level=$normalizedLevel, found ${snapshot.docs.length} documents');
        
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => PlacementTestQuestion.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Query with where clause failed: $e');
      }
      
      // Fallback: Query tất cả rồi filter ở client side
      debugPrint('Falling back to client-side filter...');
      
      try {
        final allSnapshot = await _firestore
            .collection(collectionName)
            .get();
        
        debugPrint('Total documents in $collectionName: ${allSnapshot.docs.length}');
        
        if (allSnapshot.docs.isEmpty) {
          // Thử các collection names khác có thể
          debugPrint('Trying alternative collection names...');
          final altNames = ['levelSkipTest', 'level_skip_tests', 'levelSkipTestQuestions'];
          for (final altName in altNames) {
            try {
              final altSnapshot = await _firestore.collection(altName).limit(1).get();
              if (altSnapshot.docs.isNotEmpty) {
                debugPrint('Found documents in alternative collection: $altName');
                throw Exception('Documents found in collection "$altName" but not in "$collectionName". Please check collection name.');
              }
            } catch (e) {
              if (e.toString().contains('found in collection')) {
                rethrow;
              }
              // Ignore other errors
            }
          }
          
          throw Exception('No documents found in collection "$collectionName". Please import data from JSON files.');
        }
        
        // Debug: Log sample document
        final sampleDoc = allSnapshot.docs.first.data();
        debugPrint('Sample document ID: ${allSnapshot.docs.first.id}');
        debugPrint('Sample document level value: ${sampleDoc['level']} (type: ${sampleDoc['level'].runtimeType})');
        debugPrint('Target level: $normalizedLevel (type: String)');
        
        // Filter ở client side
        final filteredDocs = allSnapshot.docs.where((doc) {
          final docLevel = doc.data()['level']?.toString().toUpperCase();
          return docLevel == normalizedLevel;
        }).toList();
        
        debugPrint('Filtered documents: ${filteredDocs.length}');
        
        if (filteredDocs.isEmpty) {
          final availableLevels = allSnapshot.docs.map((d) => d.data()['level']?.toString()).whereType<String>().toSet();
          throw Exception('No questions found for level $normalizedLevel. Available levels: ${availableLevels.join(", ")}');
        }
        
        return filteredDocs
            .map((doc) => PlacementTestQuestion.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e) {
        if (e.toString().contains('No documents found')) {
          rethrow;
        }
        debugPrint('Error querying collection: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('Error fetching level skip test questions: $e');
      throw Exception('Error fetching level skip test questions: $e');
    }
  }

  /// Lấy level skip test attempt của user trong ngày
  Future<LevelSkipTestAttempt?> getLevelSkipTestAttempt(
    String userId,
    String date,
  ) async {
    try {
      final docId = '${userId}_$date';
      final doc = await _firestore
          .collection(FirebaseConstants.levelSkipTestAttemptsCollection)
          .doc(docId)
          .get();

      if (!doc.exists) return null;
      return LevelSkipTestAttempt.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Error fetching level skip test attempt: $e');
    }
  }

  /// Lưu level skip test attempt (tăng count trong ngày)
  Future<void> saveLevelSkipTestAttempt(
    String userId,
    String date,
  ) async {
    try {
      final docId = '${userId}_$date';
      final docRef = _firestore
          .collection(FirebaseConstants.levelSkipTestAttemptsCollection)
          .doc(docId);

      // Kiểm tra xem đã có attempt chưa
      final doc = await docRef.get();
      
      if (doc.exists) {
        // Tăng count
        await docRef.update({
          'count': FieldValue.increment(1),
          'lastAttemptAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Tạo mới
        final attempt = LevelSkipTestAttempt(
          userId: userId,
          date: date,
          count: 1,
          lastAttemptAt: DateTime.now(),
        );
        await docRef.set(attempt.toMap());
      }
    } catch (e) {
      throw Exception('Error saving level skip test attempt: $e');
    }
  }

  static String _vocabularyDocId(String vocabularyKey) {
    return vocabularyKey.replaceAll('/', '_').replaceAll('\\', '_');
  }

  /// Merge-set từ vựng user; tối đa ~450 op/batch (giới hạn Firestore 500).
  Future<void> batchUpsertUserVocabularyWords(
    String userId,
    Map<String, Map<String, dynamic>> byVocabularyKey,
  ) async {
    if (byVocabularyKey.isEmpty) return;
    try {
      const maxOps = 450;
      WriteBatch batch = _firestore.batch();
      var n = 0;
      for (final e in byVocabularyKey.entries) {
        final ref = _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(userId)
            .collection(FirebaseConstants.userVocabularyWordsSubcollection)
            .doc(_vocabularyDocId(e.key));
        batch.set(ref, e.value, SetOptions(merge: true));
        n++;
        if (n >= maxOps) {
          await batch.commit();
          batch = _firestore.batch();
          n = 0;
        }
      }
      if (n > 0) {
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Error batch upsert vocabulary words: $e');
    }
  }
}


