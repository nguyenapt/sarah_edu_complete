import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lesson_model.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../practice/vocabulary_flashcard_screen.dart';

enum VocabularySortOption { wordAsc, wordDesc, definitionAsc, definitionDesc }

class VocabularyCollectionScreen extends StatefulWidget {
  const VocabularyCollectionScreen({super.key});

  @override
  State<VocabularyCollectionScreen> createState() => _VocabularyCollectionScreenState();
}

class _VocabularyCollectionScreenState extends State<VocabularyCollectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<TopicVocabularyItem> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  VocabularySortOption _sortOption = VocabularySortOption.wordAsc;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userLevel = authProvider.user?.currentLevel ?? 'A1';

      final levels = await _firestoreService.getLevels();
      final allowedLevelIds = _getAllowedLevelIds(levels, userLevel);

      final lessons = await _firestoreService.getLessonsByLevelsAndType(
        allowedLevelIds,
        LessonType.vocabulary,
      );

      final units = await _firestoreService.getAllUnits();
      lessons.sort((a, b) => _compareLessonOrder(a, b, levels, units));

      final languageCode =
          Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

      final deduped = <String, TopicVocabularyItem>{};
      for (final lesson in lessons) {
        final topicVocabulary = lesson.theory?.vocabulary?.topicVocabulary ?? [];
        for (final item in topicVocabulary) {
          final key =
              '${item.word.toLowerCase()}|${item.partOfSpeech.toLowerCase()}|${item.getDefinition(languageCode).toLowerCase()}';
          deduped.putIfAbsent(key, () => item);
        }
      }

      if (mounted) {
        setState(() {
          _items
            ..clear()
            ..addAll(deduped.values);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading vocabulary: $e');
    }
  }

  List<String> _getAllowedLevelIds(List<LevelModel> levels, String userLevelId) {
    final userLevel = levels.where((level) => level.id == userLevelId).toList();
    if (userLevel.isEmpty) {
      return levels.map((level) => level.id).toList();
    }
    final userOrder = userLevel.first.order;
    return levels
        .where((level) => level.order <= userOrder)
        .map((level) => level.id)
        .toList();
  }

  int _compareLessonOrder(
    LessonModel a,
    LessonModel b,
    List<LevelModel> levels,
    List<UnitModel> units,
  ) {
    final levelOrderMap = {for (final level in levels) level.id: level.order};
    final unitOrderMap = {for (final unit in units) unit.id: unit.order};

    final aLevelOrder = levelOrderMap[a.levelId] ?? 999;
    final bLevelOrder = levelOrderMap[b.levelId] ?? 999;
    if (aLevelOrder != bLevelOrder) {
      return aLevelOrder.compareTo(bLevelOrder);
    }

    final aUnitOrder = unitOrderMap[a.unitId] ?? 999;
    final bUnitOrder = unitOrderMap[b.unitId] ?? 999;
    if (aUnitOrder != bUnitOrder) {
      return aUnitOrder.compareTo(bUnitOrder);
    }

    return a.order.compareTo(b.order);
  }

  List<TopicVocabularyItem> _filterAndSort(
    List<TopicVocabularyItem> items,
    String languageCode,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<TopicVocabularyItem>.from(items)
        : items.where((item) {
            final word = item.word.toLowerCase();
            final definition = item.getDefinition(languageCode).toLowerCase();
            return word.contains(query) || definition.contains(query);
          }).toList();

    int compareBy(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

    filtered.sort((a, b) {
      switch (_sortOption) {
        case VocabularySortOption.wordAsc:
          return compareBy(a.word, b.word);
        case VocabularySortOption.wordDesc:
          return compareBy(b.word, a.word);
        case VocabularySortOption.definitionAsc:
          return compareBy(
            a.getDefinition(languageCode),
            b.getDefinition(languageCode),
          );
        case VocabularySortOption.definitionDesc:
          return compareBy(
            b.getDefinition(languageCode),
            a.getDefinition(languageCode),
          );
      }
    });

    return filtered;
  }

  void _startPractice(List<TopicVocabularyItem> items, String languageCode) {
    if (items.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyFlashcardScreen(
          items: items,
          languageCode: languageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageCode = Provider.of<LanguageProvider>(context).currentLanguageCode;

    final currentItems = _filterAndSort(_items, languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.vocabulary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(child: _buildSearchField(localizations)),
                      const SizedBox(width: 8),
                      _buildSortDropdown(localizations),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: currentItems.isEmpty
                            ? null
                            : () => _startPractice(currentItems, languageCode),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(localizations.practice),
                      ),
                    ],
                  ),
                ),
                if (currentItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _items.isEmpty
                            ? localizations.practiceVocabularyEmpty
                            : localizations.vocabularyNoMatch,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) =>
                          _buildVocabularyItem(currentItems[index], languageCode),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSearchField(AppLocalizations localizations) {
    return TextField(
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: localizations.vocabularySearchHint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildSortDropdown(AppLocalizations localizations) {
    return DropdownButtonHideUnderline(
      child: SizedBox(
        height: 34,
        child: DropdownButton<VocabularySortOption>(
          value: _sortOption,
          isDense: true,
          iconSize: 18,
          style: Theme.of(context).textTheme.bodySmall,
          items: [
            DropdownMenuItem(
              value: VocabularySortOption.wordAsc,
              child: Text(localizations.vocabularySortWordAsc),
            ),
            DropdownMenuItem(
              value: VocabularySortOption.wordDesc,
              child: Text(localizations.vocabularySortWordDesc),
            ),
            DropdownMenuItem(
              value: VocabularySortOption.definitionAsc,
              child: Text(localizations.vocabularySortDefinitionAsc),
            ),
            DropdownMenuItem(
              value: VocabularySortOption.definitionDesc,
              child: Text(localizations.vocabularySortDefinitionDesc),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _sortOption = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildVocabularyItem(TopicVocabularyItem item, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.word,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ),
                if (item.partOfSpeech.isNotEmpty)
                  Chip(
                    label: Text(
                      item.partOfSpeech,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.getDefinition(languageCode),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.take(2).map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '• $example',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
