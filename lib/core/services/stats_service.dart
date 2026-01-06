import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../core/constants/firebase_constants.dart';

/// Service để tính toán và quản lý stats (streak, XP)
class StatsService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tính XP dựa vào kết quả exercise
  /// - Exercise đúng: +10 XP
  /// - Exercise sai: +5 XP (khuyến khích thử lại)
  int calculateXP(bool isCorrect) {
    return isCorrect ? 10 : 5;
  }

  /// Tính streak mới dựa vào lastActiveDate và ngày hiện tại
  /// Logic:
  /// - Nếu hôm nay đã làm exercise → streak giữ nguyên
  /// - Nếu hôm qua đã làm exercise → streak + 1
  /// - Nếu không làm trong 1 ngày → reset về 1 (hoặc 0 nếu muốn)
  int calculateStreak(int currentStreak, DateTime? lastActiveDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Nếu chưa có lastActiveDate, đây là lần đầu tiên
    if (lastActiveDate == null) {
      return 1;
    }
    
    final lastActive = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    
    final daysDifference = today.difference(lastActive).inDays;
    
    if (daysDifference == 0) {
      // Hôm nay đã làm exercise rồi → giữ nguyên streak
      return currentStreak;
    } else if (daysDifference == 1) {
      // Hôm qua đã làm → tăng streak
      return currentStreak + 1;
    } else {
      // Không làm trong nhiều ngày → reset về 1
      return 1;
    }
  }

  /// Tính toán và cập nhật stats cho user
  Future<void> updateUserStats(
    String userId,
    bool isCorrect,
  ) async {
    // Lấy user hiện tại
    final userDoc = await _firestoreService.getUser(userId);
    if (userDoc == null) {
      throw Exception('User not found');
    }

    // Tính XP mới
    final xpGained = calculateXP(isCorrect);
    final newTotalXP = userDoc.totalXP + xpGained;

    // Tính streak mới
    final newStreak = calculateStreak(userDoc.streak, userDoc.lastActiveDate);

    // Lưu lên Firestore
    await _firestoreService.updateUserStats(
      userId,
      newTotalXP,
      newStreak,
      DateTime.now(),
    );
  }
}

