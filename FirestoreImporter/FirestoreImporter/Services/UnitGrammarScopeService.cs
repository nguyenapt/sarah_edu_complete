using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter.Services;

public class UnitGrammarScopeService
{
    private readonly IAiGrammarClient _ai;
    private readonly GrammarTopicRegistry _topics;
    private readonly GrammarJsonValidator _validator;
    private readonly GrammarAiConfig _config;
    private readonly Dictionary<string, List<string>> _cache = new(StringComparer.OrdinalIgnoreCase);

    public UnitGrammarScopeService(
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

    public async Task<List<string>> GetAllowedTopicsAsync(
        UnitModel unit,
        string model,
        CancellationToken cancellationToken = default)
    {
        if (_cache.TryGetValue(unit.Id, out var cached))
            return cached;

        var titleEn = ExerciseTextHelper.ToDisplayText(unit.Title, "en");
        var titleVi = ExerciseTextHelper.ToDisplayText(unit.Title, "vi");
        var descEn = ExerciseTextHelper.ToDisplayText(unit.Description, "en");
        var descVi = ExerciseTextHelper.ToDisplayText(unit.Description, "vi");

        var systemPrompt =
            "You map ESL curriculum unit metadata to grammar topic ids.\n" +
            "Return ONLY JSON: {\"allowedTopicIds\":[\"topic_id\",...]}\n" +
            $"Allowed ids (use ONLY from this list): {_topics.AllowedIdsForPrompt()}\n" +
            "Pick all topics explicitly or implicitly covered by the unit title/description.";

        var userPrompt = JsonConvert.SerializeObject(new
        {
            unitId = unit.Id,
            levelId = unit.LevelId,
            title = new { en = titleEn, vi = titleVi },
            description = new { en = descEn, vi = descVi }
        }, Formatting.Indented);

        var raw = await _ai.CompleteJsonAsync(systemPrompt, userPrompt, model, cancellationToken);
        var errors = _validator.ValidateUnitScope(raw);
        if (errors.Count > 0)
            throw new InvalidOperationException($"{_ai.ProviderName} unit scope: {string.Join("; ", errors)}");

        var result = JsonConvert.DeserializeObject<Phase1UnitScopeResult>(raw)
            ?? throw new InvalidOperationException("Unit scope JSON null.");

        var normalized = _topics.NormalizeTopics(result.AllowedTopicIds);
        if (normalized.Count == 0)
            throw new InvalidOperationException($"Không suy được topic cho unit {unit.Id}.");

        _cache[unit.Id] = normalized;
        return normalized;
    }
}
