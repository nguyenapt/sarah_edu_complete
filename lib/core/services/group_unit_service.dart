import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/group_unit_model.dart';
import '../../core/constants/firebase_constants.dart';
import 'firestore_service.dart';

class GroupUnitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Lấy tất cả groupUnits theo level
  Future<List<GroupUnitModel>> getGroupUnitsByLevel(String levelId) async {
    try {
      debugPrint('🔍 getGroupUnitsByLevel: Querying groupUnits for levelId=$levelId');
      
      QuerySnapshot snapshot;
      try {
        // Thử query với orderBy (cần index)
        snapshot = await _firestore
            .collection(FirebaseConstants.groupUnitsCollection)
            .where('levelId', isEqualTo: levelId)
            .orderBy('index')
            .get();
      } catch (e) {
        // Nếu thiếu index, query không có orderBy và sort trong code
        if (e.toString().contains('index') || e.toString().contains('failed-precondition')) {
          debugPrint('⚠️ Index not found, querying without orderBy and sorting in code');
          final unsortedSnapshot = await _firestore
              .collection(FirebaseConstants.groupUnitsCollection)
              .where('levelId', isEqualTo: levelId)
              .get();
          
          // Sort trong code
          final docs = unsortedSnapshot.docs.toList();
          docs.sort((a, b) {
            final aIndex = a.data()['index'] ?? 0;
            final bIndex = b.data()['index'] ?? 0;
            return (aIndex as int).compareTo(bIndex as int);
          });
          
          // Tạo QuerySnapshot từ sorted docs (workaround)
          snapshot = unsortedSnapshot; // Sẽ sort lại sau khi parse
          
          // Parse và sort
          final groupUnits = <GroupUnitModel>[];
          for (final doc in docs) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                final groupUnit = GroupUnitModel.fromFirestore(data, doc.id);
                groupUnits.add(groupUnit);
              }
            } catch (e) {
              debugPrint('❌ Error parsing groupUnit ${doc.id}: $e');
            }
          }
          
          // Sort lại theo index
          groupUnits.sort((a, b) => a.index.compareTo(b.index));
          
          debugPrint('✅ getGroupUnitsByLevel: Successfully parsed ${groupUnits.length} groupUnits (sorted in code)');
          for (var gu in groupUnits) {
            debugPrint('  - ${gu.id}: index=${gu.index}, units=${gu.units.length}');
          }
          
          return groupUnits;
        } else {
          rethrow;
        }
      }

      debugPrint('🔍 getGroupUnitsByLevel: Found ${snapshot.docs.length} documents');
      
      final groupUnits = <GroupUnitModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final groupUnit = GroupUnitModel.fromFirestore(data, doc.id);
            groupUnits.add(groupUnit);
          }
        } catch (e) {
          debugPrint('❌ Error parsing groupUnit ${doc.id}: $e');
        }
      }
      
      debugPrint('✅ getGroupUnitsByLevel: Successfully parsed ${groupUnits.length} groupUnits');
      for (var gu in groupUnits) {
        debugPrint('  - ${gu.id}: index=${gu.index}, units=${gu.units.length}');
      }
      
      return groupUnits;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching groupUnits by level: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Error fetching groupUnits by level: $e');
    }
  }

  /// Lấy một groupUnit theo ID
  Future<GroupUnitModel?> getGroupUnit(String groupId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.groupUnitsCollection)
          .doc(groupId)
          .get();

      if (!doc.exists) return null;

      return GroupUnitModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Error fetching groupUnit: $e');
    }
  }

  /// Tìm groupUnit chứa unit này
  Future<GroupUnitModel?> getGroupUnitByUnitId(String unitId) async {
    try {
      // Lấy unit để biết levelId
      final unit = await _firestoreService.getUnit(unitId);
      if (unit == null) return null;

      // Lấy tất cả groupUnits của level đó
      final groupUnits = await getGroupUnitsByLevel(unit.levelId);

      // Tìm groupUnit chứa unit này
      for (final groupUnit in groupUnits) {
        if (groupUnit.units.contains(unitId)) {
          return groupUnit;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error finding groupUnit by unitId: $e');
    }
  }

  /// Lấy index của groupUnit
  Future<int?> getGroupIndex(String groupId) async {
    try {
      final groupUnit = await getGroupUnit(groupId);
      return groupUnit?.index;
    } catch (e) {
      return null;
    }
  }
}

