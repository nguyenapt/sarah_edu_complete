import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String currentLevel; // A1, A2, B1, B2, C1, C2
  final int totalXP;
  final int streak;
  final DateTime? lastActiveDate;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.currentLevel,
    this.totalXP = 0,
    this.streak = 0,
    this.lastActiveDate,
  });

  // Helper function để convert timestamp từ Firestore (hỗ trợ cả Timestamp và int)
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      // Nếu là int, có thể là milliseconds hoặc seconds
      // Thử milliseconds trước (timestamp thường > 1000000000000)
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    return null;
  }

  // Convert từ Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      currentLevel: data['currentLevel'] ?? 'A1',
      totalXP: data['totalXP'] ?? 0,
      streak: data['streak'] ?? 0,
      lastActiveDate: _parseTimestamp(data['lastActiveDate']),
    );
  }

  // Convert sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'currentLevel': currentLevel,
      'totalXP': totalXP,
      'streak': streak,
      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
    };
  }

  // Copy with method để update
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? currentLevel,
    int? totalXP,
    int? streak,
    DateTime? lastActiveDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXP: totalXP ?? this.totalXP,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}


