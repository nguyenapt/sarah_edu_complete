import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/exercise_model.dart';
import '../../models/placement_test_model.dart';
import '../../core/constants/firebase_constants.dart';

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
}


