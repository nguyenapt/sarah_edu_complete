import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/firebase_constants.dart';
import '../srs/sm2_vocabulary.dart';
import '../../models/vocabulary_word_state.dart';
import 'firestore_service.dart';

const _prefsKey = 'vocabulary_word_states_v1';

Map<String, dynamic> _stateToFirestoreMap(VocabularyWordState s) {
  return {
    FirebaseConstants.vocabFieldFavorited: s.favorited,
    if (s.lastOutcome != null)
      FirebaseConstants.vocabFieldLastOutcome: s.lastOutcome!.wireName,
    FirebaseConstants.vocabFieldStillLearningCount: s.stillLearningCount,
    FirebaseConstants.vocabFieldGotItCount: s.gotItCount,
    FirebaseConstants.vocabFieldEaseFactor: s.easeFactor,
    FirebaseConstants.vocabFieldIntervalDays: s.intervalDays,
    FirebaseConstants.vocabFieldRepetitions: s.repetitions,
    if (s.nextReviewAt != null)
      FirebaseConstants.vocabFieldNextReviewAt:
          Timestamp.fromDate(s.nextReviewAt!.toUtc()),
    if (s.lastReviewedAt != null)
      FirebaseConstants.vocabFieldLastReviewedAt:
          Timestamp.fromDate(s.lastReviewedAt!.toUtc()),
    FirebaseConstants.vocabFieldUpdatedAt: FieldValue.serverTimestamp(),
  };
}

/// Trạng thái từ vựng (prefs + dirty); flush batch lên Firestore khi thoát flashcard.
class VocabularyUserStateService extends ChangeNotifier {
  VocabularyUserStateService._();
  static final VocabularyUserStateService instance = VocabularyUserStateService._();

  final Map<String, VocabularyWordState> _states = {};
  final Set<String> _dirtyKeys = {};
  final FirestoreService _firestoreService = FirestoreService();
  bool _loaded = false;

  Map<String, VocabularyWordState> get statesUnmodifiable =>
      Map.unmodifiable(_states);

  VocabularyWordState stateForKey(String key) =>
      _states[key] ?? VocabularyWordState.initial();

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is Map<String, dynamic>) {
            _states[k] = VocabularyWordState.fromJson(v);
          }
        });
      } catch (_) {
        // ignore corrupt
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    _states.forEach((k, v) => map[k] = v.toJson());
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  Future<void> setFavorite(String key, bool favorited) async {
    await ensureLoaded();
    final cur = _states[key] ?? VocabularyWordState.initial();
    _states[key] = cur.copyWith(favorited: favorited);
    _dirtyKeys.add(key);
    await _persistPrefs();
    notifyListeners();
  }

  Future<void> toggleFavorite(String key) async {
    final cur = stateForKey(key);
    await setFavorite(key, !cur.favorited);
  }

  Future<void> recordOutcome(String key, VocabOutcome outcome) async {
    await ensureLoaded();
    final cur = _states[key] ?? VocabularyWordState.initial();
    final srs = outcome == VocabOutcome.gotIt
        ? Sm2Vocabulary.applySrsGotIt(cur)
        : Sm2Vocabulary.applySrsStillLearning(cur);

    _states[key] = srs.copyWith(
      lastOutcome: outcome,
      gotItCount:
          outcome == VocabOutcome.gotIt ? cur.gotItCount + 1 : cur.gotItCount,
      stillLearningCount: outcome == VocabOutcome.stillLearning
          ? cur.stillLearningCount + 1
          : cur.stillLearningCount,
    );
    _dirtyKeys.add(key);
    await _persistPrefs();
    notifyListeners();
  }

  /// Đẩy mọi key dirty lên Firestore; bỏ dirty khi thành công.
  Future<void> flushPendingToFirestore(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    if (_dirtyKeys.isEmpty) return;

    final keys = List<String>.from(_dirtyKeys);
    final payload = <String, Map<String, dynamic>>{};
    for (final k in keys) {
      final s = _states[k];
      if (s != null) {
        payload[k] = _stateToFirestoreMap(s);
      }
    }
    if (payload.isEmpty) return;

    try {
      await _firestoreService.batchUpsertUserVocabularyWords(userId, payload);
      _dirtyKeys.removeAll(keys);
      await _persistPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('VocabularyUserStateService flush failed: $e');
      rethrow;
    }
  }

}
