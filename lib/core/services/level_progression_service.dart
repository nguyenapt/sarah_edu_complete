import 'package:flutter/foundation.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import '../../core/services/firestore_service.dart';
import 'group_unit_service.dart';

class LevelProgressionService {
  final FirestoreService _firestoreService = FirestoreService();

  /// So sánh exercise IDs để xác định thứ tự
  int _compareExerciseIds(String a, String b) {
    // Parse số từ exercise ID (ví dụ: exercise_a1_1_1_3 -> 3)
    int parseExerciseOrder(String exerciseId) {
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
    
    // So sánh theo level, unit, lesson, exercise
    final aParts = a.split('_');
    final bParts = b.split('_');
    
    if (aParts.length >= 2 && bParts.length >= 2) {
      // So sánh level
      const levelOrder = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
      final aLevelIndex = levelOrder.indexOf(aParts[1].toLowerCase());
      final bLevelIndex = levelOrder.indexOf(bParts[1].toLowerCase());
      if (aLevelIndex != bLevelIndex) {
        return aLevelIndex.compareTo(bLevelIndex);
      }
    }
    
    if (aParts.length >= 3 && bParts.length >= 3) {
      // So sánh unit
      final aUnit = int.tryParse(aParts[2]) ?? 0;
      final bUnit = int.tryParse(bParts[2]) ?? 0;
      if (aUnit != bUnit) {
        return aUnit.compareTo(bUnit);
      }
    }
    
    if (aParts.length >= 4 && bParts.length >= 4) {
      // So sánh lesson
      final aLesson = int.tryParse(aParts[3]) ?? 0;
      final bLesson = int.tryParse(bParts[3]) ?? 0;
      if (aLesson != bLesson) {
        return aLesson.compareTo(bLesson);
      }
    }
    
    // So sánh exercise order
    return parseExerciseOrder(a).compareTo(parseExerciseOrder(b));
  }

  /// Lấy tất cả exercises của một level
  Future<List<ExerciseModel>> getExercisesByLevel(String levelId) async {
    try {
      // Lấy tất cả units của level
      final units = await _firestoreService.getUnitsByLevel(levelId);
      if (units.isEmpty) return [];

      // Lấy tất cả exercises từ tất cả units
      final allExercises = <ExerciseModel>[];
      for (final unit in units) {
        // Lấy lessons của unit
        final lessons = await _firestoreService.getLessonsByUnit(unit.id);
        for (final lesson in lessons) {
          // Lấy exercises của lesson
          final exercises = await _firestoreService.getExercisesByLesson(lesson.id);
          allExercises.addAll(exercises);
        }
      }

      // Sắp xếp exercises theo ID
      allExercises.sort((a, b) => _compareExerciseIds(a.id, b.id));

      return allExercises;
    } catch (e) {
      throw Exception('Error fetching exercises by level: $e');
    }
  }

  /// Check xem user đã hoàn thành level chưa
  /// Level được coi là hoàn thành khi highestProgress.exerciseId khớp với level.highestExerciseId
  Future<bool> checkLevelCompletion(
    String userId,
    String levelId,
  ) async {
    try {
      // 1. Lấy level từ Firestore
      final level = await _firestoreService.getLevel(levelId);
      if (level == null) return false;

      // 2. Nếu level không có highestExerciseId, return false
      if (level.highestExerciseId == null) return false;

      // 3. Lấy user progress
      final progress = await _firestoreService.getUserProgress(userId);
      if (progress == null || progress.highestProgress == null) return false;

      // 4. So sánh highestProgress.exerciseId với level.highestExerciseId
      return progress.highestProgress!.exerciseId == level.highestExerciseId;
    } catch (e) {
      debugPrint('Error checking level completion: $e');
      return false;
    }
  }

  /// Lấy level tiếp theo
  String? getNextLevel(String currentLevel) {
    const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levelOrder.indexOf(currentLevel);
    if (currentIndex == -1 || currentIndex >= levelOrder.length - 1) {
      return null; // Không có level tiếp theo
    }
    return levelOrder[currentIndex + 1];
  }

  /// Lấy exercise đầu tiên của level với index 0
  Future<ExerciseModel?> getFirstExerciseOfLevel(String levelId) async {
    try {
      final exercises = await getExercisesByLevel(levelId);
      if (exercises.isEmpty) return null;

      // Lấy exercise đầu tiên
      final firstExercise = exercises.first;

      // Đảm bảo exercise ID có index 0 ở cuối
      // Format: exercise_c1_1_1_0
      final parts = firstExercise.id.split('_');
      if (parts.length >= 5) {
        // Thay index cuối cùng bằng 0
        parts[parts.length - 1] = '0';
        final exerciseIdWithZero = parts.join('_');

        // Tìm exercise với ID này, nếu không có thì dùng exercise đầu tiên
        final exerciseWithZero = exercises.firstWhere(
          (e) => e.id == exerciseIdWithZero,
          orElse: () => firstExercise,
        );

        return exerciseWithZero;
      }

      return firstExercise;
    } catch (e) {
      debugPrint('Error getting first exercise of level: $e');
      return null;
    }
  }

  /// Level up: cập nhật user level và highestProgress
  Future<void> levelUp(
    String userId,
    String newLevel,
  ) async {
    try {
      // 1. Update user.currentLevel
      await _firestoreService.updateUserLevel(userId, newLevel);

      // 2. Lấy exercise đầu tiên của level mới với index 0
      final firstExercise = await getFirstExerciseOfLevel(newLevel);
      if (firstExercise == null) {
        throw Exception('Cannot find first exercise of level $newLevel');
      }

      // 3. Tìm groupId từ unit
      String? groupId;
      try {
        final groupUnitService = GroupUnitService();
        final groupUnit = await groupUnitService.getGroupUnitByUnitId(firstExercise.unitId);
        groupId = groupUnit?.id;
        
        // Nếu không tìm thấy qua groupUnits, thử lấy từ unit.groupId
        if (groupId == null) {
          final unit = await _firestoreService.getUnit(firstExercise.unitId);
          groupId = unit?.groupId;
        }
      } catch (e) {
        print('⚠️ Error finding groupId for unit ${firstExercise.unitId}: $e');
      }

      // 4. Tạo highestProgress mới với exercise đầu tiên (index 0)
      final newHighestProgress = HighestProgress(
        levelId: firstExercise.levelId,
        unitId: firstExercise.unitId,
        lessonId: firstExercise.lessonId,
        exerciseId: firstExercise.id,
        groupId: groupId,
        updatedAt: DateTime.now(),
      );

      // 4. Update progress
      final progress = await _firestoreService.getUserProgress(userId);
      if (progress != null) {
        final updatedProgress = progress.copyWith(
          highestProgress: newHighestProgress,
          lastUpdated: DateTime.now(),
        );
        await _firestoreService.updateUserProgress(userId, updatedProgress);
      }
    } catch (e) {
      throw Exception('Error leveling up: $e');
    }
  }
}

