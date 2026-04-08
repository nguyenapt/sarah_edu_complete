/// Kết quả lần đánh giá gần nhất trên flashcard.
enum VocabOutcome {
  gotIt,
  stillLearning;

  static VocabOutcome? fromString(String? s) {
    switch (s) {
      case 'got_it':
        return VocabOutcome.gotIt;
      case 'still_learning':
        return VocabOutcome.stillLearning;
      default:
        return null;
    }
  }

  String get wireName =>
      this == VocabOutcome.gotIt ? 'got_it' : 'still_learning';
}

/// Trạng thái SRS + favourite + thống kê tap (local + mirror Firestore).
class VocabularyWordState {
  final bool favorited;
  final VocabOutcome? lastOutcome;
  final int stillLearningCount;
  final int gotItCount;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime? nextReviewAt;
  final DateTime? lastReviewedAt;

  const VocabularyWordState({
    required this.favorited,
    required this.lastOutcome,
    required this.stillLearningCount,
    required this.gotItCount,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReviewAt,
    required this.lastReviewedAt,
  });

  factory VocabularyWordState.initial() => const VocabularyWordState(
        favorited: false,
        lastOutcome: null,
        stillLearningCount: 0,
        gotItCount: 0,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        nextReviewAt: null,
        lastReviewedAt: null,
      );

  VocabularyWordState copyWith({
    bool? favorited,
    VocabOutcome? lastOutcome,
    int? stillLearningCount,
    int? gotItCount,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
  }) {
    return VocabularyWordState(
      favorited: favorited ?? this.favorited,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      stillLearningCount: stillLearningCount ?? this.stillLearningCount,
      gotItCount: gotItCount ?? this.gotItCount,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorited': favorited,
      'lastOutcome': lastOutcome?.wireName,
      'stillLearningCount': stillLearningCount,
      'gotItCount': gotItCount,
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'repetitions': repetitions,
      'nextReviewAt': nextReviewAt?.millisecondsSinceEpoch,
      'lastReviewedAt': lastReviewedAt?.millisecondsSinceEpoch,
    };
  }

  factory VocabularyWordState.fromJson(Map<String, dynamic> map) {
    return VocabularyWordState(
      favorited: map['favorited'] == true,
      lastOutcome: VocabOutcome.fromString(map['lastOutcome']?.toString()),
      stillLearningCount: (map['stillLearningCount'] as num?)?.toInt() ?? 0,
      gotItCount: (map['gotItCount'] as num?)?.toInt() ?? 0,
      easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (map['intervalDays'] as num?)?.toInt() ?? 0,
      repetitions: (map['repetitions'] as num?)?.toInt() ?? 0,
      nextReviewAt: _readMillis(map['nextReviewAt']),
      lastReviewedAt: _readMillis(map['lastReviewedAt']),
    );
  }

  static DateTime? _readMillis(dynamic v) {
    if (v == null) return null;
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
    }
    if (v is num) {
      return DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: true);
    }
    return null;
  }
}
