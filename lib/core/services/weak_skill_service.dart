import '../../models/progress_model.dart';

class WeakSkillService {
  static const int _minAttemptsForWeak = 3;
  static const double _weakAccuracyThreshold = 0.6;

  WeakSkillStats buildStats(List<ExerciseHistoryItem> history) {
    final overall = _aggregate(history);
    final byLevel = <String, WeakSkillGroupStats>{};
    final byUnit = <String, WeakSkillGroupStats>{};
    final byLesson = <String, WeakSkillGroupStats>{};

    final groupedByLevel = <String, List<ExerciseHistoryItem>>{};
    final groupedByUnit = <String, List<ExerciseHistoryItem>>{};
    final groupedByLesson = <String, List<ExerciseHistoryItem>>{};

    for (final item in history) {
      groupedByLevel.putIfAbsent(item.level, () => []).add(item);
      groupedByUnit.putIfAbsent(item.unitId, () => []).add(item);
      groupedByLesson.putIfAbsent(item.lessonId, () => []).add(item);
    }

    groupedByLevel.forEach((key, items) {
      byLevel[key] = _aggregate(items);
    });
    groupedByUnit.forEach((key, items) {
      byUnit[key] = _aggregate(items);
    });
    groupedByLesson.forEach((key, items) {
      byLesson[key] = _aggregate(items);
    });

    final weakTagIds = _extractWeakTagIds(overall);
    final recommendedLessons = _buildRecommendedLessons(history, weakTagIds);

    return WeakSkillStats(
      updatedAt: DateTime.now(),
      skillTypes: overall.skillTypes,
      grammarTopics: overall.grammarTopics,
      byLevel: byLevel,
      byUnit: byUnit,
      byLesson: byLesson,
      recommendedLessons: recommendedLessons,
    );
  }

  WeakSkillGroupStats _aggregate(List<ExerciseHistoryItem> history) {
    final skillAgg = <String, _Agg>{};
    final topicAgg = <String, _Agg>{};

    for (final item in history) {
      final correct = item.correctCount;
      final total = item.totalCount > 0 ? item.totalCount : 1;

      for (final skill in item.tagsSnapshot.skillTypes) {
        skillAgg.putIfAbsent(skill, () => _Agg()).add(correct, total);
      }
      for (final topic in item.tagsSnapshot.grammarTopics) {
        topicAgg.putIfAbsent(topic, () => _Agg()).add(correct, total);
      }
    }

    return WeakSkillGroupStats(
      skillTypes: _toItems(skillAgg),
      grammarTopics: _toItems(topicAgg),
    );
  }

  List<WeakSkillItem> _toItems(Map<String, _Agg> map) {
    final items = map.entries.map((entry) {
      final accuracy = entry.value.total == 0
          ? 0.0
          : entry.value.correct / entry.value.total;
      return WeakSkillItem(
        id: entry.key,
        accuracy: accuracy,
        attempts: entry.value.total,
        correctCount: entry.value.correct,
        totalCount: entry.value.total,
      );
    }).toList();

    items.sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return items;
  }

  Set<String> _extractWeakTagIds(WeakSkillGroupStats overall) {
    final weak = <String>{};

    for (final item in overall.skillTypes) {
      if (item.attempts >= _minAttemptsForWeak &&
          item.accuracy < _weakAccuracyThreshold) {
        weak.add(item.id);
      }
    }
    for (final item in overall.grammarTopics) {
      if (item.attempts >= _minAttemptsForWeak &&
          item.accuracy < _weakAccuracyThreshold) {
        weak.add(item.id);
      }
    }

    return weak;
  }

  List<String> _buildRecommendedLessons(
    List<ExerciseHistoryItem> history,
    Set<String> weakTagIds,
  ) {
    if (weakTagIds.isEmpty) return [];

    final sorted = List<ExerciseHistoryItem>.from(history)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    final recommended = <String>[];
    final seen = <String>{};

    for (final item in sorted) {
      if (seen.contains(item.lessonId)) continue;
      final tags = {
        ...item.tagsSnapshot.skillTypes,
        ...item.tagsSnapshot.grammarTopics,
      };
      if (tags.any(weakTagIds.contains)) {
        recommended.add(item.lessonId);
        seen.add(item.lessonId);
      }
      if (recommended.length >= 10) break;
    }

    return recommended;
  }
}

class _Agg {
  int correct = 0;
  int total = 0;

  void add(int correctCount, int totalCount) {
    correct += correctCount;
    total += totalCount;
  }
}
