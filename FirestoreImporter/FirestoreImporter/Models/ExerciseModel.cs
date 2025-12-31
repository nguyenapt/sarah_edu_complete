using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class ExerciseModel
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("lessonId")]
    public string LessonId { get; set; } = string.Empty;

    [JsonProperty("unitId")]
    public string UnitId { get; set; } = string.Empty;

    [JsonProperty("levelId")]
    public string LevelId { get; set; } = string.Empty;

    [JsonProperty("type")]
    public string Type { get; set; } = "single_choice";

    [JsonProperty("question")]
    public object? Question { get; set; } // Có thể là string hoặc Dictionary<string, string>

    [JsonProperty("content")]
    public Dictionary<string, object>? Content { get; set; }

    [JsonProperty("points")]
    public int Points { get; set; } = 10;

    [JsonProperty("timeLimit")]
    public int? TimeLimit { get; set; }

    [JsonProperty("difficulty")]
    public string Difficulty { get; set; } = "easy";

    [JsonProperty("explanation")]
    public object? Explanation { get; set; } // Có thể là string hoặc Dictionary<string, string>

    [JsonProperty("groupQuestions")]
    public List<GroupQuestion>? GroupQuestions { get; set; }

    [JsonProperty("imageUrl")]
    public string? ImageUrl { get; set; }

    [JsonProperty("audioUrl")]
    public string? AudioUrl { get; set; }

    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "lessonId", LessonId },
            { "unitId", UnitId },
            { "levelId", LevelId },
            { "type", Type },
            { "points", Points },
            { "difficulty", Difficulty }
        };

        if (Question != null)
        {
            data["question"] = Question;
        }

        if (Content != null)
        {
            data["content"] = Content;
        }

        if (TimeLimit.HasValue)
        {
            data["timeLimit"] = TimeLimit.Value;
        }

        if (Explanation != null)
        {
            data["explanation"] = Explanation;
        }

        if (GroupQuestions != null && GroupQuestions.Count > 0)
        {
            data["groupQuestions"] = GroupQuestions.Select(gq => gq.ToFirestore()).ToList();
        }

        if (!string.IsNullOrEmpty(ImageUrl))
        {
            data["imageUrl"] = ImageUrl;
        }

        if (!string.IsNullOrEmpty(AudioUrl))
        {
            data["audioUrl"] = AudioUrl;
        }

        if (Title != null)
        {
            data["title"] = Title;
        }

        return data;
    }
}

public class GroupQuestion
{
    [JsonProperty("question")]
    public object? Question { get; set; }

    [JsonProperty("type")]
    public string Type { get; set; } = "button_single_choice";

    [JsonProperty("content")]
    public Dictionary<string, object>? Content { get; set; }

    [JsonProperty("point")]
    public int Point { get; set; } = 0;

    [JsonProperty("timeLimit")]
    public int? TimeLimit { get; set; }

    [JsonProperty("difficulty")]
    public string Difficulty { get; set; } = "easy";

    [JsonProperty("explanation")]
    public Dictionary<string, string>? Explanation { get; set; }

    [JsonProperty("imageUrl")]
    public string? ImageUrl { get; set; }

    [JsonProperty("audioUrl")]
    public string? AudioUrl { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "type", Type },
            { "point", Point },
            { "difficulty", Difficulty }
        };

        if (Question != null)
        {
            data["question"] = Question;
        }

        if (Content != null)
        {
            data["content"] = Content;
        }

        if (TimeLimit.HasValue)
        {
            data["timeLimit"] = TimeLimit.Value;
        }

        if (Explanation != null)
        {
            data["explanation"] = Explanation;
        }

        if (!string.IsNullOrEmpty(ImageUrl))
        {
            data["imageUrl"] = ImageUrl;
        }

        if (!string.IsNullOrEmpty(AudioUrl))
        {
            data["audioUrl"] = AudioUrl;
        }

        return data;
    }
}


