import '../../models/unit_model.dart';
import '../../models/unit_group_model.dart';
import '../../models/exercise_model.dart';
import '../../models/progress_model.dart';
import 'firestore_service.dart';

/// Service để quản lý nhóm unit và logic unlock
class UnitGroupService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Lấy tất cả units trong một group
  Future<List<UnitModel>> getUnitsByGroup(
    String levelId,
    String group,
  ) async {
    try {
      final allUnits = await _firestoreService.getUnitsByLevel(levelId);
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
      final allUnits = await _firestoreService.getUnitsByLevel(levelId);
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

  /// Xác định group "Ôn tập" (group trước group hiện tại, hoặc group đầu tiên nếu chưa có progress)
  Future<String?> getReviewGroup(
    String levelId,
    HighestProgress? highestProgress,
  ) async {
    try {
      final allGroups = await getAllGroups(levelId);
      if (allGroups.isEmpty) return null;

      // Nếu chưa có progress, trả về group đầu tiên
      if (highestProgress == null) {
        return allGroups.isNotEmpty ? allGroups.first : null;
      }

      // Lấy group hiện tại
      final currentGroup = await getCurrentGroup(highestProgress, levelId);
      if (currentGroup == null) {
        return allGroups.first;
      }

      // Tìm group trước group hiện tại
      final currentIndex = allGroups.indexOf(currentGroup);
      if (currentIndex <= 0) {
        // Đang ở group đầu tiên, không có group để ôn tập
        return null;
      }

      return allGroups[currentIndex - 1];
    } catch (e) {
      return null;
    }
  }

  /// Xác định group "Tiếp tục luyện tập" (group chứa unit trong highestProgress.unitId)
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
      return currentGroup ?? allGroups.first;
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
      if (groupIndex == 0) return true;

      // Nếu không có group trước đó, unlock
      if (groupIndex < 0) return false;

      final previousGroup = allGroups[groupIndex - 1];

      // Tối ưu: Nếu highestProgress đã vượt qua tất cả units trong group trước đó
      if (highestProgress != null) {
        final previousUnits = await getUnitsByGroup(levelId, previousGroup);
        if (previousUnits.isNotEmpty) {
          // Lấy unit hiện tại từ highestProgress
          final currentUnit = await _firestoreService.getUnit(highestProgress.unitId);
          if (currentUnit != null && currentUnit.levelId == levelId) {
            // Kiểm tra xem highestProgress đã vượt qua tất cả units trong previousGroup chưa
            final previousUnitsOrder = previousUnits.map((u) => u.order).toList()..sort();
            final maxPreviousOrder = previousUnitsOrder.isNotEmpty 
                ? previousUnitsOrder.last 
                : 0;
            
            // Nếu unit hiện tại có order lớn hơn tất cả units trong previousGroup
            if (currentUnit.order > maxPreviousOrder) {
              return true;
            }
          }
        }
      }

      // Fallback: Check exerciseHistory để đếm số exercises đã hoàn thành trong previousGroup
      final previousUnits = await getUnitsByGroup(levelId, previousGroup);
      if (previousUnits.isEmpty) return true;

      final previousUnitIds = previousUnits.map((u) => u.id).toSet();
      final previousExercises = await getExercisesByGroup(levelId, previousGroup);
      
      if (previousExercises.isEmpty) return true;

      // Đếm số exercises đã hoàn thành trong previousGroup
      final completedExerciseIds = progress.exerciseHistory
          .where((item) => previousUnitIds.contains(item.unitId))
          .map((item) => item.exerciseId)
          .toSet();

      // Unlock nếu đã hoàn thành tất cả exercises trong previousGroup
      final allExerciseIds = previousExercises.map((e) => e.id).toSet();
      return completedExerciseIds.length >= allExerciseIds.length;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra group đã hoàn thành chưa
  Future<bool> isGroupCompleted(
    String levelId,
    String group,
    UserProgressModel progress,
    HighestProgress? highestProgress,
  ) async {
    try {
      final units = await getUnitsByGroup(levelId, group);
      if (units.isEmpty) return false;

      // Tối ưu: Nếu highestProgress đã vượt qua tất cả units trong group
      if (highestProgress != null) {
        final currentUnit = await _firestoreService.getUnit(highestProgress.unitId);
        if (currentUnit != null && currentUnit.levelId == levelId) {
          final groupUnitsOrder = units.map((u) => u.order).toList()..sort();
          final maxGroupOrder = groupUnitsOrder.isNotEmpty ? groupUnitsOrder.last : 0;
          
          // Nếu highestProgress đã vượt qua tất cả units trong group
          if (currentUnit.order > maxGroupOrder) {
            return true;
          }
        }
      }

      // Fallback: Check tất cả exercises trong group đã có trong exerciseHistory
      final exercises = await getExercisesByGroup(levelId, group);
      if (exercises.isEmpty) return false;

      final completedExerciseIds = progress.exerciseHistory
          .where((item) => units.any((u) => u.id == item.unitId))
          .map((item) => item.exerciseId)
          .toSet();

      final allExerciseIds = exercises.map((e) => e.id).toSet();
      return completedExerciseIds.length >= allExerciseIds.length;
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
      final groups = await getAllGroups(levelId);
      if (groups.isEmpty) return [];

      final reviewGroup = await getReviewGroup(levelId, highestProgress);
      final continueGroup = await getContinueGroup(levelId, highestProgress);

      final unitGroups = <UnitGroup>[];

      for (int i = 0; i < groups.length; i++) {
        final group = groups[i];
        final units = await getUnitsByGroup(levelId, group);
        
        final isUnlocked = await isGroupUnlocked(
          levelId,
          group,
          progress,
          highestProgress,
        );
        
        final isCompleted = await isGroupCompleted(
          levelId,
          group,
          progress,
          highestProgress,
        );

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

