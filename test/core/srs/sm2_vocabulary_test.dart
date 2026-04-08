import 'package:flutter_test/flutter_test.dart';
import 'package:sarah_edu_complete/core/srs/sm2_vocabulary.dart';
import 'package:sarah_edu_complete/models/vocabulary_word_state.dart';

void main() {
  test('applySrsGotIt tăng repetitions và đặt nextReviewAt', () {
    final s = VocabularyWordState.initial();
    final r = Sm2Vocabulary.applySrsGotIt(s);
    expect(r.repetitions, 1);
    expect(r.intervalDays, 1);
    expect(r.nextReviewAt, isNotNull);
  });

  test('applySrsGotIt lần 2 dùng khoảng 6 ngày', () {
    final s = Sm2Vocabulary.applySrsGotIt(VocabularyWordState.initial());
    final r = Sm2Vocabulary.applySrsGotIt(s);
    expect(r.repetitions, 2);
    expect(r.intervalDays, 6);
  });

  test('applySrsStillLearning reset repetitions và giảm ease', () {
    final s = Sm2Vocabulary.applySrsGotIt(VocabularyWordState.initial());
    final r = Sm2Vocabulary.applySrsStillLearning(s);
    expect(r.repetitions, 0);
    expect(r.easeFactor, lessThan(s.easeFactor));
    expect(r.intervalDays, 1);
  });
}
