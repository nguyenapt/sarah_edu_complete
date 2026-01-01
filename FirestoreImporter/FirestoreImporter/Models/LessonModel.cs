using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class LessonModel
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("unitId")]
    public string UnitId { get; set; } = string.Empty;

    [JsonProperty("levelId")]
    public string LevelId { get; set; } = string.Empty;

    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    [JsonProperty("type")]
    public string Type { get; set; } = "grammar";

    [JsonProperty("order")]
    public int Order { get; set; }

    [JsonProperty("content")]
    public LessonContent? Content { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "unitId", UnitId },
            { "levelId", LevelId },
            { "type", Type },
            { "order", Order }
        };

        if (Title != null)
        {
            data["title"] = Title;
        }

        if (Content != null)
        {
            data["content"] = Content.ToFirestore();
        }

        return data;
    }
}

public class LessonContent
{
    [JsonProperty("theory")]
    public TheoryContent? Theory { get; set; }

    [JsonProperty("exercises")]
    public List<string> Exercises { get; set; } = new();

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "exercises", Exercises }
        };

        if (Theory != null)
        {
            data["theory"] = Theory.ToFirestore();
        }

        return data;
    }
}

public class TheoryContent
{
    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    /// <summary>
    /// Description chứa raw HTML (không bị escape).
    /// Key là language code (ví dụ: "en", "vi"), value là raw HTML string.
    /// </summary>
    [JsonProperty("description")]
    public Dictionary<string, string>? Description { get; set; }

    [JsonProperty("examples")]
    public List<Example> Examples { get; set; } = new();

    [JsonProperty("usage")]
    public object? Usage { get; set; } // Có thể là List<UsageItem> hoặc Map

    [JsonProperty("hints")]
    public Dictionary<string, object> Hints { get; set; } = new();

    [JsonProperty("forms")]
    public GrammarForms? Forms { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>();

        if (Title != null)
        {
            data["title"] = Title;
        }

        if (Description != null)
        {
            data["description"] = Description;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples.Select(e => e.ToFirestore()).ToList();
        }

        if (Usage != null)
        {
            data["usage"] = Usage;
        }

        if (Forms != null)
        {
            data["forms"] = Forms.ToFirestore();
        }

        if (Hints != null && Hints.Count > 0)
        {
            data["hints"] = Hints;
        }

        return data;
    }
}

public class Example
{
    [JsonProperty("sentence")]
    public string Sentence { get; set; } = string.Empty;

    [JsonProperty("explanation")]
    public Dictionary<string, string>? Explanation { get; set; }

    [JsonProperty("audioUrl")]
    public string? AudioUrl { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "sentence", Sentence }
        };

        if (Explanation != null)
        {
            data["explanation"] = Explanation;
        }

        if (!string.IsNullOrEmpty(AudioUrl))
        {
            data["audioUrl"] = AudioUrl;
        }

        return data;
    }
}

public class GrammarForms
{
    [JsonProperty("statement")]
    public List<string>? Statement { get; set; }

    [JsonProperty("negative")]
    public List<string>? Negative { get; set; }

    [JsonProperty("question")]
    public List<string>? Question { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>();

        if (Statement != null)
        {
            data["statement"] = Statement;
        }

        if (Negative != null)
        {
            data["negative"] = Negative;
        }

        if (Question != null)
        {
            data["question"] = Question;
        }

        return data;
    }
}


