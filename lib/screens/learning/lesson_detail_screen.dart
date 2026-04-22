import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../practice/vocabulary_flashcard_screen.dart';
import '../../widgets/common/horizon_top_app_bar.dart';

enum VocabularySortOption { wordAsc, wordDesc, definitionAsc, definitionDesc }

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  String _vocabularySearchQuery = '';
  VocabularySortOption _vocabularySortOption = VocabularySortOption.wordAsc;

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HorizonTopAppBar(
        title: widget.lesson.getTitle(languageCode),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theory Section
            if (widget.lesson.theory != null) _buildTheorySection(),
          ],
        ),
      ),
    );
  }

  /// Fixes HTML table by removing tbody tags and problematic inline styles
  String _fixTableHtml(String html) {
    if (!html.contains('<table')) {
      return html;
    }
    
    var fixedHtml = html;
    
    // Remove all style attributes from table tags
    fixedHtml = fixedHtml.replaceAllMapped(
      RegExp(r'<table[^>]*>', caseSensitive: false),
      (match) {
        final tag = match.group(0)!;
        // Remove style attribute completely (handle both double and single quotes)
        var newTag = tag.replaceAll(RegExp(r'\s*style\s*=\s*"[^"]*"', caseSensitive: false), '');
        newTag = newTag.replaceAll(RegExp(r"\s*style\s*=\s*'[^']*'", caseSensitive: false), '');
        return newTag;
      },
    );
    
    // Remove inline width styles from td/th tags that might cause rendering issues
    fixedHtml = fixedHtml.replaceAllMapped(
      RegExp(r'<td[^>]*style="[^"]*width:[^"]*"[^>]*>', caseSensitive: false),
      (match) {
        final tag = match.group(0)!;
        // Remove width from style attribute
        var newTag = tag.replaceAll(RegExp(r'width\s*:\s*[^;"]*;?\s*', caseSensitive: false), '');
        newTag = newTag.replaceAll(RegExp(r'style="\s*;"'), '');
        newTag = newTag.replaceAll(RegExp(r'style=""'), '');
        return newTag;
      },
    );
    
    // Remove tbody tags if present (keep the content inside)
    fixedHtml = fixedHtml.replaceAll(RegExp(r'</?tbody[^>]*>', caseSensitive: false), '');
    
    return fixedHtml;
  }

  Map<String, Style> _tableStylesForTheory() {
    return {
      'table': Style(
        margin: Margins.only(bottom: 16),
      ),
      'td': Style(
        border: Border.all(color: Colors.grey[400]!, width: 1),
        padding: HtmlPaddings.all(8),
        fontSize: FontSize(13),
        backgroundColor: Colors.white,
        color: Colors.black,
      ),
      'th': Style(
        border: Border.all(color: Colors.grey[400]!, width: 1),
        padding: HtmlPaddings.all(8),
        fontSize: FontSize(13),
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.grey[100],
        color: Colors.black,
      ),
    };
  }

  Map<String, Style> _tableStylesGreyBorders() {
    return {
      'table': Style(
        border: Border.all(color: Colors.grey, width: 1),
        margin: Margins.symmetric(vertical: 8),
      ),
      'tr': Style(
        border: Border.all(color: Colors.grey, width: 1),
      ),
      'td': Style(
        border: Border.all(color: Colors.grey, width: 1),
        padding: HtmlPaddings.all(8),
      ),
      'th': Style(
        border: Border.all(color: Colors.grey, width: 1),
        padding: HtmlPaddings.all(8),
        backgroundColor: Colors.grey[200],
        fontWeight: FontWeight.bold,
      ),
    };
  }

  Map<String, Style> _theoryDescriptionStyleMap(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyLarge;
    final color = body?.color ?? Colors.black;
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(body?.fontSize ?? 16),
        color: color,
      ),
      'p': Style(
        margin: Margins.only(bottom: 8),
        color: color,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      'span': Style(
        color: color,
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _grammarFormLineStyleMap() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'p': Style(
        margin: Margins.only(bottom: 4),
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
      ),
      ..._tableStylesGreyBorders(),
    };
  }

  Map<String, Style> _usageTitleStyleMap() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(16),
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(16),
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
      'span': Style(
        color: AppTheme.primaryColor,
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _usageExampleStyleMap() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
      'span': Style(
        color: Colors.grey[700],
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _exampleSentenceStyleMap(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w500,
        color: color,
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        fontSize: FontSize(16),
        fontWeight: FontWeight.w500,
        color: color,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      'span': Style(
        color: color,
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _exampleExplanationStyleMap() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
      'span': Style(
        color: Colors.grey[700],
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _vocabDefinitionStyleMap(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;
    final color = body?.color ?? Colors.black;
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(body?.fontSize ?? 14),
        color: color,
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        color: color,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      'span': Style(
        color: color,
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _vocabExampleBulletStyleMap() {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'p': Style(
        margin: Margins.only(bottom: 4),
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
      'span': Style(
        color: Colors.grey[700],
      ),
      ..._tableStylesForTheory(),
    };
  }

  Map<String, Style> _wordPatternTitleStyleMap(BuildContext context) {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(Theme.of(context).textTheme.titleMedium?.fontSize ?? 16),
      ),
      'p': Style(
        margin: Margins.only(bottom: 6),
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      'strong': Style(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
      'span': Style(
        color: AppTheme.primaryColor,
      ),
      ..._tableStylesForTheory(),
    };
  }

  Widget _buildLessonHtml(String raw, Map<String, Style> style) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();
    return Html(
      data: _fixTableHtml(raw),
      extensions: const [
        TableHtmlExtension(),
      ],
      style: style,
    );
  }

  Widget _buildTheorySection() {
    final theory = widget.lesson.theory!;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.theory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              theory.getTitle(languageCode),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                return _buildLessonHtml(
                  theory.getDescription(languageCode),
                  _theoryDescriptionStyleMap(context),
                );
              },
            ),
            if (theory.usage != null && theory.usage!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildUsageSection(theory.usage!, languageCode),
            ],
            if (theory.forms != null) ...[
              const SizedBox(height: 16),
              _buildFormsSection(theory.forms!, languageCode),
            ],
            if (theory.vocabulary != null) ...[
              const SizedBox(height: 16),
              _buildVocabularySection(theory.vocabulary!, languageCode),
            ],
            if (theory.examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildExamplesSection(theory.examples, languageCode),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormsSection(GrammarForms forms, String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.sentenceForms,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (forms.statement != null && forms.statement!.isNotEmpty)
          _buildFormList(
            AppLocalizations.of(context)!.affirmative,
            forms.getStatement(),
            Icons.check_circle,
          ),
        if (forms.negative != null && forms.negative!.isNotEmpty)
          _buildFormList(
            AppLocalizations.of(context)!.negative,
            forms.getNegative(),
            Icons.cancel,
          ),
        if (forms.question != null && forms.question!.isNotEmpty)
          _buildFormList(
            AppLocalizations.of(context)!.interrogative,
            forms.getQuestion(),
            Icons.help_outline,
          ),
        if (forms.form != null && forms.form!.isNotEmpty)
          _buildFormList(
            AppLocalizations.of(context)!.grammarForm,
            forms.getForm(),
            Icons.article_outlined,
          ),
      ],
    );
  }

  Widget _buildFormList(String label, List<String> forms, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...forms.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: _buildLessonHtml(entry.value, _grammarFormLineStyleMap()),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUsageSection(List<UsageItem> usageItems, String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.howToUse,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...usageItems.map((item) => _buildUsageItem(item, languageCode)),
      ],
    );
  }

  Widget _buildUsageItem(UsageItem item, String languageCode) {
    final title = item.getTitle(languageCode);
    final example = item.getExample(languageCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              _buildLessonHtml(title, _usageTitleStyleMap()),
              const SizedBox(height: 8),
            ],
            if (example.isNotEmpty)
              _buildLessonHtml(example, _usageExampleStyleMap()),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularySection(VocabularyContent vocabulary, String languageCode) {
    final topicVocabularyItems = vocabulary.topicVocabulary ?? [];
    final filteredTopicVocabulary = _filterAndSortTopicVocabulary(
      topicVocabularyItems,
      languageCode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Vocabulary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Topic Vocabulary
        if (topicVocabularyItems.isNotEmpty) ...[
          _buildTopicVocabularyControls(filteredTopicVocabulary, languageCode),
          const SizedBox(height: 8),
          if (filteredTopicVocabulary.isEmpty)
            Text(
              AppLocalizations.of(context)!.vocabularyNoMatch,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            )
          else
            ...filteredTopicVocabulary.map((item) => _buildTopicVocabularyItem(item, languageCode)),
          const SizedBox(height: 16),
        ],
        // Phrasal Verbs
        if (vocabulary.phrasalVerbs != null && vocabulary.phrasalVerbs!.isNotEmpty) ...[
          Text(
            'Phrasal Verbs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...vocabulary.phrasalVerbs!.map((item) => _buildPhrasalVerbItem(item, languageCode)),
          const SizedBox(height: 16),
        ],
        // Prepositional Phrases
        if (vocabulary.prepositionalPhrases != null && vocabulary.prepositionalPhrases!.isNotEmpty) ...[
          Text(
            'Prepositional Phrases',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...vocabulary.prepositionalPhrases!.map((item) => _buildPrepositionalPhraseItem(item, languageCode)),
          const SizedBox(height: 16),
        ],
        // Word Formation
        if (vocabulary.wordFormation != null && vocabulary.wordFormation!.isNotEmpty) ...[
          Text(
            'Word Formation',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildWordFormationTable(vocabulary.wordFormation!),
          const SizedBox(height: 16),
        ],
        // Word Patterns
        if (vocabulary.wordPatterns != null && vocabulary.wordPatterns!.isNotEmpty) ...[
          Text(
            'Word Patterns',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildWordPatternsSection(vocabulary.wordPatterns!),
        ],
      ],
    );
  }

  Widget _buildTopicVocabularyItem(TopicVocabularyItem item, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.word,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    item.partOfSpeech,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
                if (item.audioUrl != null) ...[
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () {
                      // TODO: Implement audio playback
                    },
                  ),
                ],
              ],
            ),
            if (item.definitions != null) ...[
              const SizedBox(height: 8),
              _buildLessonHtml(
                item.getDefinition(languageCode),
                _vocabDefinitionStyleMap(context),
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Expanded(
                          child: _buildLessonHtml(
                            example,
                            _vocabExampleBulletStyleMap(),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhrasalVerbItem(PhrasalVerbItem item, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.verb,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            if (item.definition != null) ...[
              const SizedBox(height: 8),
              _buildLessonHtml(
                item.getDefinition(languageCode),
                _vocabDefinitionStyleMap(context),
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Expanded(
                          child: _buildLessonHtml(
                            example,
                            _vocabExampleBulletStyleMap(),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  List<TopicVocabularyItem> _filterAndSortTopicVocabulary(
    List<TopicVocabularyItem> items,
    String languageCode,
  ) {
    final query = _vocabularySearchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<TopicVocabularyItem>.from(items)
        : items.where((item) {
            final word = item.word.toLowerCase();
            final definition = item.getDefinition(languageCode).toLowerCase();
            return word.contains(query) || definition.contains(query);
          }).toList();

    int compareBy(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

    filtered.sort((a, b) {
      switch (_vocabularySortOption) {
        case VocabularySortOption.wordAsc:
          return compareBy(a.word, b.word);
        case VocabularySortOption.wordDesc:
          return compareBy(b.word, a.word);
        case VocabularySortOption.definitionAsc:
          return compareBy(a.getDefinition(languageCode), b.getDefinition(languageCode));
        case VocabularySortOption.definitionDesc:
          return compareBy(b.getDefinition(languageCode), a.getDefinition(languageCode));
      }
    });

    return filtered;
  }

  Widget _buildTopicVocabularyControls(
    List<TopicVocabularyItem> currentItems,
    String languageCode,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          localizations.vocabularyFilterLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildTopicVocabularySearchField()),
        const SizedBox(width: 8),
        _buildTopicVocabularySort(),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: currentItems.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VocabularyFlashcardScreen(
                        items: currentItems,
                        languageCode: languageCode,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.practice),
        ),
      ],
    );
  }

  Widget _buildTopicVocabularySort() {
    final localizations = AppLocalizations.of(context)!;
    return DropdownButtonHideUnderline(
      child: SizedBox(
        height: 34,
        child: DropdownButton<VocabularySortOption>(
          value: _vocabularySortOption,
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
              _vocabularySortOption = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTopicVocabularySearchField() {
    final localizations = AppLocalizations.of(context)!;
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
          _vocabularySearchQuery = value;
        });
      },
    );
  }

  Widget _buildPrepositionalPhraseItem(PrepositionalPhraseItem item, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.phrase,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            if (item.definition != null) ...[
              const SizedBox(height: 8),
              _buildLessonHtml(
                item.getDefinition(languageCode),
                _vocabDefinitionStyleMap(context),
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Expanded(
                          child: _buildLessonHtml(
                            example,
                            _vocabExampleBulletStyleMap(),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordFormationTable(List<WordFormationItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(color: Colors.grey[300]!),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Base Word',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Related Forms',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...items.map((item) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        item.baseWord,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(item.relatedForms.join(', ')),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildWordPatternsSection(List<WordPatternItem> items) {
    final adjectives = items.where((item) => item.category.toLowerCase() == 'adjective').toList();
    final verbs = items.where((item) => item.category.toLowerCase() == 'verb').toList();
    final nouns = items.where((item) => item.category.toLowerCase() == 'noun').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (adjectives.isNotEmpty) ...[
          Text(
            'Adjectives',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...adjectives.map((item) => _buildWordPatternItem(item)),
          const SizedBox(height: 16),
        ],
        if (verbs.isNotEmpty) ...[
          Text(
            'Verbs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...verbs.map((item) => _buildWordPatternItem(item)),
          const SizedBox(height: 16),
        ],
        if (nouns.isNotEmpty) ...[
          Text(
            'Nouns',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...nouns.map((item) => _buildWordPatternItem(item)),
        ],
      ],
    );
  }

  Widget _buildWordPatternItem(WordPatternItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLessonHtml(
              item.pattern,
              _wordPatternTitleStyleMap(context),
            ),
            const SizedBox(height: 8),
            _buildLessonHtml(
              item.example,
              _usageExampleStyleMap(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesSection(List<Example> examples, String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.examples,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...examples.map((example) => _buildExampleItem(example, languageCode)),
      ],
    );
  }

  Widget _buildExampleItem(Example example, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLessonHtml(
                    example.sentence,
                    _exampleSentenceStyleMap(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: _buildLessonHtml(
                example.getExplanation(languageCode),
                _exampleExplanationStyleMap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

}


