import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';

class ExerciseScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  dynamic _selectedAnswer;
  bool _isSubmitted = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
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
                            _getExerciseTypeLabel(widget.exercise.type),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        if (widget.exercise.timeLimit != null)
                          Row(
                            children: [
                              Icon(Icons.timer, size: 16),
                              const SizedBox(width: 4),
                              Text('${widget.exercise.timeLimit}s'),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.exercise.question,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${widget.exercise.points} điểm'),
                        const SizedBox(width: 16),
                        Chip(
                          label: Text(
                            _getDifficultyLabel(widget.exercise.difficulty),
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

            // Answer Section based on type
            _buildAnswerSection(),

            const SizedBox(height: 24),

            // Submit Button
            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswer != null ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Nộp bài',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Result
            if (_isSubmitted) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    switch (widget.exercise.type) {
      case ExerciseType.singleChoice:
        return _buildSingleChoice();
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice();
      case ExerciseType.fillBlank:
        return _buildFillBlank();
      case ExerciseType.matching:
        return _buildMatching();
      default:
        return const Center(child: Text('Loại bài tập này chưa được hỗ trợ'));
    }
  }

  Widget _buildSingleChoice() {
    final content = widget.exercise.content as ChoiceContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn một đáp án đúng:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...content.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedAnswer == option;
          final isCorrectAnswer = content.correctAnswers.contains(option);

          Color? backgroundColor;
          if (_isSubmitted) {
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withOpacity(0.2);
            } else if (isSelected && !isCorrectAnswer) {
              backgroundColor = Colors.red.withOpacity(0.2);
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: backgroundColor,
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: _isSubmitted
                  ? null
                  : (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
              secondary: _isSubmitted && isCorrectAnswer
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : _isSubmitted && isSelected && !isCorrectAnswer
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultipleChoice() {
    final content = widget.exercise.content as ChoiceContent;
    final selectedAnswers = _selectedAnswer as List<String>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn tất cả đáp án đúng:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...content.options.map((option) {
          final isSelected = selectedAnswers.contains(option);
          final isCorrectAnswer = content.correctAnswers.contains(option);

          Color? backgroundColor;
          if (_isSubmitted) {
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withOpacity(0.2);
            } else if (isSelected && !isCorrectAnswer) {
              backgroundColor = Colors.red.withOpacity(0.2);
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: backgroundColor,
            child: CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: _isSubmitted
                  ? null
                  : (value) {
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
              secondary: _isSubmitted && isCorrectAnswer
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : _isSubmitted && isSelected && !isCorrectAnswer
                      ? const Icon(Icons.cancel, color: Colors.red)
                      : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillBlank() {
    // Simplified version - in real app, you'd need more complex UI
    return const Center(
      child: Text('Fill blank exercise - Coming soon'),
    );
  }

  Widget _buildMatching() {
    // Simplified version - in real app, you'd need drag-and-drop UI
    return const Center(
      child: Text('Matching exercise - Coming soon'),
    );
  }

  void _handleSubmit() {
    bool isCorrect = false;

    switch (widget.exercise.type) {
      case ExerciseType.singleChoice:
        final content = widget.exercise.content as ChoiceContent;
        isCorrect = content.correctAnswers.contains(_selectedAnswer);
        break;
      case ExerciseType.multipleChoice:
        final content = widget.exercise.content as ChoiceContent;
        final selected = _selectedAnswer as List<String>? ?? [];
        isCorrect = selected.length == content.correctAnswers.length &&
            selected.every((answer) => content.correctAnswers.contains(answer));
        break;
      default:
        isCorrect = false;
    }

    setState(() {
      _isSubmitted = true;
      _isCorrect = isCorrect;
    });
  }

  Widget _buildResultSection() {
    return Card(
      color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrect ? 'Chính xác!' : 'Sai rồi!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.exercise.explanation != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Giải thích',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.exercise.explanation!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Bạn nhận được ${_isCorrect ? widget.exercise.points : 0} điểm',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getExerciseTypeLabel(ExerciseType type) {
    switch (type) {
      case ExerciseType.singleChoice:
        return 'Chọn 1 đáp án';
      case ExerciseType.multipleChoice:
        return 'Chọn nhiều đáp án';
      case ExerciseType.fillBlank:
        return 'Điền từ';
      case ExerciseType.matching:
        return 'Nối';
      case ExerciseType.listening:
        return 'Nghe';
      case ExerciseType.speaking:
        return 'Nói';
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Dễ';
      case Difficulty.medium:
        return 'Trung bình';
      case Difficulty.hard:
        return 'Khó';
    }
  }
}


