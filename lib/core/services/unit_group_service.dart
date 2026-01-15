import 'package:flutter/foundation.dart';
import '../../models/unit_model.dart';
import '../../models/unit_group_model.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import '../../models/group_unit_model.dart';
import 'firestore_service.dart';
import 'group_unit_service.dart';

/// Service để quản lý nhóm unit và logic unlock
class UnitGroupService {
  final FirestoreService _firestoreService = FirestoreService();
  final GroupUnitService _groupUnitService = GroupUnitService();
  
  // Cache units của level để tránh query lại
  final Map<String, List<UnitModel>> _cachedUnitsByLevel = {};

  /// So sánh 2 exercise IDs để xem exercise nào cao hơn
  /// Format: exercise_a1_1_2_4 -> [exercise, a1, 1, 2, 4]
  /// Trả về: -1 nếu exercise1 < exercise2, 0 nếu bằng, 1 nếu exercise1 > exercise2
  int _compareExerciseIds(String exerciseId1, String exerciseId2) {
    final parts1 = exerciseId1.split('_');
    final parts2 = exerciseId2.split('_');
    
    // Cần ít nhất 5 parts: exercise_level_unit_lesson_exercise
    if (parts1.length < 5 || parts2.length < 5) {
      return exerciseId1.compareTo(exerciseId2);
    }
    
    // So sánh level (index 1)
    final levelCompare = parts1[1].compareTo(parts2[1]);
    if (levelCompare != 0) return levelCompare;
    
    // So sánh unit (index 2)
    final unit1 = int.tryParse(parts1[2]) ?? 0;
    final unit2 = int.tryParse(parts2[2]) ?? 0;
    if (unit1 != unit2) return unit1.compareTo(unit2);
    
    // So sánh lesson (index 3)
    final lesson1 = int.tryParse(parts1[3]) ?? 0;
    final lesson2 = int.tryParse(parts2[3]) ?? 0;
    if (lesson1 != lesson2) return lesson1.compareTo(lesson2);
    
    // So sánh exercise (index 4)
    final exercise1 = int.tryParse(parts1[4]) ?? 0;
    final exercise2 = int.tryParse(parts2[4]) ?? 0;
    return exercise1.compareTo(exercise2);
  }

  /// So sánh highestProgress với một group dựa trên unit/lesson của group
  /// So sánh theo thứ tự: levelId → unitId (số unit) → lessonId (số lesson) → exerciseId (số exercise)
  /// Trả về: -1 nếu highestProgress < group, 0 nếu bằng, 1 nếu highestProgress > group
  Future<int> _compareHighestProgressWithGroup(
    HighestProgress highestProgress,
    String levelId,
    String group,
  ) async {
    try {
      // 1. So sánh levelId (phải cùng level)
      final levelCompare = highestProgress.levelId.toUpperCase().compareTo(levelId.toUpperCase());
      if (levelCompare != 0) {
        // Nếu khác level, so sánh theo thứ tự level
        const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
        final progressLevelIndex = levelOrder.indexOf(highestProgress.levelId.toUpperCase());
        final groupLevelIndex = levelOrder.indexOf(levelId.toUpperCase());
        if (progressLevelIndex != -1 && groupLevelIndex != -1) {
          final compare = progressLevelIndex.compareTo(groupLevelIndex);
          if (compare != 0) return compare;
        }
        return levelCompare;
      }

      // 2. Lấy units của group để so sánh unit
      final groupUnits = await getUnitsByGroup(levelId, group);
      if (groupUnits.isEmpty) {
        // Group không có unit, không thể so sánh
        return 0;
      }

      // Lấy unit đầu tiên của group (hoặc unit cao nhất nếu có nhiều)
      // Sắp xếp units theo order và lấy unit cao nhất
      groupUnits.sort((a, b) => a.order.compareTo(b.order));
      final highestUnitInGroup = groupUnits.last;

      // Parse số unit từ highestProgress.unitId (ví dụ: unit_a1_1 -> 1)
      final progressUnitParts = highestProgress.unitId.split('_');
      final progressUnitNum = progressUnitParts.length >= 3 
          ? int.tryParse(progressUnitParts[progressUnitParts.length - 1]) ?? 0
          : 0;

      // Parse số unit từ highestUnitInGroup.id (ví dụ: unit_a1_7 -> 7)
      final groupUnitParts = highestUnitInGroup.id.split('_');
      final groupUnitNum = groupUnitParts.length >= 3
          ? int.tryParse(groupUnitParts[groupUnitParts.length - 1]) ?? 0
          : 0;

      // So sánh unit (ưu tiên dùng order field nếu có, fallback về parse từ ID)
      final groupUnitOrder = highestUnitInGroup.order != 0 ? highestUnitInGroup.order : groupUnitNum;
      final unitCompare = progressUnitNum.compareTo(groupUnitOrder);
      if (unitCompare != 0) return unitCompare;

      // 3. Nếu cùng unit, so sánh lesson
      // Lấy lessons của unit cao nhất trong group
      final groupLessons = await _firestoreService.getLessonsByUnit(highestUnitInGroup.id);
      if (groupLessons.isEmpty) {
        // Group không có lesson, chỉ so sánh đến unit
        // Nếu đã cùng unit và group không có lesson, highestProgress đã vượt qua group
        // Nhưng vì đã so sánh unit ở trên và return nếu khác, nên đến đây là cùng unit
        // Group không có lesson = lesson 0, highestProgress có lesson > 0 → vượt qua
        final progressLessonParts = highestProgress.lessonId.split('_');
        final progressLessonNum = progressLessonParts.length >= 4
            ? int.tryParse(progressLessonParts[progressLessonParts.length - 1]) ?? 0
            : 0;
        // Nếu group không có lesson (coi là 0), highestProgress có lesson > 0 → vượt qua
        return progressLessonNum > 0 ? 1 : 0;
      }

      // Sắp xếp lessons theo order và lấy lesson cao nhất
      groupLessons.sort((a, b) => a.order.compareTo(b.order));
      final highestLessonInGroup = groupLessons.last;

      // Parse số lesson từ highestProgress.lessonId
      final progressLessonParts = highestProgress.lessonId.split('_');
      final progressLessonNum = progressLessonParts.length >= 4
          ? int.tryParse(progressLessonParts[progressLessonParts.length - 1]) ?? 0
          : 0;

      // Parse số lesson từ highestLessonInGroup.id
      final groupLessonParts = highestLessonInGroup.id.split('_');
      final groupLessonNum = groupLessonParts.length >= 4
          ? int.tryParse(groupLessonParts[groupLessonParts.length - 1]) ?? 0
          : 0;

      // So sánh lesson (ưu tiên dùng order field nếu có, fallback về parse từ ID)
      final groupLessonOrder = highestLessonInGroup.order != 0 ? highestLessonInGroup.order : groupLessonNum;
      final lessonCompare = progressLessonNum.compareTo(groupLessonOrder);
      if (lessonCompare != 0) return lessonCompare;

      // 4. Nếu cùng lesson, so sánh exercise
      // Lấy exercises của lesson cao nhất trong group
      final groupExercises = await _firestoreService.getExercisesByLesson(highestLessonInGroup.id);
      if (groupExercises.isEmpty) {
        // Group không có exercise, chỉ so sánh đến lesson
        // Parse số exercise từ highestProgress.exerciseId (ví dụ: exercise_a1_1_2_3 -> 3)
        final progressExerciseParts = highestProgress.exerciseId.split('_');
        final progressExerciseNum = progressExerciseParts.length >= 5
            ? int.tryParse(progressExerciseParts[progressExerciseParts.length - 1]) ?? 0
            : 0;
        // Nếu group không có exercise, coi như highestProgress đã vượt qua group
        return progressExerciseNum > 0 ? 1 : 0;
      }

      // Sắp xếp exercises và lấy exercise cao nhất
      groupExercises.sort((a, b) => _compareExerciseIds(a.id, b.id));
      final highestExerciseInGroup = groupExercises.last;

      // So sánh exercise
      return _compareExerciseIds(highestProgress.exerciseId, highestExerciseInGroup.id);
    } catch (e) {
      print('Error comparing highestProgress with group: $e');
      return 0;
    }
  }
  
  /// Lấy exercise ID cao nhất trong một group
  Future<String?> _getHighestExerciseIdInGroup(String levelId, String group) async {
    try {
      final exercises = await getExercisesByGroup(levelId, group);
      if (exercises.isEmpty) return null;
      
      // Sắp xếp và lấy exercise cuối cùng (cao nhất)
      exercises.sort((a, b) => _compareExerciseIds(a.id, b.id));
      return exercises.last.id;
    } catch (e) {
      return null;
    }
  }

  /// Lấy units của level (có cache)
  Future<List<UnitModel>> _getUnitsByLevelCached(String levelId) async {
    if (!_cachedUnitsByLevel.containsKey(levelId)) {
      _cachedUnitsByLevel[levelId] = await _firestoreService.getUnitsByLevel(levelId);
    }
    return _cachedUnitsByLevel[levelId]!;
  }

  /// Lấy tất cả units trong một group
  /// Hỗ trợ cả groupUnits collection (groupId) và logic cũ (unit.group)
  Future<List<UnitModel>> getUnitsByGroup(
    String levelId,
    String group,
  ) async {
    try {
      // Thử lấy từ groupUnits collection trước
      final groupUnit = await _groupUnitService.getGroupUnit(group);
      if (groupUnit != null) {
        // Lấy units từ groupUnit
        final allUnits = await _getUnitsByLevelCached(levelId);
        final unitMap = <String, UnitModel>{};
        for (final unit in allUnits) {
          unitMap[unit.id] = unit;
        }
        
        final units = groupUnit.units
            .map((unitId) => unitMap[unitId])
            .where((unit) => unit != null)
            .cast<UnitModel>()
            .toList();
        
        units.sort((a, b) => a.order.compareTo(b.order));
        return units;
      }
      
      // Fallback: sử dụng logic cũ (unit.groupId)
      final allUnits = await _getUnitsByLevelCached(levelId);
      return allUnits
          .where((unit) => unit.groupId == group)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      throw Exception('Error fetching units by group: $e');
    }
  }

  /// Lấy danh sách tất cả groups trong một level, sắp xếp theo order
  /// Ưu tiên lấy từ groupUnits collection, fallback về unit.groupId/group
  Future<List<String>> getAllGroups(String levelId) async {
    try {
      // Thử lấy từ groupUnits collection trước
      final groupUnits = await _groupUnitService.getGroupUnitsByLevel(levelId);
      if (groupUnits.isNotEmpty) {
        return groupUnits.map((gu) => gu.id).toList();
      }
      
      // Fallback: sử dụng logic cũ từ units
      final allUnits = await _getUnitsByLevelCached(levelId);
      final groups = <String>{};
      
      for (final unit in allUnits) {
        if (unit.groupId != null && unit.groupId!.isNotEmpty) {
          groups.add(unit.groupId!);
        }
      }
      
      final groupsList = groups.toList();
      
      // Sắp xếp groups theo số (nếu là số) hoặc alphabet
      groupsList.sort((a, b) {
        final aNum = int.tryParse(a);
        final bNum = int.tryParse(b);
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        return a.compareTo(b);
      });
      
      return groupsList;
    } catch (e) {
      throw Exception('Error fetching all groups: $e');
    }
  }

  /// Lấy tất cả exercises từ tất cả units trong một group
  /// Sắp xếp theo unit order, lesson order, và exercise order
  Future<List<ExerciseModel>> getExercisesByGroup(
    String levelId,
    String group, {
    String? languageCode,
  }) async {
    try {
      final units = await getUnitsByGroup(levelId, group);
      if (units.isEmpty) return [];

      final unitIds = units.map((unit) => unit.id).toList();
      final allExercises = await _firestoreService.getExercisesByUnits(
        unitIds,
        languageCode: languageCode,
      );

      // Tạo map để tra cứu unit order nhanh
      final unitOrderMap = <String, int>{};
      for (final unit in units) {
        unitOrderMap[unit.id] = unit.order;
      }

      // Sắp xếp exercises: theo unit order, sau đó parse từ exercise ID
      allExercises.sort((a, b) {
        // So sánh unit order trước
        final aUnitOrder = unitOrderMap[a.unitId] ?? 0;
        final bUnitOrder = unitOrderMap[b.unitId] ?? 0;
        if (aUnitOrder != bUnitOrder) {
          return aUnitOrder.compareTo(bUnitOrder);
        }

        // Nếu cùng unit, parse lesson và exercise từ ID
        final aParts = a.id.split('_');
        final bParts = b.id.split('_');
        
        if (aParts.length >= 4 && bParts.length >= 4) {
          final aLesson = int.tryParse(aParts[3]) ?? 0;
          final bLesson = int.tryParse(bParts[3]) ?? 0;
          if (aLesson != bLesson) {
            return aLesson.compareTo(bLesson);
          }
        }

        if (aParts.length >= 5 && bParts.length >= 5) {
          final aExercise = int.tryParse(aParts[4]) ?? 0;
          final bExercise = int.tryParse(bParts[4]) ?? 0;
          return aExercise.compareTo(bExercise);
        }

        return 0;
      });

      return allExercises;
    } catch (e) {
      throw Exception('Error fetching exercises by group: $e');
    }
  }

  /// Xác định group hiện tại dựa vào highestProgress.groupId hoặc unit.groupId
  Future<String?> getCurrentGroup(
    HighestProgress? highestProgress,
    String levelId,
  ) async {
    if (highestProgress == null) return null;

    try {
      // Ưu tiên sử dụng groupId từ highestProgress
      if (highestProgress.groupId != null) {
        return highestProgress.groupId;
      }
      
      // Fallback: lấy từ unit.groupId
      final unit = await _firestoreService.getUnit(highestProgress.unitId);
      if (unit == null || unit.levelId != levelId) return null;
      
      return unit.groupId;
    } catch (e) {
      return null;
    }
  }

  /// Xác định group "Ôn tập" (group đã hoàn thành - group trước group "Tiếp tục luyện tập")
  Future<String?> getReviewGroup(
    String levelId,
    HighestProgress? highestProgress,
  ) async {
    try {
      final allGroups = await getAllGroups(levelId);
      if (allGroups.isEmpty) return null;

      // Nếu chưa có progress, không có group để ôn tập
      if (highestProgress == null) {
        return null;
      }

      // Lấy group "Tiếp tục luyện tập"
      final continueGroup = await getContinueGroup(levelId, highestProgress);
      if (continueGroup == null) {
        return null;
      }
      
      // Tìm group trước group "Tiếp tục luyện tập"
      final continueIndex = allGroups.indexOf(continueGroup);
      if (continueIndex <= 0) {
        // Đang ở group đầu tiên, không có group để ôn tập
        return null;
      }

      return allGroups[continueIndex - 1];
    } catch (e) {
      return null;
    }
  }

  /// Xác định group "Tiếp tục luyện tập" 
  /// Group hiện tại nếu chưa hoàn thành, hoặc group tiếp theo nếu đã hoàn thành group hiện tại
  Future<String?> getContinueGroup(
    String levelId,
    HighestProgress? highestProgress,
  ) async {
    try {
      final allGroups = await getAllGroups(levelId);
      if (allGroups.isEmpty) return null;

      // Nếu chưa có progress, trả về group đầu tiên
      if (highestProgress == null) {
        return allGroups.first;
      }

      // Lấy group hiện tại
      final currentGroup = await getCurrentGroup(highestProgress, levelId);
      if (currentGroup == null) {
        return allGroups.first;
      }
      
      // Kiểm tra xem group hiện tại đã hoàn thành chưa
      final highestExerciseInCurrentGroup = await _getHighestExerciseIdInGroup(levelId, currentGroup);
      if (highestExerciseInCurrentGroup == null) {
        // Group không có exercises, trả về group hiện tại
        return currentGroup;
      }
      
      // So sánh highestProgress với exercise cao nhất trong group hiện tại
      final comparison = _compareExerciseIds(highestProgress.exerciseId, highestExerciseInCurrentGroup);
      
      if (comparison >= 0) {
        // Đã hoàn thành group hiện tại, trả về group tiếp theo
        final currentIndex = allGroups.indexOf(currentGroup);
        if (currentIndex >= 0 && currentIndex < allGroups.length - 1) {
          return allGroups[currentIndex + 1];
        }
        // Đã ở group cuối cùng, trả về group hiện tại
        return currentGroup;
      } else {
        // Chưa hoàn thành group hiện tại, trả về group hiện tại
        return currentGroup;
      }
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra group có unlock không (tối ưu với highestProgress)
  Future<bool> isGroupUnlocked(
    String levelId,
    String group,
    UserProgressModel progress,
    HighestProgress? highestProgress,
  ) async {
    try {
      final allGroups = await getAllGroups(levelId);
      if (allGroups.isEmpty) return false;

      final groupIndex = allGroups.indexOf(group);
      
      // Group đầu tiên luôn unlock
      if (groupIndex == 0) {
        print('DEBUG isGroupUnlocked: Group $group is first group, unlocking');
        return true;
      }

      // Nếu không tìm thấy group trong danh sách, khóa
      if (groupIndex < 0) {
        print('DEBUG isGroupUnlocked: Group $group not found in groups list, locking');
        return false;
      }

      final previousGroup = allGroups[groupIndex - 1];
      print('DEBUG isGroupUnlocked: Checking group $group (index $groupIndex), previousGroup: $previousGroup');

      // Kiểm tra dựa vào highestProgress: so sánh với previousGroup
      if (highestProgress != null) {
        // Thử lấy exercise cao nhất trong previousGroup trước
        final highestExerciseInPreviousGroup = await _getHighestExerciseIdInGroup(levelId, previousGroup);
        
        if (highestExerciseInPreviousGroup != null) {
          // Group có exercise: so sánh highestProgress với exercise cao nhất trong group trước
          final comparison = _compareExerciseIds(highestProgress.exerciseId, highestExerciseInPreviousGroup);
          
          print('DEBUG isGroupUnlocked: highestProgress.exerciseId: ${highestProgress.exerciseId}, highestExerciseInPreviousGroup: $highestExerciseInPreviousGroup, comparison: $comparison');
          
          // Nếu highestProgress >= exercise cao nhất trong previousGroup → unlock
          if (comparison >= 0) {
            print('DEBUG isGroupUnlocked: Unlocking $group because highestProgress >= highestExerciseInPreviousGroup');
            return true;
          } else {
            print('DEBUG isGroupUnlocked: Locking $group because highestProgress < highestExerciseInPreviousGroup');
            return false;
          }
        } else {
          // Group không có exercise: so sánh dựa trên unit/lesson của group
          final comparison = await _compareHighestProgressWithGroup(highestProgress, levelId, previousGroup);
          
          print('DEBUG isGroupUnlocked: previousGroup has no exercises, comparing highestProgress with group. highestProgress: ${highestProgress.exerciseId}, comparison: $comparison');
          
          // Nếu highestProgress >= previousGroup (dựa trên unit/lesson) → unlock
          if (comparison >= 0) {
            print('DEBUG isGroupUnlocked: Unlocking $group because highestProgress >= previousGroup (based on unit/lesson)');
            return true;
          } else {
            print('DEBUG isGroupUnlocked: Locking $group because highestProgress < previousGroup (based on unit/lesson)');
            return false;
          }
        }
      }

      // Fallback: Nếu không có highestProgress, kiểm tra dựa vào exerciseHistory
      final previousUnits = await getUnitsByGroup(levelId, previousGroup);
      if (previousUnits.isEmpty) {
        print('DEBUG isGroupUnlocked: previousUnits is empty, locking $group');
        return false;
      }

      final previousUnitIds = previousUnits.map((u) => u.id).toSet();
      final previousExercises = await getExercisesByGroup(levelId, previousGroup);
      
      if (previousExercises.isEmpty) {
        // PreviousGroup không có exercises: so sánh dựa trên unit/lesson
        // Nếu không có highestProgress, không thể so sánh → lock
        if (highestProgress == null) {
          print('DEBUG isGroupUnlocked: previousExercises is empty and no highestProgress, locking $group');
          return false;
        }
        // Có highestProgress: so sánh với previousGroup
        final comparison = await _compareHighestProgressWithGroup(highestProgress, levelId, previousGroup);
        print('DEBUG isGroupUnlocked: previousExercises is empty, comparing highestProgress with previousGroup. comparison: $comparison');
        return comparison >= 0;
      }

      // Lấy exercise cao nhất trong previousGroup để so sánh
      previousExercises.sort((a, b) => _compareExerciseIds(a.id, b.id));
      final highestExerciseId = previousExercises.last.id;
      
      // Kiểm tra xem đã hoàn thành exercise cao nhất chưa
      final hasCompletedHighestExercise = progress.exerciseHistory
          .any((item) => item.exerciseId == highestExerciseId && previousUnitIds.contains(item.unitId));
      
      print('DEBUG isGroupUnlocked: highestExerciseId: $highestExerciseId, hasCompletedHighestExercise: $hasCompletedHighestExercise');
      return hasCompletedHighestExercise;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra group đã hoàn thành chưa
  /// Group được coi là hoàn thành khi highestProgress >= exercise cao nhất trong group
  Future<bool> isGroupCompleted(
    String levelId,
    String group,
    UserProgressModel progress,
    HighestProgress? highestProgress,
  ) async {
    try {
      final units = await getUnitsByGroup(levelId, group);
      if (units.isEmpty) return false;

      // Kiểm tra dựa vào highestProgress: so sánh với exercise cao nhất trong group
      if (highestProgress != null) {
        final highestExerciseInGroup = await _getHighestExerciseIdInGroup(levelId, group);
        
        if (highestExerciseInGroup != null) {
          // So sánh highestProgress với exercise cao nhất trong group
          final comparison = _compareExerciseIds(highestProgress.exerciseId, highestExerciseInGroup);
          
          // Nếu highestProgress >= exercise cao nhất trong group → group đã hoàn thành
          return comparison >= 0;
        }
      }

      // Fallback: Check xem đã hoàn thành exercise cao nhất trong group chưa
      final exercises = await getExercisesByGroup(levelId, group);
      if (exercises.isEmpty) return false;

      // Sắp xếp và lấy exercise cao nhất
      exercises.sort((a, b) => _compareExerciseIds(a.id, b.id));
      final highestExerciseId = exercises.last.id;
      
      final unitIds = units.map((u) => u.id).toSet();
      final hasCompletedHighestExercise = progress.exerciseHistory
          .any((item) => item.exerciseId == highestExerciseId && unitIds.contains(item.unitId));
      
      return hasCompletedHighestExercise;
    } catch (e) {
      return false;
    }
  }

  /// Lấy tất cả UnitGroups cho một level với thông tin unlock và type
  /// Sử dụng collection groupUnits thay vì tính toán từ units
  Future<List<UnitGroup>> getAllUnitGroups(
    String levelId,
    UserProgressModel progress,
    HighestProgress? highestProgress,
  ) async {
    try {
      // Load groupUnits từ collection
      debugPrint('🔍 getAllUnitGroups: Loading groupUnits for level $levelId');
      List<GroupUnitModel> groupUnits;
      try {
        groupUnits = await _groupUnitService.getGroupUnitsByLevel(levelId);
        debugPrint('🔍 getAllUnitGroups: Found ${groupUnits.length} groupUnits');
      } catch (e) {
        debugPrint('❌ getAllUnitGroups: Error loading groupUnits: $e');
        // Nếu là lỗi permission, có thể do security rules chưa được cấu hình
        // Trả về empty list để fallback về units view
        if (e.toString().contains('permission-denied') || e.toString().contains('permissions')) {
          debugPrint('⚠️ getAllUnitGroups: Permission denied - Firestore security rules may need to be updated for groupUnits collection');
        }
        return [];
      }
      
      if (groupUnits.isEmpty) {
        debugPrint('⚠️ getAllUnitGroups: No groupUnits found in collection for level $levelId');
        return [];
      }

      // Logic mới: Xác định group hiện tại & group đã hoàn thành
      // CHỈ dùng highestProgress nếu levelId khớp với level đang load
      GroupUnitModel? completedGroup;
      int? continueGroupIndex;
      
      if (highestProgress != null && highestProgress.levelId == levelId) {
        GroupUnitModel? currentGroup;

        // Ưu tiên dùng groupId từ highestProgress
        if (highestProgress.groupId != null) {
          currentGroup = groupUnits
              .where((groupUnit) => groupUnit.id == highestProgress.groupId)
              .cast<GroupUnitModel?>()
              .firstWhere((groupUnit) => groupUnit != null, orElse: () => null);
        }

        // Fallback: tìm group theo unitId
        if (currentGroup == null && highestProgress.unitId.isNotEmpty) {
          currentGroup = groupUnits
              .where((groupUnit) => groupUnit.units.contains(highestProgress.unitId))
              .cast<GroupUnitModel?>()
              .firstWhere((groupUnit) => groupUnit != null, orElse: () => null);
        }

        if (currentGroup != null) {
          final highestExerciseId = currentGroup.highestExerciseId;
          final isCompleted = highestExerciseId != null &&
              _compareExerciseIds(highestProgress.exerciseId, highestExerciseId) >= 0;

          if (isCompleted) {
            completedGroup = currentGroup;
            continueGroupIndex = currentGroup.index + 1;
            debugPrint('🔍 currentGroup=${currentGroup.id} completed, continueGroupIndex=$continueGroupIndex');
          } else {
            continueGroupIndex = currentGroup.index;
            debugPrint('🔍 currentGroup=${currentGroup.id} not completed, continueGroupIndex=$continueGroupIndex');
          }
        } else {
          // Fallback cuối: tìm group có highestExerciseId khớp với highestProgress.exerciseId
          for (final groupUnit in groupUnits) {
            if (groupUnit.highestExerciseId != null &&
                groupUnit.highestExerciseId == highestProgress.exerciseId) {
              completedGroup = groupUnit;
              debugPrint('🔍 Found completedGroup: ${groupUnit.id} (index=${groupUnit.index})');
              break;
            }
          }

          if (completedGroup != null) {
            continueGroupIndex = completedGroup.index + 1;
            debugPrint('🔍 continueGroupIndex=$continueGroupIndex (after completedGroup ${completedGroup.id})');
          } else {
            continueGroupIndex = 0;
            debugPrint('🔍 No currentGroup/completedGroup found, continueGroupIndex=0');
          }
        }
      } else {
        // Không có highestProgress hoặc levelId khác → group đầu tiên (index 0) là "Tiếp tục luyện tập"
        if (highestProgress != null) {
          debugPrint('🔍 highestProgress.levelId (${highestProgress.levelId}) != levelId ($levelId), treating as new level - unlock first group');
        } else {
          debugPrint('🔍 No highestProgress, unlock first group');
        }
        continueGroupIndex = 0;
      }
      
      debugPrint('🔍 Final continueGroupIndex=$continueGroupIndex for level $levelId');

      // Load units cho tất cả groups
      final allUnits = await _getUnitsByLevelCached(levelId);
      final unitMap = <String, UnitModel>{};
      for (final unit in allUnits) {
        unitMap[unit.id] = unit;
      }

      final unitGroups = <UnitGroup>[];

      for (final groupUnit in groupUnits) {
        debugPrint('🔍 Processing groupUnit: id=${groupUnit.id}, index=${groupUnit.index}, units=${groupUnit.units.length}');
        
        // Lấy units từ groupUnit
        final units = groupUnit.units
            .map((unitId) => unitMap[unitId])
            .where((unit) => unit != null)
            .cast<UnitModel>()
            .toList();

        debugPrint('  ✅ Found ${units.length} units for group ${groupUnit.id} (expected ${groupUnit.units.length})');
        
        // Nếu không có units nào match, log warning nhưng vẫn tạo group
        if (units.isEmpty && groupUnit.units.isNotEmpty) {
          debugPrint('  ⚠️ Warning: No units found for group ${groupUnit.id}. Expected units: ${groupUnit.units.join(", ")}');
        }

        // Logic mới: Kiểm tra completed dựa trên highestExerciseId
        bool isCompleted = false;
        if (completedGroup != null && groupUnit.id == completedGroup.id) {
          isCompleted = true;
        }

        // Xác định type và unlock status dựa trên logic mới
        GroupType type;
        bool isUnlocked;

        if (continueGroupIndex == null) {
          // Không có continueGroupIndex → group đầu tiên enable
          isUnlocked = groupUnit.index == 0;
          type = groupUnit.index == 0 ? GroupType.continuePractice : GroupType.locked;
          debugPrint('  📌 No continueGroupIndex: group ${groupUnit.id} isUnlocked=$isUnlocked, type=$type');
        } else {
          // Phân loại groups dựa trên index so với continueGroupIndex
          if (completedGroup != null && groupUnit.id == completedGroup.id) {
            // Group đã hoàn thành → review
            type = GroupType.review;
            isUnlocked = true;
          } else if (groupUnit.index == continueGroupIndex) {
            // Group tiếp theo (sau group đã hoàn thành hoặc group đầu tiên) → continuePractice
            type = GroupType.continuePractice;
            isUnlocked = true;
          } else if (groupUnit.index < continueGroupIndex) {
            // Group trước continueGroup → review (nếu không phải completedGroup)
            type = GroupType.review;
            isUnlocked = true;
          } else {
            // Group sau continueGroup → locked
            type = GroupType.locked;
            isUnlocked = false;
          }
          debugPrint('  📌 continueGroupIndex=$continueGroupIndex, completedGroup=${completedGroup?.id}: group ${groupUnit.id} (index=${groupUnit.index}) isUnlocked=$isUnlocked, type=$type, isCompleted=$isCompleted');
        }

        final unitGroup = UnitGroup.fromUnits(
          levelId: levelId,
          group: groupUnit.id, // Use groupUnit.id instead of group string
          units: units,
          order: groupUnit.index + 1,
          isUnlocked: isUnlocked,
          isCompleted: isCompleted,
          type: type,
          title: groupUnit.title, // Pass group title from GroupUnitModel
        );

        debugPrint('  ✅ Created UnitGroup: ${unitGroup.group}, type=${unitGroup.type}, units=${unitGroup.units.length}');
        unitGroups.add(unitGroup);
      }
      
      debugPrint('✅ Total unitGroups created: ${unitGroups.length}');

      return unitGroups;
    } catch (e) {
      throw Exception('Error fetching all unit groups: $e');
    }
  }
}

