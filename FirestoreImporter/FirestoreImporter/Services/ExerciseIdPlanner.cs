using FirestoreImporter.Models;

namespace FirestoreImporter.Services;

/// <summary>
/// Port logic từ UnitGroupService.compareExerciseIds (Flutter).
/// </summary>
public static class ExerciseIdPlanner
{
    public static int CompareExerciseIds(string a, string b)
    {
        var parts1 = a.Split('_');
        var parts2 = b.Split('_');

        if (parts1.Length < 5 || parts2.Length < 5)
            return string.CompareOrdinal(a, b);

        var levelCompare = string.CompareOrdinal(parts1[1], parts2[1]);
        if (levelCompare != 0) return levelCompare;

        var unit1 = int.TryParse(parts1[2], out var u1) ? u1 : 0;
        var unit2 = int.TryParse(parts2[2], out var u2) ? u2 : 0;
        if (unit1 != unit2) return unit1.CompareTo(unit2);

        var lesson1 = int.TryParse(parts1[3], out var l1) ? l1 : 0;
        var lesson2 = int.TryParse(parts2[3], out var l2) ? l2 : 0;
        if (lesson1 != lesson2) return lesson1.CompareTo(lesson2);

        var ex1 = int.TryParse(parts1[4], out var e1) ? e1 : 0;
        var ex2 = int.TryParse(parts2[4], out var e2) ? e2 : 0;
        return ex1.CompareTo(ex2);
    }

    public static int GetExerciseOrderNumber(string exerciseId)
    {
        var parts = exerciseId.Split('_');
        if (parts.Length >= 5 && int.TryParse(parts[4], out var n))
            return n;
        return 0;
    }

    public static string BuildExerciseId(string templateId, int exerciseNumber)
    {
        var parts = templateId.Split('_');
        if (parts.Length < 5)
            throw new ArgumentException($"ID không đúng định dạng: {templateId}");
        parts[4] = exerciseNumber.ToString();
        return string.Join('_', parts);
    }

    /// <summary>
    /// Chèn exercise mới ngay sau afterExerciseId bằng cách đánh số lại các bài sau đó.
    /// </summary>
    public static IdInsertPlan PlanInsertAfter(
        string afterExerciseId,
        IEnumerable<string> lessonExerciseIds)
    {
        var sorted = lessonExerciseIds
            .OrderBy(id => id, Comparer<string>.Create(CompareExerciseIds))
            .ToList();

        if (!sorted.Contains(afterExerciseId))
            throw new ArgumentException($"afterExerciseId không thuộc lesson: {afterExerciseId}");

        var afterOrder = GetExerciseOrderNumber(afterExerciseId);
        var newOrder = afterOrder + 1;
        var newId = BuildExerciseId(afterExerciseId, newOrder);

        var renames = new Dictionary<string, string>();
        foreach (var id in sorted)
        {
            var order = GetExerciseOrderNumber(id);
            if (order > afterOrder)
            {
                renames[id] = BuildExerciseId(id, order + 1);
            }
        }

        return new IdInsertPlan
        {
            NewExerciseId = newId,
            AfterExerciseId = afterExerciseId,
            Renames = renames
        };
    }

    public static void ApplyRenames(
        Dictionary<string, ExerciseModel> exercises,
        Dictionary<string, string> renames)
    {
        if (renames.Count == 0) return;

        var temp = new Dictionary<string, ExerciseModel>();
        foreach (var kvp in exercises.ToList())
        {
            if (renames.ContainsKey(kvp.Key))
            {
                var newId = renames[kvp.Key];
                kvp.Value.Id = newId;
                temp[newId] = kvp.Value;
                exercises.Remove(kvp.Key);
            }
        }
        foreach (var kvp in temp)
            exercises[kvp.Key] = kvp.Value;
    }

    public static void UpdateLessonExerciseRefs(LessonModel lesson, Dictionary<string, string> renames)
    {
        if (lesson.Content?.Exercises == null) return;
        for (var i = 0; i < lesson.Content.Exercises.Count; i++)
        {
            var id = lesson.Content.Exercises[i];
            if (renames.TryGetValue(id, out var newId))
                lesson.Content.Exercises[i] = newId;
        }
    }

    public static List<string> SuggestCheckpointAnchors(
        List<string> sortedExerciseIds,
        int everyN,
        int maxPerLesson)
    {
        var anchors = new List<string>();
        if (sortedExerciseIds.Count == 0) return anchors;

        var interval = sortedExerciseIds.Count <= 5 ? sortedExerciseIds.Count : everyN;
        for (var i = interval - 1; i < sortedExerciseIds.Count && anchors.Count < maxPerLesson; i += interval)
        {
            anchors.Add(sortedExerciseIds[i]);
        }

        if (anchors.Count == 0)
            anchors.Add(sortedExerciseIds[^1]);

        return anchors.Distinct().ToList();
    }
}
