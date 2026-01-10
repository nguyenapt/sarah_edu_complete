using Newtonsoft.Json;
using System.Linq;
using System.Collections;

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


