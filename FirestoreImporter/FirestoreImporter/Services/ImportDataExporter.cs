using FirestoreImporter.Models;
using Newtonsoft.Json;

namespace FirestoreImporter.Services;

public static class ImportDataExporter
{
    public static string ExportToFile(ImportData data, string sourceJsonPath, string suffix = "_grammar_enriched")
    {
        var dir = Path.GetDirectoryName(sourceJsonPath) ?? AppContext.BaseDirectory;
        var name = Path.GetFileNameWithoutExtension(sourceJsonPath);
        var outPath = string.IsNullOrEmpty(suffix)
            ? sourceJsonPath
            : Path.Combine(dir, $"{name}{suffix}.json");
        var json = JsonConvert.SerializeObject(new
        {
            levels = data.Levels,
            units = data.Units,
            lessons = data.Lessons,
            exercises = data.Exercises
        }, Formatting.Indented);
        File.WriteAllText(outPath, json);
        return outPath;
    }
}
