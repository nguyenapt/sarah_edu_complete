import '../../models/exercise_model.dart';
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

  /// Lấy level tiếp theo
  /// Ví dụ: A1 -> A2, A2 -> B1, C2 -> null
  String? _getNextLevel(String currentLevel) {
    const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levelOrder.indexOf(currentLevel);
    if (currentIndex == -1 || currentIndex >= levelOrder.length - 1) {
      return null; // Không có level tiếp theo
    }
    return levelOrder[currentIndex + 1];
  }

  /// Tìm exercise tiếp theo dựa trên highestProgress
  /// Logic đơn giản: thử +1 exercise, nếu không có thì +1 lesson, +1 unit, +1 level
  Future<ExerciseModel?> getNextExercise(HighestProgress? highestProgress) async {
    if (highestProgress == null) {
      // Nếu chưa có progress, trả về exercise đầu tiên của A1
      const firstExerciseId = 'exercise_a1_1_1_1';
      return await _firestoreService.getExercise(firstExerciseId);
    }

    // Parse exercise ID hiện tại
    final parsed = _parseExerciseId(highestProgress.exerciseId);
    if (parsed == null) return null;

    final levelId = parsed['level'] as String;
    final unitNum = parsed['unit'] as int;
    final lessonNum = parsed['lesson'] as int;
    final exerciseNum = parsed['exercise'] as int;

    // 1. Thử exercise +1: exercise_a1_3_1_7 -> exercise_a1_3_1_8
    final nextExerciseId = _buildExerciseId(levelId, unitNum, lessonNum, exerciseNum + 1);
    final nextExercise = await _firestoreService.getExercise(nextExerciseId);
    if (nextExercise != null) return nextExercise;

    // 2. Nếu không có, thử lesson +1 (exercise reset về 1): exercise_a1_3_1_7 -> exercise_a1_3_2_1
    final nextLessonExerciseId = _buildExerciseId(levelId, unitNum, lessonNum + 1, 1);
    final nextLessonExercise = await _firestoreService.getExercise(nextLessonExerciseId);
    if (nextLessonExercise != null) return nextLessonExercise;

    // 3. Nếu không có, thử unit +1 (lesson reset về 1, exercise reset về 1): exercise_a1_3_1_7 -> exercise_a1_4_1_1
    final nextUnitExerciseId = _buildExerciseId(levelId, unitNum + 1, 1, 1);
    final nextUnitExercise = await _firestoreService.getExercise(nextUnitExerciseId);
    if (nextUnitExercise != null) return nextUnitExercise;

    // 4. Nếu không có, thử level +1 (unit reset về 1, lesson reset về 1, exercise reset về 1): exercise_a1_3_1_7 -> exercise_a2_1_1_1
    final nextLevel = _getNextLevel(levelId);
    if (nextLevel != null) {
      final nextLevelExerciseId = _buildExerciseId(nextLevel, 1, 1, 1);
      final nextLevelExercise = await _firestoreService.getExercise(nextLevelExerciseId);
      if (nextLevelExercise != null) return nextLevelExercise;
    }

    // Không tìm thấy exercise tiếp theo
    return null;
  }

  /// Helper để tìm exercise đầu tiên (khi chưa có progress)
  Future<ExerciseModel?> getFirstExercise() async {
    // Tìm exercise đầu tiên của A1: exercise_a1_1_1_1
    const firstExerciseId = 'exercise_a1_1_1_1';
    return await _firestoreService.getExercise(firstExerciseId);
  }
}

