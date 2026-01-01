import 'unit_model.dart';

enum GroupType {
  review, // Ôn tập
  continuePractice, // Tiếp tục luyện tập
  locked, // Bị khóa
  normal, // Bình thường (đã unlock nhưng không phải review/continue)
}

class UnitGroup {
  final String levelId;
  final String group;
  final List<UnitModel> units;
  final int order; // Thứ tự của group
  final bool isUnlocked;
  final bool isCompleted; // Group đã hoàn thành chưa (dựa vào highestProgress hoặc exerciseHistory)
  final String displayName; // "Ôn tập", "Tiếp tục luyện tập", etc.
  final GroupType type; // REVIEW, CONTINUE, LOCKED, NORMAL

  UnitGroup({
    required this.levelId,
    required this.group,
    required this.units,
    required this.order,
    required this.isUnlocked,
    required this.isCompleted,
    required this.displayName,
    required this.type,
  });

  /// Tạo UnitGroup từ danh sách units
  factory UnitGroup.fromUnits({
    required String levelId,
    required String group,
    required List<UnitModel> units,
    required int order,
    required bool isUnlocked,
    required bool isCompleted,
    required GroupType type,
  }) {
    // Xác định displayName dựa vào type
    String displayName;
    switch (type) {
      case GroupType.review:
        displayName = 'Ôn tập';
        break;
      case GroupType.continuePractice:
        displayName = 'Tiếp tục luyện tập';
        break;
      case GroupType.locked:
        displayName = 'Khóa';
        break;
      case GroupType.normal:
        displayName = 'Nhóm $group';
        break;
    }

    return UnitGroup(
      levelId: levelId,
      group: group,
      units: units,
      order: order,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      displayName: displayName,
      type: type,
    );
  }
}

