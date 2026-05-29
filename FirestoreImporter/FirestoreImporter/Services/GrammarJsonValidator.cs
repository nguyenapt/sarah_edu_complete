using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Schema;

namespace FirestoreImporter.Services;

public class GrammarJsonValidator
{
    private readonly JSchema _phase1;
    private readonly JSchema _segmentation;
    private readonly JSchema _anchorExplanations;
    private readonly JSchema _unitScope;
    private readonly JSchema _phase2Analysis;
    private readonly JSchema _phase2Checkpoint;

    public GrammarJsonValidator()
    {
        var baseDir = Path.Combine(AppContext.BaseDirectory, "Data", "Schemas");
        _phase1 = LoadSchema(Path.Combine(baseDir, "phase1_enrichment.schema.json"));
        _segmentation = LoadSchema(Path.Combine(baseDir, "phase1_segmentation.schema.json"));
        _anchorExplanations = LoadSchema(Path.Combine(baseDir, "phase1_anchor_explanations.schema.json"));
        _unitScope = LoadSchema(Path.Combine(baseDir, "phase1_unit_scope.schema.json"));
        _phase2Analysis = LoadSchema(Path.Combine(baseDir, "phase2_lesson_analysis.schema.json"));
        _phase2Checkpoint = LoadSchema(Path.Combine(baseDir, "phase2_checkpoint_exercise.schema.json"));
    }

    private static JSchema LoadSchema(string path)
    {
        if (!File.Exists(path))
            throw new FileNotFoundException($"Schema không tồn tại: {path}");
        return JSchema.Parse(File.ReadAllText(path));
    }

    public IList<string> ValidatePhase1(string json)
    {
        return Validate(json, _phase1);
    }

    public IList<string> ValidateSegmentation(string json)
    {
        return Validate(json, _segmentation);
    }

    public IList<string> ValidateAnchorExplanations(string json)
    {
        return Validate(json, _anchorExplanations);
    }

    public IList<string> ValidateUnitScope(string json)
    {
        return Validate(json, _unitScope);
    }

    public IList<string> ValidatePhase2Analysis(string json)
    {
        return Validate(json, _phase2Analysis);
    }

    public IList<string> ValidatePhase2Checkpoint(string json)
    {
        return Validate(json, _phase2Checkpoint);
    }

    private static IList<string> Validate(string json, JSchema schema)
    {
        var token = JToken.Parse(json);
        var valid = token.IsValid(schema, out IList<ValidationError>? errors);
        if (valid) return Array.Empty<string>();
        return errors?.Select(e => e.ToString()).ToList() ?? new List<string> { "Unknown schema error" };
    }
}
