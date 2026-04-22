import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import 'lesson_detail_screen.dart';
import '../../widgets/common/horizon_top_app_bar.dart';
import '../../core/repositories/catalog_repository.dart';
import '../../models/exercise_model.dart';
import 'exercise_screen.dart';

class UnitListScreen extends StatefulWidget {
  final UnitModel? unit; // Optional: nếu có thì hiển thị unit này
  final List<UnitModel>? units; // Optional: nếu có thì hiển thị tất cả units trong group

  const UnitListScreen({
    super.key,
    this.unit,
    this.units,
  }) : assert(unit != null || units != null, 'Phải cung cấp unit hoặc units');

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  Map<String, List<LessonModel>> _lessonsByUnit = {}; // Map unitId -> lessons
  /// Danh sách bài tập đã aggregate theo từng unit.
  Map<String, List<ExerciseModel>> _exercisesByUnit = {};
  bool _isLoading = true;

  // Lấy danh sách units cần hiển thị
  List<UnitModel> get _unitsToDisplay {
    if (widget.units != null && widget.units!.isNotEmpty) {
      return widget.units!;
    } else if (widget.unit != null) {
      return [widget.unit!];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final units = _unitsToDisplay;
      final lessonsMap = <String, List<LessonModel>>{};
      final exercisesMap = <String, List<ExerciseModel>>{};
      final languageCode =
          Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

      final repo = Provider.of<CatalogRepository>(context, listen: false);

      // Load lessons/exercises cho tất cả units
      for (final unit in units) {
        final lessons = await repo.getLessonsByUnit(
          unit.id,
          onFresh: (fresh) {
            if (!mounted) return;
            setState(() {
              _lessonsByUnit[unit.id] = fresh;
            });
          },
        );
        lessonsMap[unit.id] = lessons;
        exercisesMap[unit.id] = await repo.getExercisesByUnit(
          unit.id,
          languageCode: languageCode,
        );
      }

      setState(() {
        _lessonsByUnit = lessonsMap;
        _exercisesByUnit = exercisesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingData(e.toString())),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HorizonTopAppBar(
        title: AppLocalizations.of(context)!.lessonsList,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _unitsToDisplay.map((unit) {
                  final lessons = _lessonsByUnit[unit.id] ?? [];
                  final exercises = _exercisesByUnit[unit.id] ?? [];
                  return _buildUnitCard(unit, lessons, exercises, languageCode);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildUnitCard(
    UnitModel unit,
    List<LessonModel> lessons,
    List<ExerciseModel> unitExercises,
    String languageCode,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.getTitle(languageCode),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(unit.getDescription(languageCode)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.access_time, size: 18),
                  label: Text('${unit.estimatedTime} ${loc.minutes}'),
                  backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                ),
                if (lessons.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.menu_book, size: 18),
                    label: Text(loc.lessonsCount(lessons.length)),
                    backgroundColor:
                        AppTheme.primaryColor.withOpacity(0.1),
                  ),
                if (unitExercises.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.quiz, size: 18),
                    label: Text(loc.exercisesCount(unitExercises.length)),
                    backgroundColor:
                        AppTheme.primaryColor.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (lessons.isNotEmpty) ...[
              Text(
                loc.lessonsList,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonCard(lesson, index);
                },
              ),
            ],
            if (unitExercises.isNotEmpty) ...[
              if (lessons.isNotEmpty) const SizedBox(height: 24),
              Text(
                loc.exercises,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unitExercises.length,
                itemBuilder: (context, index) {
                  final ex = unitExercises[index];
                  return _buildExerciseCard(ex, index + 1);
                },
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(loc.noLessons),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int displayIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(exercise.difficulty),
          child: Text(
            '$displayIndex',
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
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(
                    _getExerciseTypeLabel(exercise.type),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                Chip(
                  label: Text(
                    _getDifficultyLabel(exercise.difficulty),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise.points} ${AppLocalizations.of(context)!.points}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
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

  Widget _buildLessonCard(LessonModel lesson, int index) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLessonTypeColor(lesson.type),
          child: Icon(
            _getLessonTypeIcon(lesson.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          lesson.getTitle(languageCode),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.lessonNumber(index + 1)),
            if (lesson.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.exercisesCount(lesson.exercises.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailScreen(lesson: lesson),
            ),
          );
        },
      ),
    );
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.grammar:
        return Colors.blue;
      case LessonType.vocabulary:
        return Colors.green;
      case LessonType.listening:
        return Colors.orange;
      case LessonType.speaking:
        return Colors.purple;
      case LessonType.reading:
        return Colors.teal;
      case LessonType.writing:
        return Colors.red;
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.grammar:
        return Icons.auto_stories;
      case LessonType.vocabulary:
        return Icons.book;
      case LessonType.listening:
        return Icons.headphones;
      case LessonType.speaking:
        return Icons.mic;
      case LessonType.reading:
        return Icons.article;
      case LessonType.writing:
        return Icons.edit;
    }
  }
}

