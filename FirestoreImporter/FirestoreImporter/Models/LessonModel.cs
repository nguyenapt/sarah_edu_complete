using Newtonsoft.Json;

namespace FirestoreImporter.Models;

public class LessonModel
{
    [JsonProperty("id")]
    public string Id { get; set; } = string.Empty;

    [JsonProperty("unitId")]
    public string UnitId { get; set; } = string.Empty;

    [JsonProperty("levelId")]
    public string LevelId { get; set; } = string.Empty;

    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    [JsonProperty("type")]
    public string Type { get; set; } = "grammar";

    [JsonProperty("order")]
    public int Order { get; set; }

    [JsonProperty("content")]
    public LessonContent? Content { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "unitId", UnitId },
            { "levelId", LevelId },
            { "type", Type },
            { "order", Order }
        };

        if (Title != null)
        {
            data["title"] = Title;
        }

        if (Content != null)
        {
            data["content"] = Content.ToFirestore();
        }

        return data;
    }
}

public class LessonContent
{
    [JsonProperty("theory")]
    public TheoryContent? Theory { get; set; }

    [JsonProperty("exercises")]
    public List<string> Exercises { get; set; } = new();

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "exercises", Exercises }
        };

        if (Theory != null)
        {
            data["theory"] = Theory.ToFirestore();
        }

        return data;
    }
}

public class TheoryContent
{
    [JsonProperty("title")]
    public Dictionary<string, string>? Title { get; set; }

    /// <summary>
    /// Description chứa raw HTML (không bị escape).
    /// Key là language code (ví dụ: "en", "vi"), value là raw HTML string.
    /// </summary>
    [JsonProperty("description")]
    public Dictionary<string, string>? Description { get; set; }

    [JsonProperty("examples")]
    public List<Example> Examples { get; set; } = new();

    [JsonProperty("usage")]
    public object? Usage { get; set; } // Có thể là List<UsageItem> hoặc Map

    [JsonProperty("hints")]
    public Dictionary<string, object> Hints { get; set; } = new();

    [JsonProperty("forms")]
    public GrammarForms? Forms { get; set; }

    [JsonProperty("vocabulary")]
    public VocabularyContent? Vocabulary { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>();

        if (Title != null)
        {
            data["title"] = Title;
        }

        if (Description != null)
        {
            data["description"] = Description;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples.Select(e => e.ToFirestore()).ToList();
        }

        if (Usage != null)
        {
            data["usage"] = Usage;
        }

        if (Forms != null)
        {
            data["forms"] = Forms.ToFirestore();
        }

        if (Vocabulary != null)
        {
            data["vocabulary"] = Vocabulary.ToFirestore();
        }

        if (Hints != null && Hints.Count > 0)
        {
            data["hints"] = Hints;
        }

        return data;
    }
}

public class Example
{
    [JsonProperty("sentence")]
    public string Sentence { get; set; } = string.Empty;

    [JsonProperty("explanation")]
    public Dictionary<string, string>? Explanation { get; set; }

    [JsonProperty("audioUrl")]
    public string? AudioUrl { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "sentence", Sentence }
        };

        if (Explanation != null)
        {
            data["explanation"] = Explanation;
        }

        if (!string.IsNullOrEmpty(AudioUrl))
        {
            data["audioUrl"] = AudioUrl;
        }

        return data;
    }
}

public class GrammarForms
{
    [JsonProperty("statement")]
    public List<string>? Statement { get; set; }

    [JsonProperty("negative")]
    public List<string>? Negative { get; set; }

    [JsonProperty("question")]
    public List<string>? Question { get; set; }

    [JsonProperty("form")]
    public List<string>? Form { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>();

        if (Statement != null)
        {
            data["statement"] = Statement;
        }

        if (Negative != null)
        {
            data["negative"] = Negative;
        }

        if (Question != null)
        {
            data["question"] = Question;
        }

        if (Form != null)
        {
            data["form"] = Form;
        }

        return data;
    }
}

// Vocabulary Content Classes
public class TopicVocabularyItem
{
    [JsonProperty("word")]
    public string Word { get; set; } = string.Empty;

    [JsonProperty("partOfSpeech")]
    public string PartOfSpeech { get; set; } = string.Empty;

    [JsonProperty("definitions")]
    public Dictionary<string, string>? Definitions { get; set; }

    [JsonProperty("examples")]
    public List<string> Examples { get; set; } = new();

    [JsonProperty("audioUrl")]
    public string? AudioUrl { get; set; }

    [JsonProperty("imageUrl")]
    public string? ImageUrl { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "word", Word },
            { "partOfSpeech", PartOfSpeech }
        };

        if (Definitions != null)
        {
            data["definitions"] = Definitions;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples;
        }

        if (!string.IsNullOrEmpty(AudioUrl))
        {
            data["audioUrl"] = AudioUrl;
        }

        if (!string.IsNullOrEmpty(ImageUrl))
        {
            data["imageUrl"] = ImageUrl;
        }

        return data;
    }
}

public class PhrasalVerbItem
{
    [JsonProperty("verb")]
    public string Verb { get; set; } = string.Empty;

    [JsonProperty("definition")]
    public Dictionary<string, string>? Definition { get; set; }

    [JsonProperty("examples")]
    public List<string> Examples { get; set; } = new();

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "verb", Verb }
        };

        if (Definition != null)
        {
            data["definition"] = Definition;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples;
        }

        return data;
    }
}

public class PrepositionalPhraseItem
{
    [JsonProperty("phrase")]
    public string Phrase { get; set; } = string.Empty;

    [JsonProperty("definition")]
    public Dictionary<string, string>? Definition { get; set; }

    [JsonProperty("examples")]
    public List<string> Examples { get; set; } = new();

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "phrase", Phrase }
        };

        if (Definition != null)
        {
            data["definition"] = Definition;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples;
        }

        return data;
    }
}

public class WordFormationItem
{
    [JsonProperty("baseWord")]
    public string BaseWord { get; set; } = string.Empty;

    [JsonProperty("relatedForms")]
    public List<string> RelatedForms { get; set; } = new();

    [JsonProperty("examples")]
    public List<string> Examples { get; set; } = new();

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>
        {
            { "baseWord", BaseWord }
        };

        if (RelatedForms != null && RelatedForms.Count > 0)
        {
            data["relatedForms"] = RelatedForms;
        }

        if (Examples != null && Examples.Count > 0)
        {
            data["examples"] = Examples;
        }

        return data;
    }
}

public class WordPatternItem
{
    [JsonProperty("category")]
    public string Category { get; set; } = string.Empty; // adjective, verb, noun

    [JsonProperty("pattern")]
    public string Pattern { get; set; } = string.Empty;

    [JsonProperty("example")]
    public string Example { get; set; } = string.Empty;

    public Dictionary<string, object> ToFirestore()
    {
        return new Dictionary<string, object>
        {
            { "category", Category },
            { "pattern", Pattern },
            { "example", Example }
        };
    }
}

public class VocabularyContent
{
    [JsonProperty("topicVocabulary")]
    public List<TopicVocabularyItem>? TopicVocabulary { get; set; }

    [JsonProperty("phrasalVerbs")]
    public List<PhrasalVerbItem>? PhrasalVerbs { get; set; }

    [JsonProperty("prepositionalPhrases")]
    public List<PrepositionalPhraseItem>? PrepositionalPhrases { get; set; }

    [JsonProperty("wordFormation")]
    public List<WordFormationItem>? WordFormation { get; set; }

    [JsonProperty("wordPatterns")]
    public List<WordPatternItem>? WordPatterns { get; set; }

    public Dictionary<string, object> ToFirestore()
    {
        var data = new Dictionary<string, object>();

        if (TopicVocabulary != null && TopicVocabulary.Count > 0)
        {
            data["topicVocabulary"] = TopicVocabulary.Select(e => e.ToFirestore()).ToList();
        }

        if (PhrasalVerbs != null && PhrasalVerbs.Count > 0)
        {
            data["phrasalVerbs"] = PhrasalVerbs.Select(e => e.ToFirestore()).ToList();
        }

        if (PrepositionalPhrases != null && PrepositionalPhrases.Count > 0)
        {
            data["prepositionalPhrases"] = PrepositionalPhrases.Select(e => e.ToFirestore()).ToList();
        }

        if (WordFormation != null && WordFormation.Count > 0)
        {
            data["wordFormation"] = WordFormation.Select(e => e.ToFirestore()).ToList();
        }

        if (WordPatterns != null && WordPatterns.Count > 0)
        {
            data["wordPatterns"] = WordPatterns.Select(e => e.ToFirestore()).ToList();
        }

        return data;
    }
}


