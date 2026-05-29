namespace FirestoreImporter.Services;

public interface IAiGrammarClient
{
    string ProviderName { get; }

    Task<string> CompleteJsonAsync(
        string systemPrompt,
        string userPrompt,
        string model,
        CancellationToken cancellationToken = default);
}

public static class AiGrammarProviders
{
    public const string OpenAi = "openai";
    public const string Gemini = "gemini";
}
