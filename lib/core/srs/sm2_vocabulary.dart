import '../../models/vocabulary_word_state.dart';

/// SM-2 đơn giản cho từ vựng: Got It ≈ quality 5, Still Learning ≈ quality 0.
abstract final class Sm2Vocabulary {
  static const double minEase = 1.3;
  static const double defaultEase = 2.5;
  static const double stillLearningEasePenalty = 0.2;

  static DateTime _nowUtc() => DateTime.now().toUtc();

  /// Cập nhật trường SRS sau Got It (không đụng favourite / counts / lastOutcome).
  static VocabularyWordState applySrsGotIt(VocabularyWordState s) {
    final now = _nowUtc();
    var ease = s.easeFactor;
    var rep = s.repetitions;
    int newInterval;

    if (rep == 0) {
      newInterval = 1;
    } else if (rep == 1) {
      newInterval = 6;
    } else {
      final prev = s.intervalDays <= 0 ? 1 : s.intervalDays;
      newInterval = (prev * ease).round();
      if (newInterval < 1) newInterval = 1;
    }

    rep += 1;
    final next = now.add(Duration(days: newInterval));

    return s.copyWith(
      easeFactor: ease,
      intervalDays: newInterval,
      repetitions: rep,
      nextReviewAt: next,
      lastReviewedAt: now,
    );
  }

  /// Cập nhật trường SRS sau Still Learning.
  static VocabularyWordState applySrsStillLearning(VocabularyWordState s) {
    final now = _nowUtc();
    final ease = (s.easeFactor - stillLearningEasePenalty).clamp(minEase, 10.0);
    const newInterval = 1;
    final next = now.add(const Duration(days: newInterval));

    return s.copyWith(
      easeFactor: ease,
      intervalDays: newInterval,
      repetitions: 0,
      nextReviewAt: next,
      lastReviewedAt: now,
    );
  }
}
