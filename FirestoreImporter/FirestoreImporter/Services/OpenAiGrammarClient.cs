using System.Net.Http.Headers;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

public class OpenAiGrammarClient : IAiGrammarClient
{
    private readonly HttpClient _httpClient;
    private readonly GrammarAiConfig _config;

    public string ProviderName => "OpenAI";

    public OpenAiGrammarClient(GrammarAiConfig config, HttpClient? httpClient = null)
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
        var apiKey = _config.GetApiKey(AiGrammarProviders.OpenAi);
        if (string.IsNullOrWhiteSpace(apiKey))
            throw new InvalidOperationException("Thiếu OpenAI API key. Đặt OPENAI_API_KEY hoặc OpenAI.ApiKey trong appsettings.local.json.");

        var payload = new
        {
            model,
            temperature = 0.3,
            response_format = new { type = "json_object" },
            messages = new[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = userPrompt }
            }
        };

        return await SendWithRetryAsync(
            "https://api.openai.com/v1/chat/completions",
            apiKey,
            payload,
            body =>
            {
                var json = JObject.Parse(body);
                return json["choices"]?[0]?["message"]?["content"]?.ToString()
                    ?? throw new InvalidOperationException("OpenAI trả về nội dung rỗng.");
            },
            cancellationToken);
    }

    private async Task<string> SendWithRetryAsync<TPayload>(
        string url,
        string apiKey,
        TPayload payload,
        Func<string, string> parseSuccess,
        CancellationToken cancellationToken)
    {
        Exception? lastError = null;
        for (var attempt = 0; attempt <= _config.MaxRetries; attempt++)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, url);
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                request.Content = new StringContent(
                    JsonConvert.SerializeObject(payload),
                    Encoding.UTF8,
                    "application/json");

                using var response = await _httpClient.SendAsync(request, cancellationToken);
                var body = await response.Content.ReadAsStringAsync(cancellationToken);
                if (!response.IsSuccessStatusCode)
                    throw new HttpRequestException($"OpenAI HTTP {(int)response.StatusCode}: {body}");

                return parseSuccess(body);
            }
            catch (Exception ex)
            {
                lastError = ex;
                if (attempt >= _config.MaxRetries)
                    break;
                await Task.Delay(TimeSpan.FromSeconds(1 + attempt), cancellationToken);
            }
        }

        throw lastError ?? new Exception("OpenAI request failed.");
    }
}
