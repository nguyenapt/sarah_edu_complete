using FirestoreImporter.Models;
using Google.Cloud.Firestore;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

public static class FirestoreDocumentMapper
{
    public static UnitModel MapUnit(DocumentSnapshot doc)
    {
        var json = FirestoreValueNormalizer.DocumentToJson(doc);
        var unit = JsonConvert.DeserializeObject<UnitModel>(json) ?? new UnitModel();
        unit.Id = doc.Id;

        var jo = JObject.Parse(json);
        if (jo["groupId"] != null && string.IsNullOrEmpty(unit.Group))
            unit.Group = jo["groupId"]?.ToString();

        return unit;
    }

    public static LessonModel MapLesson(DocumentSnapshot doc)
    {
        var json = FirestoreValueNormalizer.DocumentToJson(doc);
        var lesson = JsonConvert.DeserializeObject<LessonModel>(json) ?? new LessonModel();
        lesson.Id = doc.Id;
        return lesson;
    }

    public static ExerciseModel MapExercise(DocumentSnapshot doc)
    {
        var json = FirestoreValueNormalizer.DocumentToJson(doc);
        var exercise = JsonConvert.DeserializeObject<ExerciseModel>(json) ?? new ExerciseModel();
        exercise.Id = doc.Id;
        return exercise;
    }

    public static LevelData MapLevel(DocumentSnapshot doc)
    {
        var json = FirestoreValueNormalizer.DocumentToJson(doc);
        return JsonConvert.DeserializeObject<LevelData>(json) ?? new LevelData();
    }
}
