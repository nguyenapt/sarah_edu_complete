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
  final String lessonId; // THÊM MỚI
  final String unitId;
  final String level;
  final double score; // 0.0 - 1.0
  final DateTime completedAt;
  final int timeSpent; // seconds
  final List<String> mistakes;
  final int correctCount;
  final int totalCount;
  final TagsSnapshot tagsSnapshot;

  ExerciseHistoryItem({
    required this.exerciseId,
    required this.lessonId, // THÊM MỚI
    required this.unitId,
    required this.level,
    required this.score,
    required this.completedAt,
    required this.timeSpent,
    this.mistakes = const [],
    this.correctCount = 0,
    this.totalCount = 0,
    TagsSnapshot? tagsSnapshot,
  }) : tagsSnapshot = tagsSnapshot ?? TagsSnapshot();

  factory ExerciseHistoryItem.fromMap(Map<String, dynamic> map) {
    return ExerciseHistoryItem(
      exerciseId: map['exerciseId'] ?? '',
      lessonId: map['lessonId'] ?? '', // THÊM MỚI
      unitId: map['unitId'] ?? '',
      level: map['level'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      timeSpent: map['timeSpent'] ?? 0,
      mistakes: List<String>.from(map['mistakes'] ?? []),
      correctCount: map['correctCount'] ?? 0,
      totalCount: map['totalCount'] ?? 0,
      tagsSnapshot: TagsSnapshot.fromMap(map['tagsSnapshot'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'lessonId': lessonId, // THÊM MỚI
      'unitId': unitId,
      'level': level,
      'score': score,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeSpent': timeSpent,
      'mistakes': mistakes,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'tagsSnapshot': tagsSnapshot.toMap(),
    };
  }
}

class HighestProgress {
  final String levelId;
  final String unitId;
  final String lessonId;
  final String exerciseId;
  final String? groupId; // Group ID from groupUnits collection
  final DateTime updatedAt;

  HighestProgress({
    required this.levelId,
    required this.unitId,
    required this.lessonId,
    required this.exerciseId,
    this.groupId,
    required this.updatedAt,
  });

  factory HighestProgress.fromMap(Map<String, dynamic> map) {
    return HighestProgress(
      levelId: map['levelId'] ?? '',
      unitId: map['unitId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      exerciseId: map['exerciseId'] ?? '',
      groupId: map['groupId'],
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'unitId': unitId,
      'lessonId': lessonId,
      'exerciseId': exerciseId,
      'groupId': groupId,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  HighestProgress copyWith({
    String? levelId,
    String? unitId,
    String? lessonId,
    String? exerciseId,
    String? groupId,
    DateTime? updatedAt,
  }) {
    return HighestProgress(
      levelId: levelId ?? this.levelId,
      unitId: unitId ?? this.unitId,
      lessonId: lessonId ?? this.lessonId,
      exerciseId: exerciseId ?? this.exerciseId,
      groupId: groupId ?? this.groupId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

class TagsSnapshot {
  final List<String> skillTypes;
  final List<String> grammarTopics;

  TagsSnapshot({
    this.skillTypes = const [],
    this.grammarTopics = const [],
  });

  factory TagsSnapshot.fromMap(Map<String, dynamic> map) {
    return TagsSnapshot(
      skillTypes: List<String>.from(map['skillTypes'] ?? []),
      grammarTopics: List<String>.from(map['grammarTopics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skillTypes': skillTypes,
      'grammarTopics': grammarTopics,
    };
  }
}

class WeakSkillItem {
  final String id;
  final double accuracy;
  final int attempts;
  final int correctCount;
  final int totalCount;

  WeakSkillItem({
    required this.id,
    required this.accuracy,
    required this.attempts,
    required this.correctCount,
    required this.totalCount,
  });

  factory WeakSkillItem.fromMap(Map<String, dynamic> map) {
    return WeakSkillItem(
      id: map['id'] ?? '',
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      attempts: map['attempts'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      totalCount: map['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accuracy': accuracy,
      'attempts': attempts,
      'correctCount': correctCount,
      'totalCount': totalCount,
    };
  }
}

class WeakSkillGroupStats {
  final List<WeakSkillItem> skillTypes;
  final List<WeakSkillItem> grammarTopics;

  WeakSkillGroupStats({
    this.skillTypes = const [],
    this.grammarTopics = const [],
  });

  factory WeakSkillGroupStats.fromMap(Map<String, dynamic> map) {
    return WeakSkillGroupStats(
      skillTypes: (map['skillTypes'] as List<dynamic>?)
              ?.map((e) => WeakSkillItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      grammarTopics: (map['grammarTopics'] as List<dynamic>?)
              ?.map((e) => WeakSkillItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skillTypes': skillTypes.map((e) => e.toMap()).toList(),
      'grammarTopics': grammarTopics.map((e) => e.toMap()).toList(),
    };
  }
}

class WeakSkillStats {
  final DateTime updatedAt;
  final List<WeakSkillItem> skillTypes;
  final List<WeakSkillItem> grammarTopics;
  final Map<String, WeakSkillGroupStats> byLevel;
  final Map<String, WeakSkillGroupStats> byUnit;
  final Map<String, WeakSkillGroupStats> byLesson;
  final List<String> recommendedLessons;

  WeakSkillStats({
    required this.updatedAt,
    this.skillTypes = const [],
    this.grammarTopics = const [],
    this.byLevel = const {},
    this.byUnit = const {},
    this.byLesson = const {},
    this.recommendedLessons = const [],
  });

  factory WeakSkillStats.fromMap(Map<String, dynamic> map) {
    final byLevelMap = <String, WeakSkillGroupStats>{};
    final byUnitMap = <String, WeakSkillGroupStats>{};
    final byLessonMap = <String, WeakSkillGroupStats>{};

    if (map['byLevel'] != null) {
      (map['byLevel'] as Map<String, dynamic>).forEach((key, value) {
        byLevelMap[key] = WeakSkillGroupStats.fromMap(value as Map<String, dynamic>);
      });
    }
    if (map['byUnit'] != null) {
      (map['byUnit'] as Map<String, dynamic>).forEach((key, value) {
        byUnitMap[key] = WeakSkillGroupStats.fromMap(value as Map<String, dynamic>);
      });
    }
    if (map['byLesson'] != null) {
      (map['byLesson'] as Map<String, dynamic>).forEach((key, value) {
        byLessonMap[key] = WeakSkillGroupStats.fromMap(value as Map<String, dynamic>);
      });
    }

    return WeakSkillStats(
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      skillTypes: (map['skillTypes'] as List<dynamic>?)
              ?.map((e) => WeakSkillItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      grammarTopics: (map['grammarTopics'] as List<dynamic>?)
              ?.map((e) => WeakSkillItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      byLevel: byLevelMap,
      byUnit: byUnitMap,
      byLesson: byLessonMap,
      recommendedLessons: List<String>.from(map['recommendedLessons'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    final byLevelMap = <String, dynamic>{};
    byLevel.forEach((key, value) {
      byLevelMap[key] = value.toMap();
    });
    final byUnitMap = <String, dynamic>{};
    byUnit.forEach((key, value) {
      byUnitMap[key] = value.toMap();
    });
    final byLessonMap = <String, dynamic>{};
    byLesson.forEach((key, value) {
      byLessonMap[key] = value.toMap();
    });

    return {
      'updatedAt': Timestamp.fromDate(updatedAt),
      'skillTypes': skillTypes.map((e) => e.toMap()).toList(),
      'grammarTopics': grammarTopics.map((e) => e.toMap()).toList(),
      'byLevel': byLevelMap,
      'byUnit': byUnitMap,
      'byLesson': byLessonMap,
      'recommendedLessons': recommendedLessons,
    };
  }
}

class UserProgressModel {
  final String userId;
  final Map<String, LevelProgress> levelProgress; // Key: levelId
  final WeakPoints weakPoints;
  final List<ExerciseHistoryItem> exerciseHistory;
  final HighestProgress? highestProgress; // THÊM MỚI
  final WeakSkillStats? weakSkillStats;
  final DateTime lastUpdated;

  UserProgressModel({
    required this.userId,
    this.levelProgress = const {},
    required this.weakPoints,
    this.exerciseHistory = const [],
    this.highestProgress, // THÊM MỚI
    this.weakSkillStats,
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

    // Parse highestProgress
    HighestProgress? highestProgressData;
    if (data['highestProgress'] != null) {
      highestProgressData = HighestProgress.fromMap(data['highestProgress'] as Map<String, dynamic>);
    }

    return UserProgressModel(
      userId: doc.id,
      levelProgress: levelProgressMap,
      weakPoints: WeakPoints.fromMap(data['weakPoints'] ?? {}),
      exerciseHistory: exerciseHistoryList,
      highestProgress: highestProgressData, // THÊM MỚI
      weakSkillStats: data['weakSkillStats'] != null
          ? WeakSkillStats.fromMap(data['weakSkillStats'] as Map<String, dynamic>)
          : null,
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
      'highestProgress': highestProgress?.toMap(), // THÊM MỚI
      'weakSkillStats': weakSkillStats?.toMap(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserProgressModel copyWith({
    String? userId,
    Map<String, LevelProgress>? levelProgress,
    WeakPoints? weakPoints,
    List<ExerciseHistoryItem>? exerciseHistory,
    HighestProgress? highestProgress, // THÊM MỚI
    WeakSkillStats? weakSkillStats,
    DateTime? lastUpdated,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      levelProgress: levelProgress ?? this.levelProgress,
      weakPoints: weakPoints ?? this.weakPoints,
      exerciseHistory: exerciseHistory ?? this.exerciseHistory,
      highestProgress: highestProgress ?? this.highestProgress, // THÊM MỚI
      weakSkillStats: weakSkillStats ?? this.weakSkillStats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}


