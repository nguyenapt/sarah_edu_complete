import '../../models/exercise_model.dart';
import '../../models/lesson_model.dart';
import '../../models/unit_model.dart';
import '../../models/progress_model.dart';
import '../../core/services/firestore_service.dart';

/// Service để tìm exercise tiếp theo dựa trên highestProgress
class NextExerciseService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Parse exercise ID để lấy các số
  /// Ví dụ: exercise_a1_1_1_2 -> {level: 'A1', unit: 1, lesson: 1, exercise: 2}
  Map<String, dynamic>? _parseExerciseId(String exerciseId) {
    try {
      final parts = exerciseId.split('_');
      if (parts.length < 5) return null;
      
      // exercise_a1_1_1_2 -> ['exercise', 'a1', '1', '1', '2']
      final level = parts[1].toUpperCase(); // a1 -> A1
      final unit = int.tryParse(parts[2]);
      final lesson = int.tryParse(parts[3]);
      final exercise = int.tryParse(parts[4]);
      
      if (unit == null || lesson == null || exercise == null) return null;
      
      return {
        'level': level,
        'unit': unit,
        'lesson': lesson,
        'exercise': exercise,
      };
    } catch (e) {
      return null;
    }
  }

  /// Tạo exercise ID từ các số
  /// Ví dụ: {level: 'A1', unit: 1, lesson: 1, exercise: 3} -> 'exercise_a1_1_1_3'
  String _buildExerciseId(String level, int unit, int lesson, int exercise) {
    return 'exercise_${level.toLowerCase()}_${unit}_${lesson}_$exercise';
  }

  /// Tìm exercise tiếp theo trong cùng lesson
  Future<ExerciseModel?> _findNextExerciseInLesson(
    String levelId,
    String unitId,
    String lessonId,
    int currentExerciseNum,
  ) async {
    try {
      // Lấy tất cả exercises trong lesson
      final exercises = await _firestoreService.getExercisesByLesson(lessonId);
      if (exercises.isEmpty) return null;

      // Sắp xếp theo exercise number (parse từ ID)
      exercises.sort((a, b) {
        final aNum = _parseExerciseId(a.id)?['exercise'] ?? 0;
        final bNum = _parseExerciseId(b.id)?['exercise'] ?? 0;
        return aNum.compareTo(bNum);
      });

      // Tìm exercise tiếp theo
      for (final exercise in exercises) {
        final exNum = _parseExerciseId(exercise.id)?['exercise'] ?? 0;
        if (exNum > currentExerciseNum) {
          return exercise;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tìm exercise đầu tiên trong lesson tiếp theo
  Future<ExerciseModel?> _findFirstExerciseInNextLesson(
    String levelId,
    String unitId,
    int currentLessonNum,
  ) async {
    try {
      // Lấy unit để lấy danh sách lessons
      final unit = await _firestoreService.getUnit(unitId);
      if (unit == null) return null;

      // Lấy tất cả lessons trong unit
      final lessons = await _firestoreService.getLessonsByUnit(unitId);
      if (lessons.isEmpty) return null;

      // Sắp xếp theo order
      lessons.sort((a, b) => a.order.compareTo(b.order));

      // Tìm lesson tiếp theo
      LessonModel? nextLesson;
      for (final lesson in lessons) {
        if (lesson.order > currentLessonNum) {
          nextLesson = lesson;
          break;
        }
      }

      // Nếu không có lesson tiếp theo trong unit này, tìm lesson đầu tiên của unit tiếp theo
      if (nextLesson == null) {
        return await _findFirstExerciseInNextUnit(levelId, unit.order);
      }

      // Lấy exercise đầu tiên trong lesson tiếp theo
      final exercises = await _firestoreService.getExercisesByLesson(nextLesson.id);
      if (exercises.isEmpty) return null;

      // Sắp xếp và lấy exercise đầu tiên
      exercises.sort((a, b) {
        final aNum = _parseExerciseId(a.id)?['exercise'] ?? 0;
        final bNum = _parseExerciseId(b.id)?['exercise'] ?? 0;
        return aNum.compareTo(bNum);
      });

      return exercises.first;
    } catch (e) {
      return null;
    }
  }

  /// Tìm exercise đầu tiên trong unit tiếp theo
  Future<ExerciseModel?> _findFirstExerciseInNextUnit(
    String levelId,
    int currentUnitOrder,
  ) async {
    try {
      // Lấy tất cả units trong level
      final units = await _firestoreService.getUnitsByLevel(levelId);
      if (units.isEmpty) return null;

      // Sắp xếp theo order
      units.sort((a, b) => a.order.compareTo(b.order));

      // Tìm unit tiếp theo
      UnitModel? nextUnit;
      for (final unit in units) {
        if (unit.order > currentUnitOrder) {
          nextUnit = unit;
          break;
        }
      }

      // Nếu không có unit tiếp theo trong level này, tìm unit đầu tiên của level tiếp theo
      if (nextUnit == null) {
        return await _findFirstExerciseInNextLevel(levelId);
      }

      // Lấy lesson đầu tiên trong unit tiếp theo
      final lessons = await _firestoreService.getLessonsByUnit(nextUnit.id);
      if (lessons.isEmpty) return null;

      lessons.sort((a, b) => a.order.compareTo(b.order));
      final firstLesson = lessons.first;

      // Lấy exercise đầu tiên trong lesson đầu tiên
      final exercises = await _firestoreService.getExercisesByLesson(firstLesson.id);
      if (exercises.isEmpty) return null;

      exercises.sort((a, b) {
        final aNum = _parseExerciseId(a.id)?['exercise'] ?? 0;
        final bNum = _parseExerciseId(b.id)?['exercise'] ?? 0;
        return aNum.compareTo(bNum);
      });

      return exercises.first;
    } catch (e) {
      return null;
    }
  }

  /// Tìm exercise đầu tiên trong level tiếp theo
  Future<ExerciseModel?> _findFirstExerciseInNextLevel(String currentLevelId) async {
    try {
      // Danh sách levels theo thứ tự
      const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      final currentIndex = levelOrder.indexOf(currentLevelId);
      if (currentIndex == -1 || currentIndex >= levelOrder.length - 1) {
        return null; // Không có level tiếp theo
      }

      final nextLevelId = levelOrder[currentIndex + 1];

      // Lấy units trong level tiếp theo
      final units = await _firestoreService.getUnitsByLevel(nextLevelId);
      if (units.isEmpty) return null;

      units.sort((a, b) => a.order.compareTo(b.order));
      final firstUnit = units.first;

      // Lấy lesson đầu tiên
      final lessons = await _firestoreService.getLessonsByUnit(firstUnit.id);
      if (lessons.isEmpty) return null;

      lessons.sort((a, b) => a.order.compareTo(b.order));
      final firstLesson = lessons.first;

      // Lấy exercise đầu tiên
      final exercises = await _firestoreService.getExercisesByLesson(firstLesson.id);
      if (exercises.isEmpty) return null;

      exercises.sort((a, b) {
        final aNum = _parseExerciseId(a.id)?['exercise'] ?? 0;
        final bNum = _parseExerciseId(b.id)?['exercise'] ?? 0;
        return aNum.compareTo(bNum);
      });

      return exercises.first;
    } catch (e) {
      return null;
    }
  }

  /// Tìm exercise tiếp theo dựa trên highestProgress
  /// Trả về null nếu không tìm thấy (đã học hết)
  Future<ExerciseModel?> getNextExercise(HighestProgress? highestProgress) async {
    if (highestProgress == null) {
      // Nếu chưa có progress, trả về exercise đầu tiên của A1
      return await _findFirstExerciseInNextLevel(''); // Sẽ tìm A1
    }

    // Parse exercise ID hiện tại
    final parsed = _parseExerciseId(highestProgress.exerciseId);
    if (parsed == null) return null;

    final levelId = parsed['level'] as String;
    final unitNum = parsed['unit'] as int;
    final lessonNum = parsed['lesson'] as int;
    final exerciseNum = parsed['exercise'] as int;

    // Tìm exercise tiếp theo trong cùng lesson
    final nextInLesson = await _findNextExerciseInLesson(
      levelId,
      highestProgress.unitId,
      highestProgress.lessonId,
      exerciseNum,
    );
    if (nextInLesson != null) return nextInLesson;

    // Nếu không có, tìm exercise đầu tiên trong lesson tiếp theo
    final nextInNextLesson = await _findFirstExerciseInNextLesson(
      levelId,
      highestProgress.unitId,
      lessonNum,
    );
    if (nextInNextLesson != null) return nextInNextLesson;

    // Nếu không có, tìm exercise đầu tiên trong unit tiếp theo
    final unit = await _firestoreService.getUnit(highestProgress.unitId);
    if (unit != null) {
      final nextInNextUnit = await _findFirstExerciseInNextUnit(
        levelId,
        unit.order,
      );
      if (nextInNextUnit != null) return nextInNextUnit;
    }

    // Nếu không có, tìm exercise đầu tiên trong level tiếp theo
    return await _findFirstExerciseInNextLevel(levelId);
  }

  /// Helper để tìm exercise đầu tiên (khi chưa có progress)
  Future<ExerciseModel?> getFirstExercise() async {
    // Tìm exercise đầu tiên của A1
    const firstLevelId = 'A1';
    final units = await _firestoreService.getUnitsByLevel(firstLevelId);
    if (units.isEmpty) return null;

    units.sort((a, b) => a.order.compareTo(b.order));
    final firstUnit = units.first;

    final lessons = await _firestoreService.getLessonsByUnit(firstUnit.id);
    if (lessons.isEmpty) return null;

    lessons.sort((a, b) => a.order.compareTo(b.order));
    final firstLesson = lessons.first;

    final exercises = await _firestoreService.getExercisesByLesson(firstLesson.id);
    if (exercises.isEmpty) return null;

    exercises.sort((a, b) {
      final aNum = _parseExerciseId(a.id)?['exercise'] ?? 0;
      final bNum = _parseExerciseId(b.id)?['exercise'] ?? 0;
      return aNum.compareTo(bNum);
    });

    return exercises.first;
  }
}

