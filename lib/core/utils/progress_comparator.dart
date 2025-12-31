import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';

/// Class để so sánh tiến trình học tập
/// So sánh dựa trên levelId, unitId, lessonId, exerciseId
class ProgressComparator {
  /// So sánh levelId (A1 < A2 < B1 < B2 < C1 < C2)
  static int _compareLevel(String level1, String level2) {
    final order = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final index1 = order.indexOf(level1);
    final index2 = order.indexOf(level2);
    
    if (index1 == -1 && index2 == -1) return 0;
    if (index1 == -1) return -1;
    if (index2 == -1) return 1;
    
    return index1.compareTo(index2);
  }

  /// Parse số từ unit ID (ví dụ: unit_a1_1 -> 1)
  static int _parseUnitOrder(String unitId) {
    // Pattern: unit_a1_1 -> số cuối cùng là 1
    final parts = unitId.split('_');
    if (parts.length >= 3) {
      try {
        return int.parse(parts[parts.length - 1]);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Parse số từ lesson ID (ví dụ: lesson_a1_1_2 -> 2)
  static int _parseLessonOrder(String lessonId) {
    // Pattern: lesson_a1_1_2 -> số cuối cùng là 2
    final parts = lessonId.split('_');
    if (parts.length >= 4) {
      try {
        return int.parse(parts[parts.length - 1]);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Parse số từ exercise ID (ví dụ: exercise_a1_1_1_3 -> 3)
  static int _parseExerciseOrder(String exerciseId) {
    // Pattern: exercise_a1_1_1_3 -> số cuối cùng là 3
    final parts = exerciseId.split('_');
    if (parts.length >= 5) {
      try {
        return int.parse(parts[parts.length - 1]);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// So sánh unit order: dùng order field nếu có, fallback về parse từ ID
  static int _compareUnit(String unitId1, String unitId2, UnitModel? unit1, UnitModel? unit2) {
    // Ưu tiên dùng order field nếu có
    if (unit1 != null && unit2 != null) {
      return unit1.order.compareTo(unit2.order);
    }
    if (unit1 != null) {
      return unit1.order.compareTo(_parseUnitOrder(unitId2));
    }
    if (unit2 != null) {
      return _parseUnitOrder(unitId1).compareTo(unit2.order);
    }
    // Fallback về parse từ ID
    return _parseUnitOrder(unitId1).compareTo(_parseUnitOrder(unitId2));
  }

  /// So sánh lesson order: dùng order field nếu có, fallback về parse từ ID
  static int _compareLesson(String lessonId1, String lessonId2, LessonModel? lesson1, LessonModel? lesson2) {
    // Ưu tiên dùng order field nếu có
    if (lesson1 != null && lesson2 != null) {
      return lesson1.order.compareTo(lesson2.order);
    }
    if (lesson1 != null) {
      return lesson1.order.compareTo(_parseLessonOrder(lessonId2));
    }
    if (lesson2 != null) {
      return _parseLessonOrder(lessonId1).compareTo(lesson2.order);
    }
    // Fallback về parse từ ID
    return _parseLessonOrder(lessonId1).compareTo(_parseLessonOrder(lessonId2));
  }

  /// So sánh exercise order: parse từ ID (không có order field trong ExerciseModel)
  static int _compareExercise(String exerciseId1, String exerciseId2) {
    return _parseExerciseOrder(exerciseId1).compareTo(_parseExerciseOrder(exerciseId2));
  }

  /// So sánh 2 progress objects
  /// Trả về: -1 nếu progress1 < progress2, 0 nếu bằng, 1 nếu progress1 > progress2
  static int compareProgress({
    required String levelId1,
    required String unitId1,
    required String lessonId1,
    required String exerciseId1,
    required String levelId2,
    required String unitId2,
    required String lessonId2,
    required String exerciseId2,
    UnitModel? unit1,
    UnitModel? unit2,
    LessonModel? lesson1,
    LessonModel? lesson2,
  }) {
    // 1. So sánh levelId
    final levelCompare = _compareLevel(levelId1, levelId2);
    if (levelCompare != 0) return levelCompare;

    // 2. Nếu cùng level, so sánh unitId
    final unitCompare = _compareUnit(unitId1, unitId2, unit1, unit2);
    if (unitCompare != 0) return unitCompare;

    // 3. Nếu cùng unit, so sánh lessonId
    final lessonCompare = _compareLesson(lessonId1, lessonId2, lesson1, lesson2);
    if (lessonCompare != 0) return lessonCompare;

    // 4. Nếu cùng lesson, so sánh exerciseId
    return _compareExercise(exerciseId1, exerciseId2);
  }

  /// Kiểm tra xem progress mới có cao hơn progress hiện tại không
  /// Trả về true nếu progress mới cao hơn
  static bool isHigherThan({
    required String newLevelId,
    required String newUnitId,
    required String newLessonId,
    required String newExerciseId,
    required String currentLevelId,
    required String currentUnitId,
    required String currentLessonId,
    required String currentExerciseId,
    UnitModel? newUnit,
    UnitModel? currentUnit,
    LessonModel? newLesson,
    LessonModel? currentLesson,
  }) {
    final compareResult = compareProgress(
      levelId1: newLevelId,
      unitId1: newUnitId,
      lessonId1: newLessonId,
      exerciseId1: newExerciseId,
      levelId2: currentLevelId,
      unitId2: currentUnitId,
      lessonId2: currentLessonId,
      exerciseId2: currentExerciseId,
      unit1: newUnit,
      unit2: currentUnit,
      lesson1: newLesson,
      lesson2: currentLesson,
    );
    
    return compareResult > 0;
  }
}

