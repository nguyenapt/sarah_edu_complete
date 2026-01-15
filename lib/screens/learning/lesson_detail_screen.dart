import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../core/services/firestore_service.dart';
import '../../models/exercise_model.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_screen.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  List<ExerciseModel> _exercises = [];
  bool _isLoadingExercises = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoadingExercises = true;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final exercises = await _firestoreService.getExercisesByLesson(
        widget.lesson.id,
        languageCode: languageProvider.currentLanguageCode,
      );
      setState(() {
        _exercises = exercises;
        _isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingExercises = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorLoadingExercises}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.getTitle(languageCode)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theory Section
            if (widget.lesson.theory != null) _buildTheorySection(),

            const SizedBox(height: 24),

            // Exercises Section
            _buildExercisesSection(),
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

  Widget _buildTheorySection() {
    final theory = widget.lesson.theory!;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                final htmlContent = theory.getDescription(languageCode);
                final fixedHtmlContent = _fixTableHtml(htmlContent);               
               
                
                return Html(
                  data: fixedHtmlContent,
                  extensions: [
                    TableHtmlExtension(),
                  ],
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16),
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 8),
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                    "strong": Style(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                    "span": Style(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                    "table": Style(
                      //border: Border.all(color: Colors.grey[400]!, width: 1),
                      margin: Margins.only(bottom: 16),
                    ),
                    "td": Style(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      padding: HtmlPaddings.all(8),
                      fontSize: FontSize(13),
                      backgroundColor: Colors.white,
                      color: Colors.black,
                    ),
                    "th": Style(
                      border: Border.all(color: Colors.grey[400]!, width: 1),
                      padding: HtmlPaddings.all(8),
                      fontSize: FontSize(13),
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.grey[100],
                      color: Colors.black,
                    ),
                  },
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
                      child: Html(
                        data: entry.value,
                        extensions: [
                          TableHtmlExtension(),
                        ],
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                          "strong": Style(
                            fontWeight: FontWeight.bold,
                          ),
                          "table": Style(
                            border: Border.all(color: Colors.grey, width: 1),
                            margin: Margins.symmetric(vertical: 8),
                          ),
                          "tr": Style(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          "td": Style(
                            border: Border.all(color: Colors.grey, width: 1),
                            padding: HtmlPaddings.all(8),
                          ),
                          "th": Style(
                            border: Border.all(color: Colors.grey, width: 1),
                            padding: HtmlPaddings.all(8),
                            backgroundColor: Colors.grey[200],
                            fontWeight: FontWeight.bold,
                          ),
                        },
                      ),
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
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (example.isNotEmpty)
              Text(
                example,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularySection(VocabularyContent vocabulary, String languageCode) {
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
        if (vocabulary.topicVocabulary != null && vocabulary.topicVocabulary!.isNotEmpty) ...[
          Text(
            'Topic Vocabulary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...vocabulary.topicVocabulary!.map((item) => _buildTopicVocabularyItem(item, languageCode)),
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
      margin: const EdgeInsets.only(bottom: 8),
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
              Text(
                item.getDefinition(languageCode),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• $example',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
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
              Text(
                item.getDefinition(languageCode),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• $example',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
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
              Text(
                item.getDefinition(languageCode),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (item.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• $example',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
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
            Text(
              item.pattern,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.example,
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
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
              children: [
                Icon(Icons.format_quote, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    example.sentence,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                example.getExplanation(languageCode),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.quiz, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.exercises,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingExercises)
          const Center(child: CircularProgressIndicator())
        else if (_exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(AppLocalizations.of(context)!.noExercises),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return _buildExerciseCard(exercise, index);
            },
          ),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(exercise.difficulty),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          exercise.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    _getExerciseTypeLabel(exercise.type),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    _getDifficultyLabel(exercise.difficulty),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${exercise.points} ${AppLocalizations.of(context)!.points}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseScreen(exercise: exercise),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    final localizations = AppLocalizations.of(context)!;
    switch (difficulty) {
      case Difficulty.easy:
        return localizations.easy;
      case Difficulty.medium:
        return localizations.medium;
      case Difficulty.hard:
        return localizations.hard;
    }
  }

  String _getExerciseTypeLabel(ExerciseType type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case ExerciseType.singleChoice:
        return localizations.selectOneAnswerShort;
      case ExerciseType.multipleChoice:
        return localizations.selectMultipleAnswersShort;
      case ExerciseType.fillBlank:
        return localizations.fillBlank;
      case ExerciseType.matching:
        return localizations.matching;
      case ExerciseType.listening:
        return localizations.listening;
      case ExerciseType.speaking:
        return localizations.speaking;
      case ExerciseType.buttonSingleChoice:
        return localizations.selectOneAnswerShort;
      case ExerciseType.crossword:
        return localizations.crossword;
      case ExerciseType.sequentialQuestions:
        return 'Sequential Questions';
      case ExerciseType.wordMatching:
        return 'Word Matching';
      case ExerciseType.definitionMatching:
        return 'Definition Matching';
      case ExerciseType.wordFormationExercise:
        return 'Word Formation';
      case ExerciseType.wordPatternExercise:
        return 'Word Pattern';
    }
  }
}


