using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter.Services;

public class GrammarCheckpointPipeline
{
    private readonly IAiGrammarClient _ai;
    private readonly GrammarTopicRegistry _topics;
    private readonly GrammarJsonValidator _validator;
    private readonly GrammarAiConfig _config;

    public GrammarCheckpointPipeline(
        IAiGrammarClient ai,
        GrammarTopicRegistry topics,
        GrammarJsonValidator validator,
        GrammarAiConfig config)
    {
        _ai = ai;
        _topics = topics;
        _validator = validator;
        _config = config;
    }

    private string CheckpointModel =>
        _config.GetCheckpointModel(
            string.Equals(_ai.ProviderName, "Gemini", StringComparison.OrdinalIgnoreCase)
                ? AiGrammarProviders.Gemini
                : AiGrammarProviders.OpenAi);

    public async Task<Phase2LessonAnalysis?> AnalyzeLessonAsync(
        string lessonId,
        List<ExerciseModel> exercises,
        LessonModel? lesson,
        List<string> suggestedAnchors,
        CancellationToken cancellationToken = default)
    {
        var sorted = exercises.OrderBy(e => e.Id, Comparer<string>.Create(ExerciseIdPlanner.CompareExerciseIds)).ToList();
        var summary = sorted.Select(e => new
        {
            id = e.Id,
            type = e.Type,
            question = ExerciseTextHelper.ToDisplayText(e.Question, "en"),
            grammarTopics = e.GrammarTopics,
            correct = ExerciseTextHelper.SummarizeContent(e.Content)
        });

        var systemPrompt =
            "You analyze ESL lesson exercises and plan grammar checkpoint placements.\n" +
            "Return ONLY JSON: {\"inferredGrammarTopic\":\"topic_id\",\"confidence\":0.9,\"checkpoints\":[{\"afterExerciseId\":\"...\",\"teachThenPractice\":true}]}\n" +
            $"Allowed grammar topic ids: {_topics.AllowedIdsForPrompt()}\n" +
            "Use afterExerciseId from the provided exercise list. Prefer suggested anchors when appropriate.\n" +
            $"Maximum checkpoints: {_config.MaxCheckpointsPerLesson}.";

        var userPrompt = JsonConvert.SerializeObject(new
        {
            lessonId,
            lessonTitle = lesson?.Title != null ? ExerciseTextHelper.ToDisplayText(lesson.Title, "en") : "",
            theorySnippet = lesson?.Content?.Theory?.Description != null
                ? ExerciseTextHelper.ToDisplayText(lesson.Content.Theory.Description, "en")
                : "",
            suggestedAnchors,
            exercises = summary
        }, Formatting.Indented);

        var raw = await _ai.CompleteJsonAsync(
            systemPrompt,
            userPrompt,
            CheckpointModel,
            cancellationToken);

        var errors = _validator.ValidatePhase2Analysis(raw);
        if (errors.Count > 0)
            throw new InvalidOperationException(string.Join("; ", errors));

        var analysis = JsonConvert.DeserializeObject<Phase2LessonAnalysis>(raw);
        if (analysis == null) return null;

        if (!_topics.IsValidTopic(analysis.InferredGrammarTopic))
            analysis.InferredGrammarTopic = _topics.NormalizeTopics(
                sorted.SelectMany(e => e.GrammarTopics).Distinct()).FirstOrDefault()
                ?? analysis.InferredGrammarTopic;

        return analysis;
    }

    public async Task<ExerciseModel> GenerateCheckpointAsync(
        Phase2LessonAnalysis analysis,
        ExerciseModel anchorExercise,
        CancellationToken cancellationToken = default)
    {
        var systemPrompt =
            "You create one grammar checkpoint exercise for Sarah Edu.\n" +
            "Return ONLY JSON for a single exercise body (no id).\n" +
            "Type should be \"button_single_choice\" (grammar note shown before answering).\n" +
            $"Allowed grammarTopics: {_topics.AllowedIdsForPrompt()}\n" +
            $"Use grammar topic: {analysis.InferredGrammarTopic}\n" +
            "question and explanation must be multilang objects with \"en\" and \"vi\".\n" +
            "explanation is a mini-lesson (3-6 sentences per language).\n" +
            GrammarExplanationFormatter.PromptFormattingRules + "\n" +
            "content must have options (4 items) and correctAnswers (1 item).\n" +
            "skillTypes must include \"grammar\". points=5, difficulty=\"easy\".";

        var topicEntry = _topics.Topics.FirstOrDefault(t =>
            t.Id.Equals(analysis.InferredGrammarTopic, StringComparison.OrdinalIgnoreCase));
        var englishTermsHint = GrammarExplanationFormatter.BuildAnchorEnglishTermsHint(
            new[] { (0, topicEntry?.LabelEn ?? analysis.InferredGrammarTopic) });

        var userPrompt = JsonConvert.SerializeObject(new
        {
            anchorExerciseId = anchorExercise.Id,
            anchorQuestion = ExerciseTextHelper.ToDisplayText(anchorExercise.Question, "en"),
            inferredGrammarTopic = analysis.InferredGrammarTopic,
            englishTermsHint,
            levelId = anchorExercise.LevelId,
            unitId = anchorExercise.UnitId,
            lessonId = anchorExercise.LessonId
        }, Formatting.Indented);

        var raw = await _ai.CompleteJsonAsync(
            systemPrompt,
            userPrompt,
            CheckpointModel,
            cancellationToken);

        var errors = _validator.ValidatePhase2Checkpoint(raw);
        if (errors.Count > 0)
            throw new InvalidOperationException(string.Join("; ", errors));

        var payload = JsonConvert.DeserializeObject<Phase2CheckpointPayload>(raw)
            ?? throw new InvalidOperationException("Checkpoint payload null.");

        payload.GrammarTopics = _topics.NormalizeTopics(
            payload.GrammarTopics.Count > 0 ? payload.GrammarTopics : new List<string> { analysis.InferredGrammarTopic });

        payload.Explanation = GrammarExplanationFormatter.FormatMultilang(payload.Explanation);

        return new ExerciseModel
        {
            LessonId = anchorExercise.LessonId,
            UnitId = anchorExercise.UnitId,
            LevelId = anchorExercise.LevelId,
            Type = payload.Type,
            Question = payload.Question,
            Explanation = payload.Explanation,
            Content = payload.Content,
            GrammarTopics = payload.GrammarTopics,
            SkillTypes = payload.SkillTypes.Count > 0 ? payload.SkillTypes : new List<string> { "grammar" },
            Points = payload.Points,
            Difficulty = payload.Difficulty,
            ContentMeta = new Dictionary<string, object>
            {
                { "role", "grammar_checkpoint" },
                { "source", "ai_v1" },
                { "afterExerciseId", anchorExercise.Id }
            }
        };
    }

    public List<CheckpointPreview> BuildCheckpointPreviews(
        ImportData data,
        string lessonId,
        Phase2LessonAnalysis analysis,
        IProgress<string>? progress = null)
    {
        if (data.Exercises == null)
            return new List<CheckpointPreview>();

        var lessonExercises = data.Exercises
            .Where(kvp => kvp.Value.LessonId == lessonId)
            .OrderBy(kvp => kvp.Key, Comparer<string>.Create(ExerciseIdPlanner.CompareExerciseIds))
            .ToList();

        var lesson = data.Lessons?.Values.FirstOrDefault(l => l.Id == lessonId);
        var previews = new List<CheckpointPreview>();
        var cumulativeRenames = new Dictionary<string, string>();

        foreach (var placement in analysis.Checkpoints)
        {
            var anchorId = placement.AfterExerciseId;
            if (!data.Exercises.ContainsKey(anchorId))
            {
                progress?.Report($"Bỏ qua checkpoint: không tìm thấy anchor {anchorId}");
                continue;
            }

            var lessonIds = lessonExercises.Select(k => cumulativeRenames.TryGetValue(k.Key, out var mapped) ? mapped : k.Key).ToList();
            var plan = ExerciseIdPlanner.PlanInsertAfter(anchorId, lessonIds);

            foreach (var rename in plan.Renames)
            {
                cumulativeRenames[rename.Key] = rename.Value;
                if (data.Exercises.TryGetValue(rename.Key, out var ex))
                {
                    data.Exercises.Remove(rename.Key);
                    ex.Id = rename.Value;
                    data.Exercises[rename.Value] = ex;
                }
            }

            var anchor = data.Exercises[anchorId];
            previews.Add(new CheckpointPreview
            {
                NewExerciseId = plan.NewExerciseId,
                AfterExerciseId = anchorId,
                LessonId = lessonId,
                IdRenames = new Dictionary<string, string>(plan.Renames),
                Summary = $"Chèn sau {anchorId} → {plan.NewExerciseId}"
            });
        }

        return previews;
    }

    public void ApplyCheckpointToData(
        ImportData data,
        CheckpointPreview preview,
        ExerciseModel checkpointExercise)
    {
        checkpointExercise.Id = preview.NewExerciseId;
        data.Exercises ??= new Dictionary<string, ExerciseModel>();
        data.Exercises[preview.NewExerciseId] = checkpointExercise;

        if (data.Lessons != null)
        {
            var lesson = data.Lessons.Values.FirstOrDefault(l => l.Id == preview.LessonId);
            if (lesson != null)
            {
                lesson.Content ??= new LessonContent();
                if (!lesson.Content.Exercises.Contains(preview.NewExerciseId))
                {
                    var anchorIndex = lesson.Content.Exercises.IndexOf(preview.AfterExerciseId);
                    if (anchorIndex >= 0)
                        lesson.Content.Exercises.Insert(anchorIndex + 1, preview.NewExerciseId);
                    else
                        lesson.Content.Exercises.Add(preview.NewExerciseId);
                }
            }
        }
    }
}
