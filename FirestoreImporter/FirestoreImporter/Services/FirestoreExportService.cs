using FirestoreImporter.Models;
using Google.Cloud.Firestore;

namespace FirestoreImporter.Services;

public enum FirestoreLoadScope
{
    Exercise,
    Lesson,
    Unit,
    Level,
    Unknown
}

public class FirestoreExportService
{
    private readonly FirestoreService _firestore;

    public FirestoreExportService(FirestoreService firestore)
    {
        _firestore = firestore;
    }

    /// <summary>
    /// Suy ra collection + scope từ document ID (hoặc "collection/docId").
    /// </summary>
    public static (FirestoreLoadScope scope, string collection, string documentId) ResolveDocument(string input)
    {
        var trimmed = input.Trim();
        if (string.IsNullOrEmpty(trimmed))
            throw new ArgumentException("Document ID trống.");

        if (trimmed.Contains('/'))
        {
            var parts = trimmed.Split('/', 2, StringSplitOptions.RemoveEmptyEntries);
            var collection = parts[0].ToLowerInvariant();
            var docId = parts[1];
            return (ScopeFromCollection(collection), collection, docId);
        }

        var id = trimmed;
        if (id.StartsWith("unit_", StringComparison.OrdinalIgnoreCase))
            return (FirestoreLoadScope.Unit, "units", id);
        if (id.StartsWith("lesson_", StringComparison.OrdinalIgnoreCase))
            return (FirestoreLoadScope.Lesson, "lessons", id);
        if (id.StartsWith("exercise_", StringComparison.OrdinalIgnoreCase))
            return (FirestoreLoadScope.Exercise, "exercises", id);

        var upper = id.ToUpperInvariant();
        if (upper is "A1" or "A2" or "B1" or "B2" or "C1" or "C2" || id.StartsWith("level_", StringComparison.OrdinalIgnoreCase))
            return (FirestoreLoadScope.Level, "levels", id);

        return (FirestoreLoadScope.Unknown, "", id);
    }

    private static FirestoreLoadScope ScopeFromCollection(string collection) => collection switch
    {
        "units" => FirestoreLoadScope.Unit,
        "lessons" => FirestoreLoadScope.Lesson,
        "exercises" => FirestoreLoadScope.Exercise,
        "levels" => FirestoreLoadScope.Level,
        _ => FirestoreLoadScope.Unknown
    };

    public async Task<ImportData> LoadByDocumentIdAsync(
        string documentInput,
        IProgress<string>? progress = null,
        CancellationToken cancellationToken = default)
    {
        var db = _firestore.GetDb();
        var (scope, collection, docId) = ResolveDocument(documentInput);

        if (scope == FirestoreLoadScope.Unknown)
        {
            scope = await TryDetectScopeAsync(db, docId, cancellationToken);
            collection = scope switch
            {
                FirestoreLoadScope.Unit => "units",
                FirestoreLoadScope.Lesson => "lessons",
                FirestoreLoadScope.Exercise => "exercises",
                FirestoreLoadScope.Level => "levels",
                _ => throw new InvalidOperationException(
                    $"Không nhận diện được document '{docId}'. Dùng unit_*, lesson_*, exercise_* hoặc levels/A1.")
            };
        }

        progress?.Report($"Đang tải {collection}/{docId}...");

        return scope switch
        {
            FirestoreLoadScope.Unit => await LoadUnitScopeAsync(db, docId, progress, cancellationToken),
            FirestoreLoadScope.Lesson => await LoadLessonScopeAsync(db, docId, progress, cancellationToken),
            FirestoreLoadScope.Exercise => await LoadExerciseScopeAsync(db, docId, progress, cancellationToken),
            FirestoreLoadScope.Level => await LoadLevelScopeAsync(db, docId, progress, cancellationToken),
            _ => throw new InvalidOperationException($"Scope không hỗ trợ: {scope}")
        };
    }

    private static async Task<FirestoreLoadScope> TryDetectScopeAsync(
        FirestoreDb db,
        string docId,
        CancellationToken cancellationToken)
    {
        foreach (var (col, scope) in new[]
        {
            ("units", FirestoreLoadScope.Unit),
            ("lessons", FirestoreLoadScope.Lesson),
            ("exercises", FirestoreLoadScope.Exercise),
            ("levels", FirestoreLoadScope.Level)
        })
        {
            var snap = await db.Collection(col).Document(docId).GetSnapshotAsync(cancellationToken);
            if (snap.Exists) return scope;
        }
        return FirestoreLoadScope.Unknown;
    }

    private async Task<ImportData> LoadUnitScopeAsync(
        FirestoreDb db,
        string unitId,
        IProgress<string>? progress,
        CancellationToken cancellationToken)
    {
        var unitSnap = await db.Collection("units").Document(unitId).GetSnapshotAsync(cancellationToken);
        if (!unitSnap.Exists)
            throw new FileNotFoundException($"Không tìm thấy unit: {unitId}");

        var unit = FirestoreDocumentMapper.MapUnit(unitSnap);
        var data = new ImportData
        {
            Units = new Dictionary<string, UnitModel> { [unitId] = unit },
            Lessons = new Dictionary<string, LessonModel>(),
            Exercises = new Dictionary<string, ExerciseModel>()
        };

        progress?.Report($"Đang tải lessons cho unit {unitId}...");
        var lessonsSnap = await db.Collection("lessons")
            .WhereEqualTo("unitId", unitId)
            .GetSnapshotAsync(cancellationToken);

        foreach (var doc in lessonsSnap.Documents)
        {
            var lesson = FirestoreDocumentMapper.MapLesson(doc);
            data.Lessons![lesson.Id] = lesson;
        }

        progress?.Report($"Đang tải exercises cho unit {unitId}...");
        await FetchExercisesByUnitIdAsync(db, unitId, data, progress, cancellationToken);

        if (data.Exercises!.Count == 0 && data.Lessons!.Count > 0)
        {
            foreach (var lessonId in data.Lessons.Keys)
                await FetchExercisesByLessonIdAsync(db, lessonId, data, cancellationToken);
        }

        progress?.Report($"✓ Unit {unitId}: {data.Lessons.Count} lessons, {data.Exercises.Count} exercises.");
        return data;
    }

    private async Task<ImportData> LoadLessonScopeAsync(
        FirestoreDb db,
        string lessonId,
        IProgress<string>? progress,
        CancellationToken cancellationToken)
    {
        var lessonSnap = await db.Collection("lessons").Document(lessonId).GetSnapshotAsync(cancellationToken);
        if (!lessonSnap.Exists)
            throw new FileNotFoundException($"Không tìm thấy lesson: {lessonId}");

        var lesson = FirestoreDocumentMapper.MapLesson(lessonSnap);
        var data = new ImportData
        {
            Lessons = new Dictionary<string, LessonModel> { [lessonId] = lesson },
            Exercises = new Dictionary<string, ExerciseModel>()
        };

        if (!string.IsNullOrEmpty(lesson.UnitId))
        {
            var unitSnap = await db.Collection("units").Document(lesson.UnitId).GetSnapshotAsync(cancellationToken);
            if (unitSnap.Exists)
            {
                data.Units = new Dictionary<string, UnitModel>
                {
                    [lesson.UnitId] = FirestoreDocumentMapper.MapUnit(unitSnap)
                };
            }
        }

        progress?.Report($"Đang tải exercises cho lesson {lessonId}...");
        await FetchExercisesByLessonIdAsync(db, lessonId, data, cancellationToken);
        progress?.Report($"✓ Lesson {lessonId}: {data.Exercises!.Count} exercises.");
        return data;
    }

    private async Task<ImportData> LoadExerciseScopeAsync(
        FirestoreDb db,
        string exerciseId,
        IProgress<string>? progress,
        CancellationToken cancellationToken)
    {
        var exSnap = await db.Collection("exercises").Document(exerciseId).GetSnapshotAsync(cancellationToken);
        if (!exSnap.Exists)
            throw new FileNotFoundException($"Không tìm thấy exercise: {exerciseId}");

        var exercise = FirestoreDocumentMapper.MapExercise(exSnap);
        var data = new ImportData
        {
            Exercises = new Dictionary<string, ExerciseModel> { [exerciseId] = exercise }
        };

        if (!string.IsNullOrEmpty(exercise.LessonId))
        {
            var lessonData = await LoadLessonScopeAsync(db, exercise.LessonId, progress, cancellationToken);
            data.Lessons = lessonData.Lessons;
            data.Units = lessonData.Units;
            data.Exercises = lessonData.Exercises;
        }

        progress?.Report($"✓ Exercise {exerciseId} (+ lesson/unit liên quan).");
        return data;
    }

    private async Task<ImportData> LoadLevelScopeAsync(
        FirestoreDb db,
        string levelId,
        IProgress<string>? progress,
        CancellationToken cancellationToken)
    {
        var levelSnap = await db.Collection("levels").Document(levelId).GetSnapshotAsync(cancellationToken);
        if (!levelSnap.Exists)
            throw new FileNotFoundException($"Không tìm thấy level: {levelId}");

        var data = new ImportData
        {
            Levels = new Dictionary<string, LevelData> { [levelId] = FirestoreDocumentMapper.MapLevel(levelSnap) },
            Units = new Dictionary<string, UnitModel>(),
            Lessons = new Dictionary<string, LessonModel>(),
            Exercises = new Dictionary<string, ExerciseModel>()
        };

        progress?.Report($"Đang tải units cho level {levelId}...");
        var unitsSnap = await db.Collection("units")
            .WhereEqualTo("levelId", levelId)
            .GetSnapshotAsync(cancellationToken);

        foreach (var doc in unitsSnap.Documents)
        {
            var unit = FirestoreDocumentMapper.MapUnit(doc);
            data.Units![unit.Id] = unit;
            await FetchExercisesByUnitIdAsync(db, unit.Id, data, progress, cancellationToken);

            var lessonsSnap = await db.Collection("lessons")
                .WhereEqualTo("unitId", unit.Id)
                .GetSnapshotAsync(cancellationToken);
            foreach (var lessonDoc in lessonsSnap.Documents)
            {
                var lesson = FirestoreDocumentMapper.MapLesson(lessonDoc);
                data.Lessons![lesson.Id] = lesson;
            }
        }

        progress?.Report($"✓ Level {levelId}: {data.Units!.Count} units, {data.Lessons!.Count} lessons, {data.Exercises!.Count} exercises.");
        return data;
    }

    private static async Task FetchExercisesByUnitIdAsync(
        FirestoreDb db,
        string unitId,
        ImportData data,
        IProgress<string>? progress,
        CancellationToken cancellationToken)
    {
        data.Exercises ??= new Dictionary<string, ExerciseModel>();
        var snap = await db.Collection("exercises")
            .WhereEqualTo("unitId", unitId)
            .GetSnapshotAsync(cancellationToken);

        foreach (var doc in snap.Documents)
        {
            var ex = FirestoreDocumentMapper.MapExercise(doc);
            data.Exercises[ex.Id] = ex;
        }

        progress?.Report($"  exercises unit {unitId}: {snap.Count} docs.");
    }

    private static async Task FetchExercisesByLessonIdAsync(
        FirestoreDb db,
        string lessonId,
        ImportData data,
        CancellationToken cancellationToken)
    {
        data.Exercises ??= new Dictionary<string, ExerciseModel>();
        var snap = await db.Collection("exercises")
            .WhereEqualTo("lessonId", lessonId)
            .GetSnapshotAsync(cancellationToken);

        foreach (var doc in snap.Documents)
        {
            var ex = FirestoreDocumentMapper.MapExercise(doc);
            data.Exercises[ex.Id] = ex;
        }
    }
}
