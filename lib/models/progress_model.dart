import 'package:cloud_firestore/cloud_firestore.dart';

class LevelProgress {
  final List<String> completedUnits;
  final String? currentUnit;
  final double mastery; // 0.0 - 1.0

  LevelProgress({
    this.completedUnits = const [],
    this.currentUnit,
    this.mastery = 0.0,
  });

  factory LevelProgress.fromMap(Map<String, dynamic> map) {
    return LevelProgress(
      completedUnits: List<String>.from(map['completedUnits'] ?? []),
      currentUnit: map['currentUnit'],
      mastery: (map['mastery'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedUnits': completedUnits,
      'currentUnit': currentUnit,
      'mastery': mastery,
    };
  }
}

class ExerciseHistoryItem {
  final String exerciseId;
  final String unitId;
  final String level;
  final double score; // 0.0 - 1.0
  final DateTime completedAt;
  final int timeSpent; // seconds
  final List<String> mistakes;

  ExerciseHistoryItem({
    required this.exerciseId,
    required this.unitId,
    required this.level,
    required this.score,
    required this.completedAt,
    required this.timeSpent,
    this.mistakes = const [],
  });

  factory ExerciseHistoryItem.fromMap(Map<String, dynamic> map) {
    return ExerciseHistoryItem(
      exerciseId: map['exerciseId'] ?? '',
      unitId: map['unitId'] ?? '',
      level: map['level'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      timeSpent: map['timeSpent'] ?? 0,
      mistakes: List<String>.from(map['mistakes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'unitId': unitId,
      'level': level,
      'score': score,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeSpent': timeSpent,
      'mistakes': mistakes,
    };
  }
}

class WeakPoints {
  final List<String> grammarTopics; // IDs của các topics yếu
  final List<String> skillTypes; // listening, speaking, reading, writing

  WeakPoints({
    this.grammarTopics = const [],
    this.skillTypes = const [],
  });

  factory WeakPoints.fromMap(Map<String, dynamic> map) {
    return WeakPoints(
      grammarTopics: List<String>.from(map['grammarTopics'] ?? []),
      skillTypes: List<String>.from(map['skillTypes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grammarTopics': grammarTopics,
      'skillTypes': skillTypes,
    };
  }
}

class UserProgressModel {
  final String userId;
  final Map<String, LevelProgress> levelProgress; // Key: levelId
  final WeakPoints weakPoints;
  final List<ExerciseHistoryItem> exerciseHistory;
  final DateTime lastUpdated;

  UserProgressModel({
    required this.userId,
    this.levelProgress = const {},
    required this.weakPoints,
    this.exerciseHistory = const [],
    required this.lastUpdated,
  });

  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse levelProgress
    final levelProgressMap = <String, LevelProgress>{};
    if (data['levelProgress'] != null) {
      (data['levelProgress'] as Map<String, dynamic>).forEach((key, value) {
        levelProgressMap[key] = LevelProgress.fromMap(value as Map<String, dynamic>);
      });
    }

    // Parse exerciseHistory
    final exerciseHistoryList = <ExerciseHistoryItem>[];
    if (data['exerciseHistory'] != null) {
      exerciseHistoryList.addAll(
        (data['exerciseHistory'] as List<dynamic>)
            .map((e) => ExerciseHistoryItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return UserProgressModel(
      userId: doc.id,
      levelProgress: levelProgressMap,
      weakPoints: WeakPoints.fromMap(data['weakPoints'] ?? {}),
      exerciseHistory: exerciseHistoryList,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final levelProgressMap = <String, dynamic>{};
    levelProgress.forEach((key, value) {
      levelProgressMap[key] = value.toMap();
    });

    return {
      'userId': userId,
      'levelProgress': levelProgressMap,
      'weakPoints': weakPoints.toMap(),
      'exerciseHistory': exerciseHistory.map((e) => e.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserProgressModel copyWith({
    String? userId,
    Map<String, LevelProgress>? levelProgress,
    WeakPoints? weakPoints,
    List<ExerciseHistoryItem>? exerciseHistory,
    DateTime? lastUpdated,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      levelProgress: levelProgress ?? this.levelProgress,
      weakPoints: weakPoints ?? this.weakPoints,
      exerciseHistory: exerciseHistory ?? this.exerciseHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}


