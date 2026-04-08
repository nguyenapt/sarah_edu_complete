import '../../models/lesson_model.dart';

/// Khóa ổn định cho prefs + Firestore doc id (sanitize `/`).
String vocabularyItemKey(TopicVocabularyItem item) {
  final w = item.word.trim().toLowerCase();
  final p = item.partOfSpeech.trim().toLowerCase();
  return '$w::$p'.replaceAll('/', '_');
}
