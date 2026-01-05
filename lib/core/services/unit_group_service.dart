import '../../models/unit_model.dart';
import '../../models/unit_group_model.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import 'firestore_service.dart';

/// Service để quản lý nhóm unit và logic unlock
class UnitGroupService {
  final FirestoreService _firestoreService = FirestoreService();
  
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
  Future<List<UnitModel>> getUnitsByGroup(
    String levelId,
    String group,
  ) async {
    try {
      // Sử dụng cache thay vì query lại
      final allUnits = await _getUnitsByLevelCached(levelId);
      return allUnits
          .where((unit) => unit.group == group)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      throw Exception('Error fetching units by group: $e');
    }
  }

  /// Lấy danh sách tất cả groups trong một level, sắp xếp theo order
  Future<List<String>> getAllGroups(String levelId) async {
    try {
      // Sử dụng cache thay vì query lại
      final allUnits = await _getUnitsByLevelCached(levelId);
      final groups = allUnits
          .where((unit) => unit.group != null && unit.group!.isNotEmpty)
          .map((unit) => unit.group!)
          .toSet()
          .toList();
      
      // Sắp xếp groups theo số (nếu là số) hoặc alphabet
      groups.sort((a, b) {
        final aNum = int.tryParse(a);
        final bNum = int.tryParse(b);
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        return a.compareTo(b);
      });
      
      return groups;
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

  /// Xác định group hiện tại dựa vào highestProgress.unitId
  Future<String?> getCurrentGroup(
    HighestProgress? highestProgress,
    String levelId,
  ) async {
    if (highestProgress == null) return null;

    try {
      final unit = await _firestoreService.getUnit(highestProgress.unitId);
      if (unit == null || unit.levelId != levelId) return null;
      
      return unit.group;
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

      // Kiểm tra dựa vào highestProgress: so sánh với exercise cao nhất trong previousGroup
      if (highestProgress != null) {
        final highestExerciseInPreviousGroup = await _getHighestExerciseIdInGroup(levelId, previousGroup);
        
        if (highestExerciseInPreviousGroup != null) {
          // So sánh highestProgress với exercise cao nhất trong group trước
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
        }
      }

      // Fallback: Nếu không có highestProgress hoặc không tìm thấy exercise cao nhất
      // Kiểm tra dựa vào exerciseHistory
      final previousUnits = await getUnitsByGroup(levelId, previousGroup);
      if (previousUnits.isEmpty) {
        print('DEBUG isGroupUnlocked: previousUnits is empty, unlocking $group (may be incorrect)');
        return true;
      }

      final previousUnitIds = previousUnits.map((u) => u.id).toSet();
      final previousExercises = await getExercisesByGroup(levelId, previousGroup);
      
      if (previousExercises.isEmpty) {
        print('DEBUG isGroupUnlocked: previousExercises is empty, unlocking $group (may be incorrect)');
        return true;
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
  Future<List<UnitGroup>> getAllUnitGroups(
    String levelId,
    UserProgressModel progress,
    HighestProgress? highestProgress,
  ) async {
    try {
      // Load units của level một lần và cache
      await _getUnitsByLevelCached(levelId);
      
      // Parallel loading: load groups, reviewGroup, continueGroup song song
      final groupResults = await Future.wait([
        getAllGroups(levelId),
        getReviewGroup(levelId, highestProgress),
        getContinueGroup(levelId, highestProgress),
      ]);
      
      final groups = groupResults[0] as List<String>;
      final reviewGroup = groupResults[1] as String?;
      final continueGroup = groupResults[2] as String?;
      
      if (groups.isEmpty) return [];

      // Parallel loading: load units cho tất cả groups cùng lúc
      final unitsFutures = groups.map((group) => getUnitsByGroup(levelId, group));
      final allUnitsList = await Future.wait(unitsFutures);

      // Parallel loading: check unlock và completed cho tất cả groups cùng lúc
      final unlockFutures = groups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return isGroupUnlocked(levelId, group, progress, highestProgress);
      });
      
      final completedFutures = groups.asMap().entries.map((entry) {
        final index = entry.key;
        final group = entry.value;
        return isGroupCompleted(levelId, group, progress, highestProgress);
      });
      
      final unlockResults = await Future.wait(unlockFutures);
      final completedResults = await Future.wait(completedFutures);

      final unitGroups = <UnitGroup>[];

      for (int i = 0; i < groups.length; i++) {
        final group = groups[i];
        final units = allUnitsList[i];
        final isUnlocked = unlockResults[i];
        final isCompleted = completedResults[i];

        // Xác định type
        GroupType type;
        if (group == reviewGroup) {
          type = GroupType.review;
        } else if (group == continueGroup) {
          type = GroupType.continuePractice;
        } else if (!isUnlocked) {
          type = GroupType.locked;
        } else {
          type = GroupType.normal;
        }
        
        // Debug log
        print('Group: $group, isUnlocked: $isUnlocked, type: $type, reviewGroup: $reviewGroup, continueGroup: $continueGroup');

        final unitGroup = UnitGroup.fromUnits(
          levelId: levelId,
          group: group,
          units: units,
          order: i + 1,
          isUnlocked: isUnlocked,
          isCompleted: isCompleted,
          type: type,
        );

        unitGroups.add(unitGroup);
      }

      return unitGroups;
    } catch (e) {
      throw Exception('Error fetching all unit groups: $e');
    }
  }
}

