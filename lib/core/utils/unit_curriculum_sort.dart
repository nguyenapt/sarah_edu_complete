import '../../models/unit_model.dart';

/// Thứ tự hiển thị unit: `order` (Firestore), tie-break `groupId`, rồi `id`.
int compareUnitsCurriculum(UnitModel a, UnitModel b) {
  final o = a.order.compareTo(b.order);
  if (o != 0) return o;
  final ga = a.groupId ?? '';
  final gb = b.groupId ?? '';
  final g = ga.compareTo(gb);
  if (g != 0) return g;
  return a.id.compareTo(b.id);
}

void sortUnitsCurriculum(List<UnitModel> units) {
  units.sort(compareUnitsCurriculum);
}
