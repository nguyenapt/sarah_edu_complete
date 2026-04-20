import 'dart:math' as math;

import '../../models/lesson_model.dart';
import '../services/vocabulary_user_state_service.dart';
import 'vocab_card_status.dart';
import 'vocabulary_item_key.dart';

const int kPracticeSessionSize = 20;
const int kMaxWeakInSession = 8;

/// Builds a mixed practice deck: up to [kMaxWeakInSession] weak SRS items, rest random from pool.
List<TopicVocabularyItem> buildVocabularyPracticeDeck(
  List<TopicVocabularyItem> pool,
  math.Random random,
) {
  if (pool.isEmpty) return [];
  if (pool.length <= kPracticeSessionSize) {
    final copy = List<TopicVocabularyItem>.from(pool)..shuffle(random);
    return copy;
  }

  final now = DateTime.now().toUtc();
  final svc = VocabularyUserStateService.instance;

  final weak = pool
      .where((e) => vocabularyIsWeak(svc.stateForKey(vocabularyItemKey(e)), now))
      .toList();
  weak.shuffle(random);

  final nWeak = math.min(kMaxWeakInSession, weak.length);
  final selectedKeys = <String>{};
  final result = <TopicVocabularyItem>[];

  for (var i = 0; i < nWeak; i++) {
    final item = weak[i];
    final key = vocabularyItemKey(item);
    if (selectedKeys.add(key)) result.add(item);
  }

  final rest = pool
      .where((e) => !selectedKeys.contains(vocabularyItemKey(e)))
      .toList()
    ..shuffle(random);

  for (final item in rest) {
    if (result.length >= kPracticeSessionSize) break;
    final key = vocabularyItemKey(item);
    if (selectedKeys.add(key)) result.add(item);
  }

  result.shuffle(random);
  return result;
}
