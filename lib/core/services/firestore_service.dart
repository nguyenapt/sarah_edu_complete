import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../models/placement_test_model.dart';
import '../../models/progress_model.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/utils/progress_comparator.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<List<UnitModel>> getAllUnits() async {
    try {
      // Lấy tất cả levels để sắp xếp
      final levels = await getLevels();
      
      // Lấy tất cả units từ tất cả levels
      final allUnits = <UnitModel>[];
      for (final level in levels) {
        final units = await getUnitsByLevel(level.id);
        allUnits.addAll(units);
      }
      
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
        return newProgress;
      }
      
      return UserProgressModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error fetching user progress: $e');
    }
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

  /// Lưu exercise progress với logic chỉ lưu khi cao hơn
  Future<void> saveExerciseProgress(
    String userId,
    ExerciseModel exercise,
    bool isCorrect,
    int timeSpent,
  ) async {
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
      );

      // Thêm vào exerciseHistory
      final updatedHistory = [
        ...currentProgress.exerciseHistory,
        newHistoryItem,
      ];

      // Kiểm tra xem có cần cập nhật highestProgress không
      HighestProgress? updatedHighestProgress = currentProgress.highestProgress;

      if (currentProgress.highestProgress == null) {
        // Nếu chưa có highestProgress, tạo mới
        updatedHighestProgress = HighestProgress(
          levelId: exercise.levelId,
          unitId: exercise.unitId,
          lessonId: exercise.lessonId,
          exerciseId: exercise.id,
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
          // Cập nhật highestProgress
          updatedHighestProgress = HighestProgress(
            levelId: exercise.levelId,
            unitId: exercise.unitId,
            lessonId: exercise.lessonId,
            exerciseId: exercise.id,
            updatedAt: DateTime.now(),
          );
        }
      }

      // Cập nhật progress
      final updatedProgress = currentProgress.copyWith(
        exerciseHistory: updatedHistory,
        highestProgress: updatedHighestProgress,
        lastUpdated: DateTime.now(),
      );

      print('Updating progress to Firestore...');
      print('New highestProgress: ${updatedHighestProgress?.exerciseId ?? "none"}');
      print('Total history items: ${updatedHistory.length}');
      
      // Lưu lên Firestore
      await updateUserProgress(userId, updatedProgress);
      print('✅ Progress updated successfully in Firestore');
    } catch (e, stackTrace) {
      print('❌ Exception in saveExerciseProgress: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error saving exercise progress: $e');
    }
  }
}


