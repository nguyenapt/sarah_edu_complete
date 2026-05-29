using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

public static class ExerciseTextHelper
{
    public static string ToDisplayText(object? value, string lang = "en")
    {
        if (value == null) return string.Empty;
        if (value is string s) return s;
        if (value is Dictionary<string, string> dict)
            return dict.TryGetValue(lang, out var t) ? t : dict.Values.FirstOrDefault() ?? string.Empty;
        if (value is JObject jo)
        {
            if (jo[lang] != null) return jo[lang]!.ToString();
            return jo.Properties().FirstOrDefault()?.Value?.ToString() ?? string.Empty;
        }
        return value.ToString() ?? string.Empty;
    }

    public static Dictionary<string, string> ToMultilang(object? value)
    {
        if (value is Dictionary<string, string> dict)
            return new Dictionary<string, string>(dict);
        if (value is JObject jo)
        {
            return jo.Properties()
                .Where(p => p.Value.Type == JTokenType.String)
                .ToDictionary(p => p.Name, p => p.Value!.ToString());
        }
        if (value is string s)
            return new Dictionary<string, string> { { "en", s } };
        return new Dictionary<string, string>();
    }

    public static object ToMultilangObject(Dictionary<string, string> map)
    {
        return map;
    }

    public static string SummarizeContent(Dictionary<string, object>? content)
    {
        if (content == null) return "{}";
        try
        {
            if (content.TryGetValue("correctAnswers", out var ca))
                return $"correctAnswers={Newtonsoft.Json.JsonConvert.SerializeObject(ca)}";
            if (content.TryGetValue("options", out var opt))
                return $"options count={((opt as System.Collections.IEnumerable)?.Cast<object>().Count() ?? 0)}";
        }
        catch { }
        return Newtonsoft.Json.JsonConvert.SerializeObject(content);
    }
}
