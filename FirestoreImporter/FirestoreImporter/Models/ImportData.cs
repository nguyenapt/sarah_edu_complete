using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class ImportData
{
    [JsonProperty("levels")]
    public Dictionary<string, LevelData>? Levels { get; set; }

    [JsonProperty("units")]
    public Dictionary<string, UnitModel>? Units { get; set; }

    [JsonProperty("lessons")]
    public Dictionary<string, LessonModel>? Lessons { get; set; }

    [JsonProperty("exercises")]
    public Dictionary<string, ExerciseModel>? Exercises { get; set; }
}

public class LevelData
{
    [JsonProperty("name")]
    public string? Name { get; set; }

    [JsonProperty("description")]
    public string? Description { get; set; }

    [JsonProperty("order")]
    public int Order { get; set; }

    [JsonProperty("totalUnits")]
    public int TotalUnits { get; set; }

    [JsonProperty("estimatedHours")]
    public int EstimatedHours { get; set; }
}


