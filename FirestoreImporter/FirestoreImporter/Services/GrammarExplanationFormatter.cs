using System.Text;
using System.Text.RegularExpressions;

namespace FirestoreImporter.Services;

/// <summary>
/// Chuẩn hóa grammar explanation: HTML nhẹ + quy tắc field vi (không hardcode từ khóa cụ thể).
/// </summary>
public static class GrammarExplanationFormatter
{
    public const string PromptFormattingRules =
        "FORMATTING (each language string):\n" +
        "- Use light HTML: <p> per paragraph, <ul>/<li> for lists, <b> for emphasis.\n" +
        "- Do NOT return one plain-text blob without tags.\n" +
        PromptViFieldRules;

    /// <summary>Quy tắc tổng quát cho field vi — áp dụng mọi chủ đề ngữ pháp, không liệt kê từ cố định.</summary>
    public const string PromptViFieldRules =
        "Field \"vi\" (English-learning app):\n" +
        "- Use Vietnamese only for explanatory glue (mô tả, hướng dẫn nối giữa các ý).\n" +
        "- Do NOT translate English study material into Vietnamese.\n" +
        "- English study material = anything the learner must read/recognize in English: " +
        "example sentences, quoted phrases, comma-separated word lists, grammatical forms, " +
        "collocations, time/frequency markers, and the topic label in English when provided.\n" +
        "- Workflow: write \"en\" first, then \"vi\" — copy the same English study-material spans from \"en\" verbatim inside Vietnamese sentences.\n" +
        "- UI labels (e.g. \"Ví dụ:\") may be Vietnamese.";

    /// <summary>Gợi ý động theo topic/anchor hiện tại (từ taxonomy), không hardcode từ khóa.</summary>
    public static string? BuildAnchorEnglishTermsHint(IEnumerable<(int Index, string TopicLabelEn)> anchors)
    {
        var lines = anchors
            .Where(a => !string.IsNullOrWhiteSpace(a.TopicLabelEn))
            .Select(a => $"index {a.Index}: {a.TopicLabelEn.Trim()}")
            .Distinct()
            .ToList();

        if (lines.Count == 0)
            return null;

        return "Topic labels in English for this request (keep verbatim in \"vi\" when referenced): "
            + string.Join("; ", lines);
    }

    public static Dictionary<string, string> FormatMultilang(Dictionary<string, string>? explanation)
    {
        if (explanation == null || explanation.Count == 0)
            return new Dictionary<string, string>();

        return explanation.ToDictionary(
            kvp => kvp.Key,
            kvp => FormatLanguage(kvp.Key, kvp.Value));
    }

    public static string FormatLanguage(string langCode, string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return text;

        return EnsureLightHtml(text.Trim());
    }

    public static string EnsureLightHtml(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return text;

        if (HasBlockHtml(text))
            return text;

        var paragraphs = text.Split(new[] { "\n\n", "\r\n\r\n" }, StringSplitOptions.RemoveEmptyEntries);
        if (paragraphs.Length > 1)
            return string.Concat(paragraphs.Select(p => $"<p>{p.Trim()}</p>"));

        var sentences = Regex.Split(text, @"(?<=[.!?])\s+")
            .Select(s => s.Trim())
            .Where(s => s.Length > 0)
            .ToList();

        if (sentences.Count <= 2)
            return $"<p>{text}</p>";

        var sb = new StringBuilder();
        for (var i = 0; i < sentences.Count; i += 2)
        {
            var chunk = string.Join(" ", sentences.Skip(i).Take(2));
            sb.Append("<p>").Append(chunk).Append("</p>");
        }

        return sb.ToString();
    }

    private static bool HasBlockHtml(string text) =>
        Regex.IsMatch(text, @"</?(p|ul|ol|li|br|div|h[1-6])\b", RegexOptions.IgnoreCase);
}
