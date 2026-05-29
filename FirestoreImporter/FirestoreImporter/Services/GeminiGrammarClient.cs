using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

public class GeminiGrammarClient : IAiGrammarClient
{
    private readonly HttpClient _httpClient;
    private readonly GrammarAiConfig _config;

    public string ProviderName => "Gemini";

    public GeminiGrammarClient(GrammarAiConfig config, HttpClient? httpClient = null)
    {
        _config = config;
        _httpClient = httpClient ?? new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(config.RequestTimeoutSeconds)
        };
    }

    public async Task<string> CompleteJsonAsync(
        string systemPrompt,
        string userPrompt,
        string model,
        CancellationToken cancellationToken = default)
    {
        var apiKey = _config.GetApiKey(AiGrammarProviders.Gemini);
        if (string.IsNullOrWhiteSpace(apiKey))
            throw new InvalidOperationException("Thiếu Gemini API key. Đặt GEMINI_API_KEY hoặc Gemini.ApiKey trong appsettings.local.json.");

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={Uri.EscapeDataString(apiKey)}";
        var payload = new
        {
            systemInstruction = new { parts = new[] { new { text = systemPrompt } } },
            contents = new[]
            {
                new
                {
                    role = "user",
                    parts = new[] { new { text = userPrompt } }
                }
            },
            generationConfig = new
            {
                temperature = 0.3,
                responseMimeType = "application/json"
            }
        };

        Exception? lastError = null;
        for (var attempt = 0; attempt <= _config.MaxRetries; attempt++)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, url);
                request.Content = new StringContent(
                    JsonConvert.SerializeObject(payload),
                    Encoding.UTF8,
                    "application/json");

                using var response = await _httpClient.SendAsync(request, cancellationToken);
                var body = await response.Content.ReadAsStringAsync(cancellationToken);
                if (!response.IsSuccessStatusCode)
                    throw new HttpRequestException($"Gemini HTTP {(int)response.StatusCode}: {body}");

                var json = JObject.Parse(body);
                var text = json["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]?.ToString();
                if (string.IsNullOrWhiteSpace(text))
                    throw new InvalidOperationException("Gemini trả về nội dung rỗng.");
                return text;
            }
            catch (Exception ex)
            {
                lastError = ex;
                if (attempt >= _config.MaxRetries)
                    break;
                await Task.Delay(TimeSpan.FromSeconds(1 + attempt), cancellationToken);
            }
        }

        throw lastError ?? new Exception("Gemini request failed.");
    }
}
