using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class UnitModel
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("levelId")]
    public string LevelId { get; set; } = string.Empty;

    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    [JsonProperty("description")]
    public Dictionary<string, string>? Description { get; set; }

    [JsonProperty("order")]
    public int Order { get; set; }

    [JsonProperty("estimatedTime")]
    public int EstimatedTime { get; set; }

    [JsonProperty("lessons")]
    public List<string> Lessons { get; set; } = new();

    [JsonProperty("prerequisites")]
    public List<string> Prerequisites { get; set; } = new();

    [JsonProperty("group")]
    public string? Group { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "levelId", LevelId },
            { "order", Order },
            { "estimatedTime", EstimatedTime },
            { "lessons", Lessons },
            { "prerequisites", Prerequisites }
        };

        if (Title != null)
        {
            data["title"] = Title;
        }

        if (Description != null)
        {
            data["description"] = Description;
        }

        if (!string.IsNullOrEmpty(Group))
        {
            data["group"] = Group;
        }

        return data;
    }
}


