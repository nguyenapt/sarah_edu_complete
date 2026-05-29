using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class GrammarTopicEntry
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("labelEn")]
    public string LabelEn { get; set; } = string.Empty;

    [JsonProperty("labelVi")]
    public string LabelVi { get; set; } = string.Empty;
}

public class GrammarTopicsFile
{
    [JsonProperty("version")]
    public int Version { get; set; }

    [JsonProperty("topics")]
    public List<GrammarTopicEntry> Topics { get; set; } = new();
}

public class Phase1UnitScopeResult
{
    [JsonProperty("allowedTopicIds")]
    public List<string> AllowedTopicIds { get; set; } = new();
}

public class QuestionTopicAssignment
{
    [JsonProperty("index")]
    public int Index { get; set; }

    [JsonProperty("topicId")]
    public string TopicId { get; set; } = string.Empty;
}

public class Phase1SegmentationResult
{
    [JsonProperty("exerciseTopics")]
    public List<string> ExerciseTopics { get; set; } = new();

    [JsonProperty("questionTopics")]
    public List<QuestionTopicAssignment> QuestionTopics { get; set; } = new();
}

public class AnchorExplanationPatch
{
    [JsonProperty("index")]
    public int Index { get; set; }

    [JsonProperty("topicId")]
    public string TopicId { get; set; } = string.Empty;

    [JsonProperty("explanation")]
    public Dictionary<string, string> Explanation { get; set; } = new();
}

public class Phase1AnchorExplanationsResult
{
    [JsonProperty("anchorPatches")]
    public List<AnchorExplanationPatch> AnchorPatches { get; set; } = new();
}

public class Phase1EnrichmentResult
{
    [JsonProperty("grammarTopics")]
    public List<string> GrammarTopics { get; set; } = new();

    [JsonProperty("explanation")]
    public Dictionary<string, string> Explanation { get; set; } = new();

    [JsonProperty("groupQuestionPatches")]
    public List<GroupQuestionPatch>? GroupQuestionPatches { get; set; }
}

public class GroupQuestionPatch
{
    [JsonProperty("index")]
    public int Index { get; set; }

    [JsonProperty("explanation")]
    public Dictionary<string, string> Explanation { get; set; } = new();
}

public class Phase2LessonAnalysis
{
    [JsonProperty("inferredGrammarTopic")]
    public string InferredGrammarTopic { get; set; } = string.Empty;

    [JsonProperty("confidence")]
    public double Confidence { get; set; }

    [JsonProperty("checkpoints")]
    public List<CheckpointPlacement> Checkpoints { get; set; } = new();
}

public class CheckpointPlacement
{
    [JsonProperty("afterExerciseId")]
    public string AfterExerciseId { get; set; } = string.Empty;

    [JsonProperty("teachThenPractice")]
    public bool TeachThenPractice { get; set; } = true;
}

public class Phase2CheckpointPayload
{
    [JsonProperty("type")]
    public string Type { get; set; } = "button_single_choice";

    [JsonProperty("question")]
    public Dictionary<string, string> Question { get; set; } = new();

    [JsonProperty("explanation")]
    public Dictionary<string, string> Explanation { get; set; } = new();

    [JsonProperty("content")]
    public Dictionary<string, object> Content { get; set; } = new();

    [JsonProperty("grammarTopics")]
    public List<string> GrammarTopics { get; set; } = new();

    [JsonProperty("skillTypes")]
    public List<string> SkillTypes { get; set; } = new();

    [JsonProperty("points")]
    public int Points { get; set; } = 5;

    [JsonProperty("difficulty")]
    public string Difficulty { get; set; } = "easy";
}

public class TopicAnchorQuestionPreviewRow
{
    public string ExerciseId { get; set; } = string.Empty;
    public string LessonId { get; set; } = string.Empty;
    public string UnitId { get; set; } = string.Empty;
    public int Index { get; set; }
    public string TopicId { get; set; } = string.Empty;
    public bool IsAnchor { get; set; }
    public bool Accepted { get; set; } = true;
    public bool Skipped { get; set; }
    public string? Error { get; set; }
    public string BeforeExplanation { get; set; } = string.Empty;
    public string AfterExplanation { get; set; } = string.Empty;
    public Dictionary<string, string>? PatchExplanation { get; set; }
}

public class TopicAnchorExercisePreview
{
    public string ExerciseId { get; set; } = string.Empty;
    public string LessonId { get; set; } = string.Empty;
    public string UnitId { get; set; } = string.Empty;
    public bool Skipped { get; set; }
    public string? Error { get; set; }
    public List<string> ExerciseTopics { get; set; } = new();
    public List<TopicAnchorQuestionPreviewRow> Rows { get; set; } = new();
}

/// <summary>Legacy preview type — giữ cho tương thích upload cũ nếu cần.</summary>
public class ExerciseEnrichmentPreview
{
    public string ExerciseId { get; set; } = string.Empty;
    public string LessonId { get; set; } = string.Empty;
    public string UnitId { get; set; } = string.Empty;
    public bool Accepted { get; set; } = true;
    public bool Skipped { get; set; }
    public string? Error { get; set; }
    public string BeforeExplanation { get; set; } = string.Empty;
    public string AfterExplanation { get; set; } = string.Empty;
    public string BeforeTopics { get; set; } = string.Empty;
    public string AfterTopics { get; set; } = string.Empty;
    public Phase1EnrichmentResult? Patch { get; set; }
}

public class CheckpointPreview
{
    public string NewExerciseId { get; set; } = string.Empty;
    public string AfterExerciseId { get; set; } = string.Empty;
    public string LessonId { get; set; } = string.Empty;
    public bool Accepted { get; set; } = true;
    public Dictionary<string, string> IdRenames { get; set; } = new();
    public ExerciseModel? Exercise { get; set; }
    public string Summary { get; set; } = string.Empty;
}

public class IdInsertPlan
{
    public string NewExerciseId { get; set; } = string.Empty;
    public string AfterExerciseId { get; set; } = string.Empty;
    public Dictionary<string, string> Renames { get; set; } = new();
}
