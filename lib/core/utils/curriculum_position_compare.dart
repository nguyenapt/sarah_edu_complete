import '../../models/progress_model.dart';
import '../../models/unit_model.dart';
import 'cefr_level_order.dart';

/// So sánh [HighestProgress] với một **unit** (Review: khóa unit nằm **sau** HP).
///
/// Thứ tự: **levelId** (CEFR) → **unitId** (order / suffix id). Cùng unit được coi là đã/chưa tới
/// (mở ôn toàn unit; chi tiết bài tập nằm sau HP vẫn trong cùng unit → mở).
class CurriculumPositionCompare {
  CurriculumPositionCompare._();

  static int _parseIdSuffix(String id, {int minParts = 3}) {
    final parts = id.split('_');
    if (parts.length < minParts) return 0;
    return int.tryParse(parts.last) ?? 0;
  }

  static int unitSortKey(UnitModel unit) {
    if (unit.order != 0) return unit.order;
    return _parseIdSuffix(unit.id);
  }

  static int _unitKeyFromId(String unitId) => _parseIdSuffix(unitId);

  /// Trả về `> 0` nếu [unit] nằm **sau** vị trí HP trong lộ trình → **khóa** ôn.
  /// `<= 0` → **mở**.
  static int compareHighestProgressToUnit(
    HighestProgress? hp,
    String catalogLevelId,
    UnitModel unit,
  ) {
    if (hp == null) return 1;

    final cat = normalizeCefrLevelId(catalogLevelId);
    final hpL = normalizeCefrLevelId(hp.levelId);
    final levelCmp = compareCefrLevel(hpL, cat);
    // User đã học cấp cao hơn cấp đang ôn
    if (levelCmp > 0) return -1;
    // HP chưa tới cấp này
    if (levelCmp < 0) return 1;

    // Cùng cấp: so unit (id / order)
    if (hp.unitId == unit.id) return -1;

    final hk = _unitKeyFromId(hp.unitId);
    final uk = unitSortKey(unit);
    return uk.compareTo(hk);
  }

  /// `true` = khóa. Khi không có HP: chỉ mở unit đầu tiên trong list đã sort.
  static bool isReviewUnitLocked(
    HighestProgress? hp,
    String catalogLevelId,
    UnitModel unit, {
    int sortedIndexInLevel = 0,
  }) {
    if (hp == null) return sortedIndexInLevel > 0;
    return compareHighestProgressToUnit(hp, catalogLevelId, unit) > 0;
  }
}
