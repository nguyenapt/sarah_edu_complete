using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter.Services;

public class GrammarEnrichmentPipeline
{
    private readonly IAiGrammarClient _ai;
    private readonly GrammarTopicRegistry _topics;
    private readonly GrammarJsonValidator _validator;
    private readonly GrammarAiConfig _config;
    private readonly UnitGrammarScopeService _unitScope;

    public GrammarEnrichmentPipeline(
        IAiGrammarClient ai,
        GrammarTopicRegistry topics,
        GrammarJsonValidator validator,
        GrammarAiConfig config,
        UnitGrammarScopeService unitScope)
    {
        _ai = ai;
        _topics = topics;
        _validator = validator;
        _config = config;
        _unitScope = unitScope;
    }

    public async Task<TopicAnchorExercisePreview> EnrichExerciseWithTopicAnchorsAsync(
        ExerciseModel exercise,
        UnitModel? unit,
        LessonModel? lesson,
        string enrichmentModel,
        CancellationToken cancellationToken = default)
    {
        var preview = new TopicAnchorExercisePreview
        {
            ExerciseId = exercise.Id,
            LessonId = exercise.LessonId,
            UnitId = exercise.UnitId
        };

        try
        {
            if (unit == null)
                throw new InvalidOperationException($"Không tìm thấy unit {exercise.UnitId} trong dữ liệu đã load.");

            var allowedTopics = await _unitScope.GetAllowedTopicsAsync(unit, enrichmentModel, cancellationToken);

            if (exercise.GroupQuestions == null || exercise.GroupQuestions.Count == 0)
            {
                await EnrichStandaloneExerciseAsync(exercise, lesson, allowedTopics, enrichmentModel, preview, cancellationToken);
                return preview;
            }

            var segmentation = await SegmentQuestionsAsync(exercise, lesson, allowedTopics, enrichmentModel, cancellationToken);
            preview.ExerciseTopics = segmentation.ExerciseTopics;

            var anchorAssignments = TopicAnchorResolver.GetAnchorAssignments(segmentation.QuestionTopics);
            var anchorIndexSet = anchorAssignments.Select(a => a.Index).ToHashSet();

            Phase1AnchorExplanationsResult? anchorResult = null;
            if (anchorAssignments.Count > 0)
            {
                anchorResult = await WriteAnchorExplanationsAsync(
                    exercise,
                    lesson,
                    allowedTopics,
                    anchorAssignments,
                    enrichmentModel,
                    cancellationToken);
            }

            var patchByIndex = anchorResult?.AnchorPatches.ToDictionary(p => p.Index) ?? new Dictionary<int, AnchorExplanationPatch>();

            for (var i = 0; i < exercise.GroupQuestions.Count; i++)
            {
                var gq = exercise.GroupQuestions[i];
                var topic = segmentation.QuestionTopics.FirstOrDefault(q => q.Index == i)?.TopicId ?? "";
                var isAnchor = anchorIndexSet.Contains(i);
                var before = ExerciseTextHelper.ToDisplayText(gq.Explanation, "vi");

                Dictionary<string, string>? patchExp = null;
                string after = "";
                if (isAnchor && patchByIndex.TryGetValue(i, out var patch))
                {
                    patchExp = patch.Explanation;
                    after = patch.Explanation.TryGetValue("vi", out var vi) ? vi : patch.Explanation.Values.FirstOrDefault() ?? "";
                }

                preview.Rows.Add(new TopicAnchorQuestionPreviewRow
                {
                    ExerciseId = exercise.Id,
                    LessonId = exercise.LessonId,
                    UnitId = exercise.UnitId,
                    Index = i,
                    TopicId = topic,
                    IsAnchor = isAnchor,
                    Accepted = isAnchor,
                    BeforeExplanation = before,
                    AfterExplanation = after,
                    PatchExplanation = patchExp
                });
            }
        }
        catch (Exception ex)
        {
            preview.Skipped = true;
            preview.Error = ex.Message;
        }

        return preview;
    }

    public void ApplyTopicAnchorPreview(ExerciseModel exercise, TopicAnchorExercisePreview preview)
    {
        if (preview.Skipped || preview.ExerciseTopics.Count > 0)
            exercise.GrammarTopics = preview.ExerciseTopics;

        if (exercise.GroupQuestions == null || exercise.GroupQuestions.Count == 0)
        {
            var anchorRow = preview.Rows.FirstOrDefault(r =>
                r.IsAnchor && r.Accepted && r.PatchExplanation != null);
            if (anchorRow?.PatchExplanation != null)
                exercise.Explanation = anchorRow.PatchExplanation;
            return;
        }

        foreach (var row in preview.Rows)
        {
            if (!row.Accepted || !row.IsAnchor || row.PatchExplanation == null)
                continue;
            if (row.Index < 0 || row.Index >= exercise.GroupQuestions.Count)
                continue;
            exercise.GroupQuestions[row.Index].Explanation = row.PatchExplanation;
        }
    }

    private async Task EnrichStandaloneExerciseAsync(
        ExerciseModel exercise,
        LessonModel? lesson,
        List<string> allowedTopics,
        string model,
        TopicAnchorExercisePreview preview,
        CancellationToken cancellationToken)
    {
        var segmentation = new Phase1SegmentationResult
        {
            ExerciseTopics = _topics.NormalizeTopics(exercise.GrammarTopics),
            QuestionTopics = new List<QuestionTopicAssignment>
            {
                new() { Index = 0, TopicId = exercise.GrammarTopics.FirstOrDefault() ?? allowedTopics.First() }
            }
        };
        if (segmentation.ExerciseTopics.Count == 0)
            segmentation.ExerciseTopics = allowedTopics.Take(1).ToList();

        var anchors = TopicAnchorResolver.GetAnchorAssignments(segmentation.QuestionTopics);
        var anchorResult = await WriteAnchorExplanationsAsync(
            exercise,
            lesson,
            allowedTopics,
            anchors,
            model,
            cancellationToken,
            standalone: true);

        var patch = anchorResult.AnchorPatches.FirstOrDefault();
        preview.ExerciseTopics = segmentation.ExerciseTopics;
        preview.Rows.Add(new TopicAnchorQuestionPreviewRow
        {
            ExerciseId = exercise.Id,
            LessonId = exercise.LessonId,
            UnitId = exercise.UnitId,
            Index = 0,
            TopicId = anchors.FirstOrDefault()?.TopicId ?? "",
            IsAnchor = true,
            BeforeExplanation = ExerciseTextHelper.ToDisplayText(exercise.Explanation, "vi"),
            AfterExplanation = patch?.Explanation.TryGetValue("vi", out var vi) == true ? vi : "",
            PatchExplanation = patch?.Explanation
        });
    }

    private async Task<Phase1SegmentationResult> SegmentQuestionsAsync(
        ExerciseModel exercise,
        LessonModel? lesson,
        List<string> allowedTopics,
        string model,
        CancellationToken cancellationToken)
    {
        var systemPrompt =
            "You classify each sub-question in an ESL exercise by grammar topic.\n" +
            "Return ONLY JSON: {\"exerciseTopics\":[\"...\"],\"questionTopics\":[{\"index\":0,\"topicId\":\"...\"}]}\n" +
            $"Each topicId MUST be one of unit allowed topics: {string.Join(", ", allowedTopics)}\n" +
            "exerciseTopics = distinct topics used in this exercise.\n" +
            "questionTopics must include EVERY sub-question index from 0 to N-1 exactly once.\n" +
            "Do NOT use correct answers to decide — infer from question wording and lesson context only.";

        var questions = exercise.GroupQuestions!.Select((gq, i) => new
        {
            index = i,
            question = ExerciseTextHelper.ToDisplayText(gq.Question, "en")
        });

        var userPrompt = JsonConvert.SerializeObject(new
        {
            exerciseId = exercise.Id,
            lessonTitle = lesson?.Title != null ? ExerciseTextHelper.ToDisplayText(lesson.Title, "en") : "",
            allowedTopics,
            existingExerciseTopics = exercise.GrammarTopics,
            questions
        }, Formatting.Indented);

        var raw = await _ai.CompleteJsonAsync(systemPrompt, userPrompt, model, cancellationToken);
        var errors = _validator.ValidateSegmentation(raw);
        if (errors.Count > 0)
            throw new InvalidOperationException($"{_ai.ProviderName} segmentation: {string.Join("; ", errors)}");

        var result = JsonConvert.DeserializeObject<Phase1SegmentationResult>(raw)
            ?? throw new InvalidOperationException("Segmentation JSON null.");

        ValidateSegmentationAgainstExercise(exercise, result, allowedTopics);
        result.ExerciseTopics = _topics.NormalizeTopics(result.ExerciseTopics);
        foreach (var qt in result.QuestionTopics)
            qt.TopicId = _topics.NormalizeTopics(new[] { qt.TopicId }).FirstOrDefault() ?? qt.TopicId;

        return result;
    }

    private static void ValidateSegmentationAgainstExercise(
        ExerciseModel exercise,
        Phase1SegmentationResult result,
        List<string> allowedTopics)
    {
        var count = exercise.GroupQuestions?.Count ?? 0;
        if (result.QuestionTopics.Count != count)
            throw new InvalidOperationException($"questionTopics phải có {count} phần tử, nhận {result.QuestionTopics.Count}.");

        for (var i = 0; i < count; i++)
        {
            if (!result.QuestionTopics.Any(q => q.Index == i))
                throw new InvalidOperationException($"Thiếu index {i} trong questionTopics.");
        }

        foreach (var qt in result.QuestionTopics)
        {
            if (!allowedTopics.Contains(qt.TopicId, StringComparer.OrdinalIgnoreCase))
                throw new InvalidOperationException($"topicId {qt.TopicId} không thuộc unit scope.");
        }
    }

    private async Task<Phase1AnchorExplanationsResult> WriteAnchorExplanationsAsync(
        ExerciseModel exercise,
        LessonModel? lesson,
        List<string> allowedTopics,
        List<QuestionTopicAssignment> anchors,
        string model,
        CancellationToken cancellationToken,
        bool standalone = false)
    {
        var anchorInputs = anchors.Select(a =>
        {
            string questionText;
            if (standalone)
                questionText = ExerciseTextHelper.ToDisplayText(exercise.Question, "en");
            else
                questionText = ExerciseTextHelper.ToDisplayText(
                    exercise.GroupQuestions![a.Index].Question, "en");

            var entry = _topics.Topics.FirstOrDefault(t =>
                t.Id.Equals(a.TopicId, StringComparison.OrdinalIgnoreCase));

            return new
            {
                index = a.Index,
                topicId = a.TopicId,
                topicLabelEn = entry?.LabelEn ?? a.TopicId,
                topicLabelVi = entry?.LabelVi ?? a.TopicId,
                question = questionText
            };
        });

        var theorySnippet = "";
        if (lesson?.Content?.Theory != null)
        {
            theorySnippet = ExerciseTextHelper.ToDisplayText(lesson.Content.Theory.Description, "en");
            if (theorySnippet.Length > 800)
                theorySnippet = theorySnippet[..800] + "...";
        }

        var systemPrompt =
            "You write ESL grammar mini-lessons for Sarah Edu.\n" +
            "Return ONLY JSON: {\"anchorPatches\":[{\"index\":0,\"topicId\":\"...\",\"explanation\":{\"en\":\"...\",\"vi\":\"...\"}}]}\n" +
            "RULES:\n" +
            "- Teach grammar structure ONLY: form, meaning, time markers, typical uses.\n" +
            "- Use standalone examples NOT copied from the exercise question.\n" +
            "- NEVER mention correct answers, options, blanks, or what the student should choose.\n" +
            "- NEVER say 'the answer is', 'choose', 'correct option'.\n" +
            $"- Languages required: {string.Join(", ", _config.Languages)}.\n" +
            "- 3-6 sentences per language.\n" +
            "- One patch per anchor index provided.\n" +
            GrammarExplanationFormatter.PromptFormattingRules;

        var englishTermsHint = GrammarExplanationFormatter.BuildAnchorEnglishTermsHint(
            anchors.Select(a =>
            {
                var entry = _topics.Topics.FirstOrDefault(t =>
                    t.Id.Equals(a.TopicId, StringComparison.OrdinalIgnoreCase));
                return (a.Index, entry?.LabelEn ?? a.TopicId);
            }));

        var userPrompt = JsonConvert.SerializeObject(new
        {
            exerciseId = exercise.Id,
            lessonTitle = lesson?.Title != null ? ExerciseTextHelper.ToDisplayText(lesson.Title, "en") : "",
            theorySnippet,
            allowedTopics,
            englishTermsHint,
            anchors = anchorInputs
        }, Formatting.Indented);

        var raw = await _ai.CompleteJsonAsync(systemPrompt, userPrompt, model, cancellationToken);
        var errors = _validator.ValidateAnchorExplanations(raw);
        if (errors.Count > 0)
            throw new InvalidOperationException($"{_ai.ProviderName} anchor explanations: {string.Join("; ", errors)}");

        var result = JsonConvert.DeserializeObject<Phase1AnchorExplanationsResult>(raw)
            ?? throw new InvalidOperationException("Anchor explanations JSON null.");

        foreach (var p in result.AnchorPatches)
        {
            p.TopicId = _topics.NormalizeTopics(new[] { p.TopicId }).FirstOrDefault() ?? p.TopicId;
            p.Explanation = GrammarExplanationFormatter.FormatMultilang(p.Explanation);
        }

        return result;
    }
}
