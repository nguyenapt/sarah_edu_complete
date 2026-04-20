using Newtonsoft.Json;
using System.Linq;
using System.Collections;

namespace FirestoreImporter.Models;

public class VoiceConfig
{
    [JsonProperty("gender")]
    public string Gender { get; set; } = "female"; // "male" or "female"

    [JsonProperty("age")]
    public string Age { get; set; } = "adult"; // "kid", "young", "adult", "senior"

    [JsonProperty("languageCode")]
    public string LanguageCode { get; set; } = "en-US";

    [JsonProperty("rate")]
    public double Rate { get; set; } = 1.0; // 0.5 - 2.0

    [JsonProperty("pitch")]
    public double Pitch { get; set; } = 0.0; // -50 to +50 semitones

    public Dictionary<string, object> ToFirestore()
    {
        return new Dictionary<string, object>
        {
            { "gender", Gender },
            { "age", Age },
            { "languageCode", LanguageCode },
            { "rate", Rate },
            { "pitch", Pitch }
        };
    }
}

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

    [JsonProperty("grammarTopics")]
    public List<string> GrammarTopics { get; set; } = new();

    [JsonProperty("skillTypes")]
    public List<string> SkillTypes { get; set; } = new();

    [JsonProperty("hasVoice")]
    public bool? HasVoice { get; set; }

    [JsonProperty("defaultVoice")]
    public VoiceConfig? DefaultVoice { get; set; }

    [JsonProperty("speakerVoices")]
    public Dictionary<string, VoiceConfig>? SpeakerVoices { get; set; }

    [JsonProperty("sequentialTitle")]
    public string? SequentialTitle { get; set; }

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
            // Nếu là crossword type, convert null values trong grid thành -1 (Firestore không hỗ trợ null trong arrays)
            if (Type == "crossword" && Content.ContainsKey("grid"))
            {
                data["content"] = ProcessCrosswordContentForFirestore(Content);
            }
            else
            {
                data["content"] = Content;
            }
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

        if (GrammarTopics != null && GrammarTopics.Count > 0)
        {
            data["grammarTopics"] = GrammarTopics;
        }

        if (SkillTypes != null && SkillTypes.Count > 0)
        {
            data["skillTypes"] = SkillTypes;
        }

        // Chỉ export voice data khi HasVoice = true
        if (HasVoice.HasValue && HasVoice.Value)
        {
            data["hasVoice"] = HasVoice.Value;

            if (DefaultVoice != null)
            {
                data["defaultVoice"] = DefaultVoice.ToFirestore();
            }

            if (SpeakerVoices != null && SpeakerVoices.Count > 0)
            {
                data["speakerVoices"] = SpeakerVoices.ToDictionary(
                    kvp => kvp.Key,
                    kvp => (object)kvp.Value.ToFirestore()
                );
            }
        }
        // Nếu HasVoice = false hoặc null, không export bất kỳ voice data nào

        if (!string.IsNullOrEmpty(SequentialTitle))
        {
            data["sequentialTitle"] = SequentialTitle;
        }

        return data;
    }
    
    private Dictionary<string, object> ProcessCrosswordContentForFirestore(Dictionary<string, object> content)
    {
        var processedContent = new Dictionary<string, object>(content);
        
        // Firestore không hỗ trợ nested arrays, nên serialize grid thành JSON string
        if (content.ContainsKey("grid"))
        {
            var gridValue = content["grid"];
            if (gridValue is List<object> gridList)
            {
                // Convert nested array thành flat array với -1 thay vì null
                var processedGrid = new List<List<int>>();
                foreach (var row in gridList)
                {
                    var processedRow = new List<int>();
                    if (row is List<object?> rowListNullable)
                    {
                        foreach (var cell in rowListNullable)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    else if (row is List<object> rowList)
                    {
                        foreach (var cell in rowList)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    else if (row is IEnumerable<object?> rowEnumerable)
                    {
                        foreach (var cell in rowEnumerable)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    processedGrid.Add(processedRow);
                }
                // Serialize thành JSON string
                processedContent["grid"] = JsonConvert.SerializeObject(processedGrid);
            }
        }
        
        return processedContent;
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
            // Nếu là crossword type, convert null values trong grid thành -1 (Firestore không hỗ trợ null trong arrays)
            if (Type == "crossword" && Content.ContainsKey("grid"))
            {
                data["content"] = ProcessCrosswordContentForFirestore(Content);
            }
            else
            {
                data["content"] = Content;
            }
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
    
    private Dictionary<string, object> ProcessCrosswordContentForFirestore(Dictionary<string, object> content)
    {
        var processedContent = new Dictionary<string, object>(content);
        
        // Firestore không hỗ trợ nested arrays, nên serialize grid thành JSON string
        if (content.ContainsKey("grid"))
        {
            var gridValue = content["grid"];
            if (gridValue is List<object> gridList)
            {
                // Convert nested array thành List<List<int>> với -1 thay vì null
                var processedGrid = new List<List<int>>();
                foreach (var row in gridList)
                {
                    var processedRow = new List<int>();
                    if (row is List<object?> rowListNullable)
                    {
                        foreach (var cell in rowListNullable)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    else if (row is List<object> rowList)
                    {
                        foreach (var cell in rowList)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    else if (row is IEnumerable<object?> rowEnumerable)
                    {
                        foreach (var cell in rowEnumerable)
                        {
                            processedRow.Add(cell == null ? -1 : Convert.ToInt32(cell));
                        }
                    }
                    processedGrid.Add(processedRow);
                }
                // Serialize thành JSON string
                processedContent["grid"] = JsonConvert.SerializeObject(processedGrid);
            }
        }
        
        return processedContent;
    }
}


