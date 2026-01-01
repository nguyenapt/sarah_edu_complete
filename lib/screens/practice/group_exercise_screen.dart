import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../core/services/unit_group_service.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/firestore_service.dart';
import '../learning/exercise_screen.dart';

class GroupExerciseScreen extends StatefulWidget {
  final String levelId;
  final String group;
  final String displayName;

  const GroupExerciseScreen({
    super.key,
    required this.levelId,
    required this.group,
    required this.displayName,
  });

  @override
  State<GroupExerciseScreen> createState() => _GroupExerciseScreenState();
}

class _GroupExerciseScreenState extends State<GroupExerciseScreen> {
  final UnitGroupService _unitGroupService = UnitGroupService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ExerciseModel> _exercises = [];
  bool _isLoading = true;
  UserProgressModel? _userProgress;
  Set<String> _completedExerciseIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      // Load exercises
      final exercises = await _unitGroupService.getExercisesByGroup(
        widget.levelId,
        widget.group,
        languageCode: languageProvider.currentLanguageCode,
      );

      // Load user progress nếu đã đăng nhập
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final userId = authProvider.user!.id;
        final progress = await _firestoreService.getUserProgress(userId);
        
        if (progress != null) {
          _completedExerciseIds = progress.exerciseHistory
              .where((item) => exercises.any((e) => e.id == item.exerciseId))
              .map((item) => item.exerciseId)
              .toSet();
          
          setState(() {
            _userProgress = progress;
          });
        }
      }

      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      AppLocalizations.of(context)!.noExercises,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Progress indicator
                    if (_userProgress != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đã hoàn thành: ${_completedExerciseIds.length}/${_exercises.length} bài tập',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Exercises list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          final isCompleted = _completedExerciseIds.contains(exercise.id);
                          return _buildExerciseCard(exercise, index, isCompleted);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel exercise, int index, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCompleted ? Colors.green.withOpacity(0.05) : null,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: _getDifficultyColor(exercise.difficulty),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isCompleted)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
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
          ).then((_) {
            // Reload data sau khi hoàn thành exercise
            _loadData();
          });
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
    }
  }
}

