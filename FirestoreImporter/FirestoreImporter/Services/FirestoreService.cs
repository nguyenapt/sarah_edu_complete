using Google.Cloud.Firestore;
using FirestoreImporter.Models;

namespace FirestoreImporter.Services;

public class FirestoreService
{
    private FirestoreDb? _db;
    private string? _projectId;

    public async Task InitializeAsync(string projectId, string? credentialsPath = null)
    {
        _projectId = projectId;

        if (!string.IsNullOrEmpty(credentialsPath) && File.Exists(credentialsPath))
        {
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);
        }

        _db = await FirestoreDb.CreateAsync(projectId);
    }

    public async Task<bool> TestConnectionAsync()
    {
        try
        {
            if (_db == null)
            {
                throw new InvalidOperationException("Firestore chưa được khởi tạo. Vui lòng nhập Project ID và Credentials.");
            }

            // Test connection bằng cách lấy một collection
            var collection = _db.Collection("test");
            await collection.Limit(1).GetSnapshotAsync();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task ImportUnitAsync(UnitModel unit)
    {
        if (_db == null)
        {
            throw new InvalidOperationException("Firestore chưa được khởi tạo.");
        }

        var collection = _db.Collection("units");
        var docRef = collection.Document(unit.Id);
        await docRef.SetAsync(unit.ToFirestore());
    }

    public async Task ImportLessonAsync(LessonModel lesson)
    {
        if (_db == null)
        {
            throw new InvalidOperationException("Firestore chưa được khởi tạo.");
        }

        var collection = _db.Collection("lessons");
        var docRef = collection.Document(lesson.Id);
        await docRef.SetAsync(lesson.ToFirestore());
    }

    public async Task ImportExerciseAsync(ExerciseModel exercise)
    {
        if (_db == null)
        {
            throw new InvalidOperationException("Firestore chưa được khởi tạo.");
        }

        var collection = _db.Collection("exercises");
        var docRef = collection.Document(exercise.Id);
        await docRef.SetAsync(exercise.ToFirestore());
    }

    public async Task ImportLevelAsync(string levelId, LevelData levelData)
    {
        if (_db == null)
        {
            throw new InvalidOperationException("Firestore chưa được khởi tạo.");
        }

        var collection = _db.Collection("levels");
        var docRef = collection.Document(levelId);
        
        var data = new Dictionary<string, object>
        {
            { "name", levelData.Name ?? "" },
            { "description", levelData.Description ?? "" },
            { "order", levelData.Order },
            { "totalUnits", levelData.TotalUnits },
            { "estimatedHours", levelData.EstimatedHours }
        };

        await docRef.SetAsync(data);
    }

    public async Task<int> ImportUnitsAsync(List<UnitModel> units, IProgress<string>? progress = null)
    {
        int successCount = 0;
        foreach (var unit in units)
        {
            try
            {
                await ImportUnitAsync(unit);
                successCount++;
                progress?.Report($"Đã import Unit: {unit.Id}");
            }
            catch (Exception ex)
            {
                progress?.Report($"Lỗi khi import Unit {unit.Id}: {ex.Message}");
            }
        }
        return successCount;
    }

    public async Task<int> ImportLessonsAsync(List<LessonModel> lessons, IProgress<string>? progress = null)
    {
        int successCount = 0;
        foreach (var lesson in lessons)
        {
            try
            {
                await ImportLessonAsync(lesson);
                successCount++;
                progress?.Report($"Đã import Lesson: {lesson.Id}");
            }
            catch (Exception ex)
            {
                progress?.Report($"Lỗi khi import Lesson {lesson.Id}: {ex.Message}");
            }
        }
        return successCount;
    }

    public async Task<int> ImportExercisesAsync(List<ExerciseModel> exercises, IProgress<string>? progress = null)
    {
        int successCount = 0;
        foreach (var exercise in exercises)
        {
            try
            {
                await ImportExerciseAsync(exercise);
                successCount++;
                progress?.Report($"Đã import Exercise: {exercise.Id}");
            }
            catch (Exception ex)
            {
                progress?.Report($"Lỗi khi import Exercise {exercise.Id}: {ex.Message}");
            }
        }
        return successCount;
    }

    public async Task<int> ImportLevelsAsync(Dictionary<string, LevelData> levels, IProgress<string>? progress = null)
    {
        int successCount = 0;
        foreach (var kvp in levels)
        {
            try
            {
                await ImportLevelAsync(kvp.Key, kvp.Value);
                successCount++;
                progress?.Report($"Đã import Level: {kvp.Key}");
            }
            catch (Exception ex)
            {
                progress?.Report($"Lỗi khi import Level {kvp.Key}: {ex.Message}");
            }
        }
        return successCount;
    }
}


