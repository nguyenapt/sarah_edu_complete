import '../../models/level_model.dart';

/// Thứ tự CEFR chuẩn trong app.
const List<String> kCefrLevelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

String normalizeCefrLevelId(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'A1';
  return raw.trim().toUpperCase();
}

/// Chỉ số trong [kCefrLevelOrder], hoặc -1 nếu không khớp.
int cefrLevelIndex(String raw) {
  return kCefrLevelOrder.indexOf(normalizeCefrLevelId(raw));
}

/// So sánh hai level CEFR. Level không nằm trong danh sách xếp cuối, so theo id.
int compareCefrLevel(String a, String b) {
  final ia = cefrLevelIndex(a);
  final ib = cefrLevelIndex(b);
  if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
  if (ia >= 0) return -1;
  if (ib >= 0) return 1;
  return normalizeCefrLevelId(a).compareTo(normalizeCefrLevelId(b));
}

/// True nếu [levelId] không cao hơn [userMaxLevelId] (cùng scale CEFR).
bool isLevelAtOrBelowUserMax(String levelId, String userMaxLevelId) {
  return compareCefrLevel(levelId, userMaxLevelId) <= 0;
}

void sortLevelsByCefr(List<LevelModel> levels) {
  levels.sort((a, b) {
    final c = compareCefrLevel(a.id, b.id);
    if (c != 0) return c;
    return a.order.compareTo(b.order);
  });
}
