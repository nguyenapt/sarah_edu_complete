import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/placement_test_model.dart';
import '../../core/services/placement_test_service.dart';
import '../../core/services/placement_storage_service.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import 'placement_test_result_screen.dart';

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  final PlacementTestService _testService = PlacementTestService();
  
  List<PlacementTestQuestion> _allQuestions = [];
  List<PlacementTestQuestion> _testQuestions = [];
  List<PlacementTestAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  DateTime? _startTime;
  int _timeSpentSeconds = 0;
  Timer? _timer;

  // Answer state
  dynamic _selectedAnswer; // String for single choice, List<String> for multiple choice

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null && mounted) {
        setState(() {
          _timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
        });
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final questions = await _testService.loadQuestions();
      _allQuestions = questions;
      
      // Tạo adaptive test sequence (bắt đầu với 10 câu A1-A2)
      _testQuestions = _testService.createAdaptiveTestSequence(
        _allQuestions,
        [], // Chưa có answers
      );

      _startTime = DateTime.now();
      _startTimer();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _handleNext() {
    if (_currentQuestionIndex >= _testQuestions.length - 1) {
      _handleSubmit();
      return;
    }

    // Lưu câu trả lời hiện tại
    _saveCurrentAnswer();

    // Adaptive logic: Nếu đã trả lời 10 câu, tạo lại sequence
    if (_answers.length == 10 && _currentQuestionIndex == 9) {
      _testQuestions = _testService.createAdaptiveTestSequence(
        _allQuestions,
        _answers,
      );
      // Giữ lại 10 câu đầu, thêm 10 câu mới
      _testQuestions = [
        ..._testQuestions.take(10),
        ..._testQuestions.skip(10).take(10),
      ];
    } else if (_answers.length == 20 && _currentQuestionIndex == 19) {
      _testQuestions = _testService.createAdaptiveTestSequence(
        _allQuestions,
        _answers,
      );
      // Giữ lại 20 câu đầu, thêm 10 câu cuối
      _testQuestions = [
        ..._testQuestions.take(20),
        ..._testQuestions.skip(20).take(10),
      ];
    }

    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
    });
  }

  void _handlePrevious() {
    if (_currentQuestionIndex > 0) {
      _saveCurrentAnswer();
      setState(() {
        _currentQuestionIndex--;
        _loadAnswerForCurrentQuestion();
      });
    }
  }

  void _saveCurrentAnswer() {
    if (_selectedAnswer == null) return;

    final question = _testQuestions[_currentQuestionIndex];
    bool isCorrect = false;

    if (question.type == PlacementTestType.singleChoice) {
      isCorrect = question.correctAnswers.contains(_selectedAnswer);
    } else if (question.type == PlacementTestType.multipleChoice) {
      final selected = _selectedAnswer as List<String>? ?? [];
      isCorrect = selected.length == question.correctAnswers.length &&
          selected.every((answer) => question.correctAnswers.contains(answer));
    } else if (question.type == PlacementTestType.fillBlank) {
      isCorrect = question.correctAnswers.contains(_selectedAnswer);
    }

    // Tìm hoặc cập nhật answer
    final existingIndex = _answers.indexWhere(
      (a) => a.questionId == question.id,
    );

    final answer = PlacementTestAnswer(
      questionId: question.id,
      selectedAnswers: question.type == PlacementTestType.multipleChoice
          ? List<String>.from(_selectedAnswer ?? [])
          : [_selectedAnswer?.toString() ?? ''],
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _answers[existingIndex] = answer;
    } else {
      _answers.add(answer);
    }
  }

  void _loadAnswerForCurrentQuestion() {
    final question = _testQuestions[_currentQuestionIndex];
    final answer = _answers.firstWhere(
      (a) => a.questionId == question.id,
      orElse: () => PlacementTestAnswer(
        questionId: question.id,
        selectedAnswers: [],
        isCorrect: false,
        answeredAt: DateTime.now(),
      ),
    );

    if (question.type == PlacementTestType.multipleChoice) {
      _selectedAnswer = List<String>.from(answer.selectedAnswers);
    } else {
      _selectedAnswer = answer.selectedAnswers.isNotEmpty
          ? answer.selectedAnswers.first
          : null;
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    _saveCurrentAnswer();

    // Tính thời gian
    if (_startTime != null) {
      _timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Tạo result
      final result = _testService.createResult(
        _testQuestions,
        _answers,
        _timeSpentSeconds,
        null, // Guest user
      );

      // Lưu vào local storage
      await PlacementStorageService.savePlacementTestResult(result);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlacementTestResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting test: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageCode = languageProvider.currentLanguageCode;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.placementTest),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_testQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.placementTest),
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final question = _testQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _testQuestions.length;
    final isLastQuestion = _currentQuestionIndex >= _testQuestions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.placementTest),
        actions: [
          if (_startTime != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_timeSpentSeconds ~/ 60}:${(_timeSpentSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_testQuestions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  _getCategoryLabel(question.category),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              Chip(
                                label: Text(
                                  question.level.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            question.getQuestion(languageCode),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${question.points} points'),
                              const SizedBox(width: 16),
                              Chip(
                                label: Text(
                                  question.difficulty,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer section
                  _buildAnswerSection(question, languageCode),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handlePrevious,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer != null && !_isSubmitting
                        ? (isLastQuestion ? _handleSubmit : _handleNext)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isLastQuestion ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(PlacementTestQuestion question, String languageCode) {
    switch (question.type) {
      case PlacementTestType.singleChoice:
        return _buildSingleChoice(question);
      case PlacementTestType.multipleChoice:
        return _buildMultipleChoice(question);
      case PlacementTestType.fillBlank:
        return _buildFillBlank(question);
    }
  }

  Widget _buildSingleChoice(PlacementTestQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.selectOneAnswer}:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...question.options.asMap().entries.map((entry) {
          final option = entry.value;
          final isSelected = _selectedAnswer == option;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultipleChoice(PlacementTestQuestion question) {
    final selectedAnswers = _selectedAnswer as List<String>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.selectAllCorrectAnswers}:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...question.options.map((option) {
          final isSelected = selectedAnswers.contains(option);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            child: CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  final current = List<String>.from(selectedAnswers);
                  if (value == true) {
                    current.add(option);
                  } else {
                    current.remove(option);
                  }
                  _selectedAnswer = current;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillBlank(PlacementTestQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.selectOneAnswer}:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...question.options.map((option) {
          final isSelected = _selectedAnswer == option;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  String _getCategoryLabel(PlacementTestCategory category) {
    switch (category) {
      case PlacementTestCategory.vocabulary:
        return 'Vocabulary';
      case PlacementTestCategory.grammar:
        return 'Grammar';
      case PlacementTestCategory.reading:
        return 'Reading';
      case PlacementTestCategory.listening:
        return 'Listening';
    }
  }
}

