using FirestoreImporter.Models;

namespace FirestoreImporter.Services;

public static class TopicAnchorResolver
{
    public static List<QuestionTopicAssignment> GetAnchorAssignments(IEnumerable<QuestionTopicAssignment> questionTopics)
    {
        return questionTopics
            .GroupBy(q => q.TopicId, StringComparer.OrdinalIgnoreCase)
            .Select(g => g.OrderBy(x => x.Index).First())
            .OrderBy(a => a.Index)
            .ToList();
    }

    public static HashSet<int> GetAnchorIndexSet(IEnumerable<QuestionTopicAssignment> questionTopics)
    {
        return GetAnchorAssignments(questionTopics).Select(a => a.Index).ToHashSet();
    }
}
