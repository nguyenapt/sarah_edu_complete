namespace FirestoreImporter.Services;

public static class AiGrammarClientFactory
{
    public static IAiGrammarClient Create(string provider, GrammarAiConfig config)
    {
        var normalized = provider.Trim().ToLowerInvariant();
        return normalized switch
        {
            AiGrammarProviders.Gemini => new GeminiGrammarClient(config),
            AiGrammarProviders.OpenAi or "openai" => new OpenAiGrammarClient(config),
            _ => throw new ArgumentException($"Provider không hỗ trợ: {provider}. Dùng openai hoặc gemini.")
        };
    }

    public static IReadOnlyList<string> GetModelsForProvider(string provider)
    {
        return provider.Trim().ToLowerInvariant() switch
        {
            AiGrammarProviders.Gemini => new[]
            {
                "gemini-2.0-flash",
                "gemini-2.0-flash-lite",
                "gemini-1.5-pro",
                "gemini-1.5-flash"
            },
            _ => new[] { "gpt-4o-mini", "gpt-4o", "gpt-4o-mini-2024-07-18" }
        };
    }
}
