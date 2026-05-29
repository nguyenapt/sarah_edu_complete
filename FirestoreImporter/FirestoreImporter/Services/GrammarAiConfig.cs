using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

public class ProviderSettings
{
    public string ApiKey { get; set; } = string.Empty;
    public string EnrichmentModel { get; set; } = "gpt-4o-mini";
    public string CheckpointModel { get; set; } = "gpt-4o-mini";
}

public class GrammarAiConfig
{
    public string DefaultProvider { get; set; } = AiGrammarProviders.OpenAi;
    public ProviderSettings OpenAi { get; set; } = new();
    public ProviderSettings Gemini { get; set; } = new()
    {
        EnrichmentModel = "gemini-2.0-flash",
        CheckpointModel = "gemini-2.0-flash"
    };

    public int MaxRetries { get; set; } = 2;
    public int RequestTimeoutSeconds { get; set; } = 120;
    public List<string> Languages { get; set; } = new() { "en", "vi" };
    public int CheckpointEveryN { get; set; } = 4;
    public int MaxCheckpointsPerLesson { get; set; } = 3;

    public string GetApiKey(string provider)
    {
        return provider.Trim().ToLowerInvariant() switch
        {
            AiGrammarProviders.Gemini => Gemini.ApiKey,
            _ => OpenAi.ApiKey
        };
    }

    public string GetEnrichmentModel(string provider) =>
        provider.Trim().ToLowerInvariant() == AiGrammarProviders.Gemini
            ? Gemini.EnrichmentModel
            : OpenAi.EnrichmentModel;

    public string GetCheckpointModel(string provider) =>
        provider.Trim().ToLowerInvariant() == AiGrammarProviders.Gemini
            ? Gemini.CheckpointModel
            : OpenAi.CheckpointModel;

    public static GrammarAiConfig Load()
    {
        var config = new GrammarAiConfig();
        var baseDir = AppContext.BaseDirectory;

        LoadFile(Path.Combine(baseDir, "appsettings.json"), config);
        LoadFile(Path.Combine(baseDir, "appsettings.local.json"), config);

        var openAiEnv = Environment.GetEnvironmentVariable("OPENAI_API_KEY");
        if (!string.IsNullOrWhiteSpace(openAiEnv))
            config.OpenAi.ApiKey = openAiEnv;

        var geminiEnv = Environment.GetEnvironmentVariable("GEMINI_API_KEY")
            ?? Environment.GetEnvironmentVariable("GOOGLE_API_KEY");
        if (!string.IsNullOrWhiteSpace(geminiEnv))
            config.Gemini.ApiKey = geminiEnv;

        return config;
    }

    private static void LoadFile(string path, GrammarAiConfig config)
    {
        if (!File.Exists(path)) return;

        var json = JObject.Parse(File.ReadAllText(path));
        if (json["GrammarAi"]?["DefaultProvider"] != null)
            config.DefaultProvider = json["GrammarAi"]!["DefaultProvider"]!.ToString();

        LoadProviderSection(json["OpenAI"], config.OpenAi, "gpt-4o-mini");
        LoadProviderSection(json["Gemini"], config.Gemini, "gemini-2.0-flash");

        var grammar = json["GrammarAi"];
        if (grammar != null)
        {
            if (grammar["Languages"] is JArray langs)
                config.Languages = langs.Select(t => t.ToString()).Where(s => !string.IsNullOrEmpty(s)).ToList()!;
            if (grammar["CheckpointEveryN"] != null)
                config.CheckpointEveryN = grammar["CheckpointEveryN"]!.Value<int>();
            if (grammar["MaxCheckpointsPerLesson"] != null)
                config.MaxCheckpointsPerLesson = grammar["MaxCheckpointsPerLesson"]!.Value<int>();
        }

        var openAiRoot = json["OpenAI"];
        if (openAiRoot?["MaxRetries"] != null)
            config.MaxRetries = openAiRoot["MaxRetries"]!.Value<int>();
        if (openAiRoot?["RequestTimeoutSeconds"] != null)
            config.RequestTimeoutSeconds = openAiRoot["RequestTimeoutSeconds"]!.Value<int>();
    }

    private static void LoadProviderSection(JToken? section, ProviderSettings target, string defaultModel)
    {
        if (section == null) return;
        if (section["ApiKey"]?.Type == JTokenType.String && !string.IsNullOrWhiteSpace(section["ApiKey"]!.ToString()))
            target.ApiKey = section["ApiKey"]!.ToString();
        if (section["EnrichmentModel"] != null)
            target.EnrichmentModel = section["EnrichmentModel"]!.ToString();
        else if (string.IsNullOrEmpty(target.EnrichmentModel))
            target.EnrichmentModel = defaultModel;
        if (section["CheckpointModel"] != null)
            target.CheckpointModel = section["CheckpointModel"]!.ToString();
        else if (string.IsNullOrEmpty(target.CheckpointModel))
            target.CheckpointModel = defaultModel;
    }
}
