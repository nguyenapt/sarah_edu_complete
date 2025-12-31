using Newtonsoft.Json;
using FirestoreImporter.Models;

namespace FirestoreImporter.Services;

public class JsonParser
{
    public static ImportData ParseJsonFile(string filePath)
    {
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException($"Không tìm thấy file: {filePath}");
        }

        var jsonContent = File.ReadAllText(filePath);
        var importData = JsonConvert.DeserializeObject<ImportData>(jsonContent);

        if (importData == null)
        {
            throw new InvalidOperationException("Không thể parse JSON file. Vui lòng kiểm tra định dạng.");
        }

        // Gán ID cho các models từ key của dictionary
        if (importData.Units != null)
        {
            foreach (var kvp in importData.Units)
            {
                kvp.Value.Id = kvp.Key;
            }
        }

        if (importData.Lessons != null)
        {
            foreach (var kvp in importData.Lessons)
            {
                kvp.Value.Id = kvp.Key;
            }
        }

        if (importData.Exercises != null)
        {
            foreach (var kvp in importData.Exercises)
            {
                kvp.Value.Id = kvp.Key;
            }
        }

        return importData;
    }
}


