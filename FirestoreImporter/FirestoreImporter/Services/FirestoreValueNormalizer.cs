using System.Collections;
using Google.Cloud.Firestore;
using Newtonsoft.Json.Linq;

namespace FirestoreImporter.Services;

/// <summary>
/// Chuyển giá trị Firestore / Newtonsoft sang kiểu Firestore SDK ghi được.
/// </summary>
public static class FirestoreValueNormalizer
{
    /// <summary>
    /// Chuẩn hóa cây dữ liệu trước SetAsync (loại bỏ JToken, IList lồng không hỗ trợ).
    /// </summary>
    public static Dictionary<string, object> PrepareDocument(Dictionary<string, object> data) =>
        data.ToDictionary(k => k.Key, k => PrepareForWrite(k.Value)!);

    public static object? PrepareForWrite(object? value)
    {
        if (value == null)
            return null;

        switch (value)
        {
            case string or bool:
                return value;
            case int i:
                return (long)i;
            case long or float or double or decimal:
                return value;
            case JValue jv:
                return jv.Type switch
                {
                    JTokenType.Integer => jv.Value<long>(),
                    JTokenType.Float => jv.Value<double>(),
                    JTokenType.Boolean => jv.Value<bool>(),
                    JTokenType.String => jv.Value<string>() ?? "",
                    JTokenType.Null => null!,
                    _ => jv.ToString()
                };
            case JObject jo:
                return jo.Properties()
                    .ToDictionary(p => p.Name, p => PrepareForWrite(p.Value)!);
            case JArray ja:
                return ja.Select(PrepareForWrite).ToList();
            case Dictionary<string, string> dss:
                return dss.ToDictionary(k => k.Key, k => (object)k.Value);
            case Dictionary<string, object> dso:
                return dso.ToDictionary(k => k.Key, k => PrepareForWrite(k.Value)!);
            case IDictionary<string, object> idso:
                return idso.ToDictionary(k => k.Key, k => PrepareForWrite(k.Value)!);
            case IEnumerable enumerable when value is not string:
            {
                var list = new List<object?>();
                foreach (var item in enumerable)
                    list.Add(PrepareForWrite(item));
                return list;
            }
            default:
                return value.ToString() ?? "";
        }
    }

    public static object? Normalize(object? value)
    {
        switch (value)
        {
            case null:
                return null;
            case string or bool or int or long or float or double or decimal:
                return value;
            case Timestamp ts:
                return ts.ToDateTime().ToString("o");
            case Dictionary<string, object> dict:
                return dict.ToDictionary(k => k.Key, k => Normalize(k.Value)!);
            case IEnumerable<object> list:
                return list.Select(Normalize).ToList();
            case IDictionary<string, object> idict:
                return idict.ToDictionary(k => k.Key, k => Normalize(k.Value)!);
            default:
                return value.ToString();
        }
    }

    public static Dictionary<string, object> DocumentToDict(DocumentSnapshot doc)
    {
        var raw = doc.ToDictionary();
        return raw.ToDictionary(k => k.Key, k => Normalize(k.Value)!);
    }

    public static string DocumentToJson(DocumentSnapshot doc)
    {
        var dict = DocumentToDict(doc);
        return JObject.FromObject(dict).ToString();
    }
}
