import '../../models/vocabulary_word_state.dart';

/// Trạng thái hiển thị icon chính trên thẻ vocabulary (không gồm sao yêu thích).
enum VocabTrailingPrimary {
  /// Đến hạn ôn hoặc vừa đánh dấu still learning.
  reviewSoon,

  /// Đã nắm khá tốt (SRS).
  mastered,

  /// Đang học dở — vòng %.
  inProgress,

  /// Chưa có dữ liệu SRS đáng kể.
  neutral,
}

bool vocabularyIsWeak(VocabularyWordState? state, DateTime nowUtc) {
  if (state == null) return false;
  if (state.lastOutcome == VocabOutcome.stillLearning) return true;
  final n = state.nextReviewAt;
  if (n == null) return false;
  return !n.isAfter(nowUtc);
}

VocabTrailingPrimary vocabularyTrailingPrimary(
  VocabularyWordState? state,
  DateTime nowUtc,
) {
  if (state == null) return VocabTrailingPrimary.neutral;

  final due = state.nextReviewAt != null && !state.nextReviewAt!.isAfter(nowUtc);
  if (due || state.lastOutcome == VocabOutcome.stillLearning) {
    return VocabTrailingPrimary.reviewSoon;
  }

  final n = state.nextReviewAt;
  if (state.repetitions >= 3 &&
      n != null &&
      n.difference(nowUtc).inDays > 7) {
    return VocabTrailingPrimary.mastered;
  }

  if (state.repetitions > 0 || state.lastReviewedAt != null) {
    return VocabTrailingPrimary.inProgress;
  }

  return VocabTrailingPrimary.neutral;
}

/// 0–1 cho CircularProgressIndicator (ước lượng “gần tới hạn ôn”).
double vocabularyProgress01(VocabularyWordState? state, DateTime nowUtc) {
  if (state == null) return 0;
  final n = state.nextReviewAt;
  final interval = state.intervalDays <= 0 ? 1 : state.intervalDays;
  if (n == null) {
    return (state.repetitions / 8).clamp(0.0, 1.0);
  }
  final leftDays = n.difference(nowUtc).inDays;
  if (leftDays <= 0) return 1.0;
  return (1.0 - (leftDays / (interval + leftDays))).clamp(0.15, 0.95);
}
