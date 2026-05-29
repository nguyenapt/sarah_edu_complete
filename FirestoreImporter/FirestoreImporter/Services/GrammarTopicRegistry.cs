using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter.Services;

public class GrammarTopicRegistry
{
    private readonly HashSet<string> _allowedIds = new(StringComparer.OrdinalIgnoreCase);
    private readonly List<GrammarTopicEntry> _topics = new();

    public IReadOnlyList<GrammarTopicEntry> Topics => _topics;

    public static GrammarTopicRegistry LoadDefault()
    {
        var path = Path.Combine(AppContext.BaseDirectory, "Data", "grammar_topics.json");
        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Không tìm thấy grammar_topics.json tại: {path}");
        }

        var file = JsonConvert.DeserializeObject<GrammarTopicsFile>(File.ReadAllText(path))
            ?? throw new InvalidOperationException("grammar_topics.json không hợp lệ.");

        var registry = new GrammarTopicRegistry();
        foreach (var topic in file.Topics)
        {
            registry._topics.Add(topic);
            registry._allowedIds.Add(topic.Id);
        }
        return registry;
    }

    public string AllowedIdsForPrompt()
    {
        return string.Join(", ", _topics.Select(t => t.Id));
    }

    public List<string> NormalizeTopics(IEnumerable<string>? topics)
    {
        if (topics == null) return new List<string>();
        return topics
            .Where(t => !string.IsNullOrWhiteSpace(t) && _allowedIds.Contains(t.Trim()))
            .Select(t => t.Trim().ToLowerInvariant())
            .Distinct()
            .ToList();
    }

    public bool IsValidTopic(string topic) => _allowedIds.Contains(topic);
}
