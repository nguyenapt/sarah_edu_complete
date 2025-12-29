import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with TickerProviderStateMixin {
  dynamic _selectedAnswer;
  bool _isSubmitted = false;
  bool _isCorrect = false;
  
  // Cho button_single_choice
  Map<int, String?> _selectedAnswers = {}; // Map<placeholderIndex, selectedOption>
  List<GlobalKey> _optionKeys = [];
  List<GlobalKey> _placeholderKeys = [];
  Map<String, AnimationController> _animationControllers = {};
  Map<String, Animation<Offset>> _animations = {};
  
  // Cho fill_blank
  Map<int, String> _fillBlankAnswers = {}; // Map<placeholderIndex, userInput>
  
  // Cho groupQuestions - chỉ hiển thị 1 question tại một thời điểm
  int _currentGroupQuestionIndex = 0;
  Map<int, bool> _questionResults = {}; // Map<questionIndex, isCorrect> - lưu kết quả từng question

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exercises),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Card(
              margin: EdgeInsets.zero,
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
                        Text('${widget.exercise.points} ${AppLocalizations.of(context)!.points}'),
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

            // Submit Button - chỉ hiển thị khi không có groupQuestions
            if (!_isSubmitted && 
                (widget.exercise.groupQuestions == null || 
                 widget.exercise.groupQuestions!.isEmpty))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit() ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                    style: const TextStyle(
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

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnswerSection() {
    // Nếu có groupQuestions, hiển thị groupQuestions
    if (widget.exercise.groupQuestions != null && widget.exercise.groupQuestions!.isNotEmpty) {
      return _buildGroupQuestions();
    }
    
    switch (widget.exercise.type) {
      case ExerciseType.singleChoice:
        return _buildSingleChoice();
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice();
      case ExerciseType.fillBlank:
        return _buildFillBlank();
      case ExerciseType.matching:
        return _buildMatching();
      case ExerciseType.buttonSingleChoice:
        return _buildButtonSingleChoice();
      case ExerciseType.listening:
      case ExerciseType.speaking:
      default:
        return Center(child: Text(AppLocalizations.of(context)!.exerciseTypeNotSupported));
    }
  }

  Widget _buildGroupQuestions() {
    final groupQuestions = widget.exercise.groupQuestions!;
    if (_currentGroupQuestionIndex >= groupQuestions.length) {
      _currentGroupQuestionIndex = 0;
    }
    
    final currentQuestion = groupQuestions[_currentGroupQuestionIndex];
    final isLastQuestion = _currentGroupQuestionIndex == groupQuestions.length - 1;
    final hasMultipleQuestions = groupQuestions.length > 1;
    
    return Column(
      children: [
        // Chỉ hiển thị question hiện tại
        if (currentQuestion.type == ExerciseType.buttonSingleChoice)
          _buildButtonSingleChoiceForGroup(currentQuestion, _currentGroupQuestionIndex)
        else if (currentQuestion.type == ExerciseType.fillBlank)
          _buildFillBlankForGroup(currentQuestion, _currentGroupQuestionIndex),
        
        const SizedBox(height: 24),
        
        // Nút điều hướng
        if (!_isSubmitted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitCurrentQuestion() 
                  ? (isLastQuestion ? _handleSubmit : _goToNextQuestion)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isLastQuestion 
                    ? AppLocalizations.of(context)!.submit
                    : AppLocalizations.of(context)!.continueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  void _goToNextQuestion() {
    // Check và lưu kết quả question hiện tại trước khi chuyển
    final currentQuestion = widget.exercise.groupQuestions![_currentGroupQuestionIndex];
    final isCorrect = _checkQuestionAnswer(currentQuestion, _currentGroupQuestionIndex);
    _questionResults[_currentGroupQuestionIndex] = isCorrect;
    
    if (_currentGroupQuestionIndex < widget.exercise.groupQuestions!.length - 1) {
      setState(() {
        _currentGroupQuestionIndex++;
      });
    }
  }
  
  bool _checkQuestionAnswer(GroupQuestion groupQuestion, int questionIndex) {
    if (groupQuestion.type == ExerciseType.buttonSingleChoice) {
      final content = groupQuestion.content as ButtonSingleChoiceContent;
      final placeholderCount = _countPlaceholders(groupQuestion.question);
      final userAnswers = <String>[];
      for (int j = 0; j < placeholderCount; j++) {
        final key = questionIndex * 1000 + j;
        final answer = _selectedAnswers[key];
        if (answer != null) {
          userAnswers.add(answer);
        }
      }
      // So sánh theo thứ tự
      if (userAnswers.length != content.correctAnswers.length) {
        return false;
      }
      for (int j = 0; j < userAnswers.length; j++) {
        if (userAnswers[j] != content.correctAnswers[j]) {
          return false;
        }
      }
      return true;
    } else if (groupQuestion.type == ExerciseType.fillBlank) {
      // Lấy correctAnswers từ content
      Map<int, String> correctAnswersMap = {};
      if (groupQuestion.content is FillBlankContent) {
        final content = groupQuestion.content as FillBlankContent;
        // Lấy tất cả placeholder indices từ question trước
        final regex = RegExp(r'\{(\d+)\}');
        final matches = regex.allMatches(groupQuestion.question);
        final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
        
        // Tạo map từ blanks, nhưng đảm bảo position khớp với placeholder indices
        if (content.blanks.isNotEmpty) {
          final sortedBlanks = List<BlankItem>.from(content.blanks);
          sortedBlanks.sort((a, b) => a.position.compareTo(b.position));
          
          for (int idx = 0; idx < placeholderIndices.length && idx < sortedBlanks.length; idx++) {
            final placeholderIndex = placeholderIndices[idx];
            correctAnswersMap[placeholderIndex] = sortedBlanks[idx].correctAnswer;
          }
        }
      } else if (groupQuestion.content is Map) {
        final contentMap = groupQuestion.content as Map<String, dynamic>;
        if (contentMap['correctAnswers'] != null) {
          final answers = contentMap['correctAnswers'] as List<dynamic>;
          final regex = RegExp(r'\{(\d+)\}');
          final matches = regex.allMatches(groupQuestion.question);
          final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
          for (int idx = 0; idx < placeholderIndices.length && idx < answers.length; idx++) {
            correctAnswersMap[placeholderIndices[idx]] = answers[idx].toString();
          }
        }
      }
      
      // Lấy tất cả placeholder indices từ question
      final regex = RegExp(r'\{(\d+)\}');
      final matches = regex.allMatches(groupQuestion.question);
      final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
      
      if (placeholderIndices.length != correctAnswersMap.length) {
        return false;
      }
      
      for (final placeholderIndex in placeholderIndices) {
        final key = questionIndex * 1000 + placeholderIndex;
        final userAnswer = _fillBlankAnswers[key]?.trim().toLowerCase() ?? '';
        final correctAnswer = correctAnswersMap[placeholderIndex]?.trim().toLowerCase() ?? '';
        if (userAnswer != correctAnswer) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
  
  bool _canSubmitCurrentQuestion() {
    if (widget.exercise.groupQuestions == null || widget.exercise.groupQuestions!.isEmpty) {
      return false;
    }
    
    final currentQuestion = widget.exercise.groupQuestions![_currentGroupQuestionIndex];
    
    if (currentQuestion.type == ExerciseType.buttonSingleChoice) {
      final placeholderCount = _countPlaceholders(currentQuestion.question);
      for (int j = 0; j < placeholderCount; j++) {
        final key = _currentGroupQuestionIndex * 1000 + j;
        if (_selectedAnswers[key] == null) {
          return false;
        }
      }
      return true;
    } else if (currentQuestion.type == ExerciseType.fillBlank) {
      final regex = RegExp(r'\{(\d+)\}');
      final matches = regex.allMatches(currentQuestion.question);
      final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
      
      for (final placeholderIndex in placeholderIndices) {
        final key = _currentGroupQuestionIndex * 1000 + placeholderIndex;
        final answer = _fillBlankAnswers[key];
        if (answer == null || answer.trim().isEmpty) {
          return false;
        }
      }
      return true;
    }
    
    return false;
  }

  Widget _buildButtonSingleChoiceForGroup(GroupQuestion groupQuestion, int groupIndex) {
    final content = groupQuestion.content as ButtonSingleChoiceContent;
    
    // Initialize keys và animations cho group này
    final placeholderCount = _countPlaceholders(groupQuestion.question);
    if (_optionKeys.length < content.options.length) {
      _optionKeys = List.generate(content.options.length, (i) => GlobalKey());
    }
    if (_placeholderKeys.length < placeholderCount) {
      _placeholderKeys = List.generate(placeholderCount, (i) => GlobalKey());
    }
    
    // Initialize selected answers cho group này
    final groupKey = 'group_$groupIndex';
    if (!_selectedAnswers.containsKey(groupIndex)) {
      _selectedAnswers[groupIndex] = null;
    }
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question với placeholders (không có Card wrapper)
            _buildQuestionContent(groupQuestion.question, groupIndex, content),
            const SizedBox(height: 24),
            // Options buttons
            _buildOptionsButtons(content.options, groupIndex, content),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSingleChoice() {
    final content = widget.exercise.content as ButtonSingleChoiceContent;
    final placeholderCount = _countPlaceholders(widget.exercise.question);
    
    // Initialize keys
    _optionKeys = List.generate(content.options.length, (i) => GlobalKey());
    _placeholderKeys = List.generate(placeholderCount, (i) => GlobalKey());
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question với placeholders (không có Card wrapper)
            _buildQuestionContent(widget.exercise.question, -1, content),
            const SizedBox(height: 24),
            // Options buttons
            _buildOptionsButtons(content.options, -1, content),
          ],
        ),
      ),
    );
  }

  int _countPlaceholders(String question) {
    final regex = RegExp(r'\{(\d+)\}');
    final matches = regex.allMatches(question);
    if (matches.isEmpty) return 0;
    final maxIndex = matches.map((m) => int.parse(m.group(1)!)).reduce((a, b) => a > b ? a : b);
    return maxIndex + 1;
  }

  Widget _buildQuestionWithPlaceholders(String question, int groupIndex, ButtonSingleChoiceContent content) {
    final placeholderCount = _countPlaceholders(question);
    final parts = question.split(RegExp(r'\{(\d+)\}'));
    final placeholders = RegExp(r'\{(\d+)\}').allMatches(question).toList();
    
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 8,
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              Text(
                parts[i],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (i < placeholders.length)
                _buildPlaceholderWidget(
                  int.parse(placeholders[i].group(1)!),
                  groupIndex,
                  content,
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Question content không có Card wrapper (dùng khi đã có Card bên ngoài)
  Widget _buildQuestionContent(String question, int groupIndex, ButtonSingleChoiceContent content) {
    final placeholderCount = _countPlaceholders(question);
    final parts = question.split(RegExp(r'\{(\d+)\}'));
    final placeholders = RegExp(r'\{(\d+)\}').allMatches(question).toList();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            Text(
              parts[i],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (i < placeholders.length)
              _buildPlaceholderWidget(
                int.parse(placeholders[i].group(1)!),
                groupIndex,
                content,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget(int placeholderIndex, int groupIndex, ButtonSingleChoiceContent content) {
    final selectedOption = groupIndex == -1 
        ? _selectedAnswers[placeholderIndex]
        : _selectedAnswers[groupIndex * 1000 + placeholderIndex];
    
    // Nếu chưa chọn, hiển thị vùng màu xám
    if (selectedOption == null) {
      return Container(
        key: _placeholderKeys[placeholderIndex],
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 80,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    
    // Kiểm tra đáp án đúng/sai sau khi submit
    Color borderColor = AppTheme.primaryColor;
    Color backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
    
    if (_isSubmitted) {
      final correctAnswer = content.correctAnswers.length > placeholderIndex 
          ? content.correctAnswers[placeholderIndex]
          : null;
      if (correctAnswer != null) {
        if (selectedOption == correctAnswer) {
          borderColor = Colors.green;
          backgroundColor = Colors.green.withOpacity(0.1);
        } else {
          borderColor = Colors.red;
          backgroundColor = Colors.red.withOpacity(0.1);
        }
      }
    }
    
    return Container(
      key: _placeholderKeys[placeholderIndex],
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSubmitted && selectedOption == (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null))
            Icon(Icons.check_circle, color: Colors.green, size: 16),
          if (_isSubmitted && selectedOption != (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null))
            Icon(Icons.cancel, color: Colors.red, size: 16),
          if (_isSubmitted) const SizedBox(width: 4),
          GestureDetector(
            onTap: _isSubmitted ? null : () => _removeFromPlaceholder(placeholderIndex, groupIndex, selectedOption),
            child: Text(
              selectedOption,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isSubmitted && selectedOption == (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null)
                    ? Colors.green
                    : _isSubmitted && selectedOption != (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null)
                        ? Colors.red
                        : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsButtons(List<String> options, int groupIndex, ButtonSingleChoiceContent content) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _isOptionSelected(option, groupIndex);
          
          return _buildOptionButton(option, index, isSelected, groupIndex, content);
        }).toList(),
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, bool isSelected, int groupIndex, ButtonSingleChoiceContent content) {
    final buttonKey = '${groupIndex}_$index';
    
    // Initialize animation controller nếu chưa có
    if (!_animationControllers.containsKey(buttonKey)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animationControllers[buttonKey] = controller;
      _animations[buttonKey] = Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }
    
    // Kiểm tra đáp án đúng/sai sau khi submit
    Color? backgroundColor = isSelected ? Colors.grey[300] : AppTheme.primaryColor;
    Color? foregroundColor = isSelected ? Colors.grey[600] : Colors.white;
    
    if (_isSubmitted && isSelected) {
      // Kiểm tra xem option này có đúng không
      final correctAnswers = content.correctAnswers;
      if (correctAnswers.contains(option)) {
        backgroundColor = Colors.green.withOpacity(0.3);
        foregroundColor = Colors.green[900];
      } else {
        backgroundColor = Colors.red.withOpacity(0.3);
        foregroundColor = Colors.red[900];
      }
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        key: _optionKeys[index],
        onPressed: _isSubmitted ? null : () => _handleOptionTap(option, index, groupIndex, content),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSubmitted && isSelected && content.correctAnswers.contains(option))
              const Icon(Icons.check_circle, size: 16),
            if (_isSubmitted && isSelected && !content.correctAnswers.contains(option))
              const Icon(Icons.cancel, size: 16),
            if (_isSubmitted && isSelected) const SizedBox(width: 4),
            Text(option),
          ],
        ),
      ),
    );
  }

  bool _isOptionSelected(String option, int groupIndex) {
    if (groupIndex == -1) {
      return _selectedAnswers.values.contains(option);
    } else {
      // Kiểm tra xem option có được chọn trong group này không
      for (var key in _selectedAnswers.keys) {
        if (key ~/ 1000 == groupIndex && _selectedAnswers[key] == option) {
          return true;
        }
      }
      return false;
    }
  }

  void _handleOptionTap(String option, int index, int groupIndex, ButtonSingleChoiceContent content) {
    setState(() {
      // Tìm placeholder trống đầu tiên
      final placeholderCount = groupIndex == -1 
          ? _countPlaceholders(widget.exercise.question)
          : _countPlaceholders(widget.exercise.groupQuestions![groupIndex].question);
      
      int? emptyPlaceholderIndex;
      for (int i = 0; i < placeholderCount; i++) {
        final key = groupIndex == -1 ? i : groupIndex * 1000 + i;
        if (_selectedAnswers[key] == null) {
          emptyPlaceholderIndex = i;
          break;
        }
      }
      
      if (emptyPlaceholderIndex != null) {
        final key = groupIndex == -1 ? emptyPlaceholderIndex! : groupIndex * 1000 + emptyPlaceholderIndex!;
        _selectedAnswers[key] = option;
      }
    });
  }

  void _removeFromPlaceholder(int placeholderIndex, int groupIndex, String option) {
    setState(() {
      final key = groupIndex == -1 ? placeholderIndex : groupIndex * 1000 + placeholderIndex;
      _selectedAnswers.remove(key);
      
      // Tìm và animate button về lại
      final optionIndex = groupIndex == -1
          ? (widget.exercise.content as ButtonSingleChoiceContent).options.indexOf(option)
          : (widget.exercise.groupQuestions![groupIndex].content as ButtonSingleChoiceContent).options.indexOf(option);
      
      // Button sẽ tự động cập nhật UI khi _selectedAnswers thay đổi
    });
  }

  bool _canSubmit() {
    // Nếu có groupQuestions
    if (widget.exercise.groupQuestions != null && widget.exercise.groupQuestions!.isNotEmpty) {
      for (int i = 0; i < widget.exercise.groupQuestions!.length; i++) {
        final groupQuestion = widget.exercise.groupQuestions![i];
        if (groupQuestion.type == ExerciseType.buttonSingleChoice) {
          final placeholderCount = _countPlaceholders(groupQuestion.question);
          for (int j = 0; j < placeholderCount; j++) {
            final key = i * 1000 + j;
            if (_selectedAnswers[key] == null) {
              return false;
            }
          }
        } else if (groupQuestion.type == ExerciseType.fillBlank) {
          final placeholderCount = _countPlaceholders(groupQuestion.question);
          for (int j = 0; j < placeholderCount; j++) {
            final key = i * 1000 + j;
            final answer = _fillBlankAnswers[key];
            if (answer == null || answer.trim().isEmpty) {
              return false;
            }
          }
        }
      }
      return true;
    }
    
    // Nếu là button_single_choice
    if (widget.exercise.type == ExerciseType.buttonSingleChoice) {
      final placeholderCount = _countPlaceholders(widget.exercise.question);
      for (int i = 0; i < placeholderCount; i++) {
        if (_selectedAnswers[i] == null) {
          return false;
        }
      }
      return true;
    }
    
    // Nếu là fill_blank
    if (widget.exercise.type == ExerciseType.fillBlank) {
      final regex = RegExp(r'\{(\d+)\}');
      final matches = regex.allMatches(widget.exercise.question);
      final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
      
      for (final placeholderIndex in placeholderIndices) {
        final key = 0 * 1000 + placeholderIndex; // groupIndex = 0 for standalone
        final answer = _fillBlankAnswers[key];
        if (answer == null || answer.trim().isEmpty) {
          return false;
        }
      }
      return true;
    }
    
    // Các loại khác
    return _selectedAnswer != null;
  }

  Widget _buildSingleChoice() {
    final content = widget.exercise.content as ChoiceContent;

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
          '${AppLocalizations.of(context)!.selectAllCorrectAnswers}:',
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
    final content = widget.exercise.content as FillBlankContent;
    
    // Tạo map từ position -> correctAnswer
    final Map<int, String> correctAnswersMap = {};
    for (final blank in content.blanks) {
      correctAnswersMap[blank.position] = blank.correctAnswer;
    }
    
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildQuestionWithTextFields(
            widget.exercise.question,
            0, // groupIndex = 0 for standalone
            correctAnswersMap,
            forceSubmitted: _isSubmitted,
          ),
        ),
      ),
    );
  }

  Widget _buildFillBlankForGroup(GroupQuestion groupQuestion, int groupIndex) {
    // Lấy correctAnswers từ content
    Map<int, String> correctAnswersMap = {};
    if (groupQuestion.content is FillBlankContent) {
      final content = groupQuestion.content as FillBlankContent;
      for (final blank in content.blanks) {
        correctAnswersMap[blank.position] = blank.correctAnswer;
      }
    } else if (groupQuestion.content is Map) {
      // Format mới: content có correctAnswers trực tiếp
      final contentMap = groupQuestion.content as Map<String, dynamic>;
      if (contentMap['correctAnswers'] != null) {
        final answers = contentMap['correctAnswers'] as List<dynamic>;
        // Lấy placeholder indices từ question để map đúng
        final regex = RegExp(r'\{(\d+)\}');
        final matches = regex.allMatches(groupQuestion.question);
        final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
        for (int idx = 0; idx < placeholderIndices.length && idx < answers.length; idx++) {
          correctAnswersMap[placeholderIndices[idx]] = answers[idx].toString();
        }
      }
    }
    
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildQuestionWithTextFields(
            groupQuestion.question,
            groupIndex,
            correctAnswersMap,
            forceSubmitted: _isSubmitted || _questionResults.containsKey(groupIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWithTextFields(
    String question,
    int groupIndex,
    Map<int, String> correctAnswersMap, {
    bool? forceSubmitted,
  }) {
    // Split question theo pattern {0}, {1}, {2}...
    // Pattern: tìm {số} và giữ lại cả số trong group
    final regex = RegExp(r'(\{(\d+)\})');
    final matches = regex.allMatches(question);
    
    if (matches.isEmpty) {
      return Text(
        question,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }
    
    // Tạo list các phần tử: text và placeholder
    final List<Widget> widgets = [];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Text trước placeholder
      if (match.start > lastEnd) {
        final textBefore = question.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          widgets.add(Text(
            textBefore,
            style: Theme.of(context).textTheme.bodyLarge,
          ));
        }
      }
      
      // Placeholder
      final placeholderIndex = int.parse(match.group(2)!);
      final key = groupIndex * 1000 + placeholderIndex;
      final userAnswer = _fillBlankAnswers[key] ?? '';
      // Nếu có groupQuestions, check xem question này đã được check chưa
      final isSubmitted = forceSubmitted ?? (_isSubmitted || 
          (widget.exercise.groupQuestions != null && 
           _questionResults.containsKey(groupIndex)));
      final correctAnswer = correctAnswersMap[placeholderIndex] ?? '';
      // Nếu question đã được check, lấy kết quả từ _questionResults
      final questionIsCorrect = widget.exercise.groupQuestions != null && 
          _questionResults.containsKey(groupIndex)
          ? _questionResults[groupIndex]!
          : (isSubmitted && userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase());
      final isCorrect = isSubmitted && questionIsCorrect;
      final isWrong = isSubmitted && userAnswer.isNotEmpty && !questionIsCorrect;
      
      widgets.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 120,
        child: TextField(
          enabled: !isSubmitted,
          controller: TextEditingController(text: userAnswer)
            ..selection = TextSelection.collapsed(offset: userAnswer.length),
          onChanged: (value) {
            setState(() {
              _fillBlankAnswers[key] = value;
            });
          },
          decoration: InputDecoration(
            hintText: '...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: isSubmitted
                ? (isCorrect 
                    ? Colors.green.withOpacity(0.2)
                    : isWrong
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey[200])
                : Colors.white,
            suffixIcon: isSubmitted
                ? (isCorrect
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : isWrong
                        ? const Icon(Icons.cancel, color: Colors.red, size: 20)
                        : null)
                : null,
          ),
          style: TextStyle(
            color: isSubmitted && isWrong ? Colors.red : null,
            fontWeight: isSubmitted && isCorrect ? FontWeight.bold : null,
          ),
        ),
      ));
      
      lastEnd = match.end;
    }
    
    // Text sau placeholder cuối cùng
    if (lastEnd < question.length) {
      final textAfter = question.substring(lastEnd);
      if (textAfter.isNotEmpty) {
        widgets.add(Text(
          textAfter,
          style: Theme.of(context).textTheme.bodyLarge,
        ));
      }
    }
    
    // Dùng Wrap để tự động xuống dòng khi cần, không bị che mất nội dung
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: widgets,
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

    // Nếu có groupQuestions
    if (widget.exercise.groupQuestions != null && widget.exercise.groupQuestions!.isNotEmpty) {
      // Check question cuối cùng (question hiện tại) nếu chưa check
      final lastQuestionIndex = widget.exercise.groupQuestions!.length - 1;
      if (!_questionResults.containsKey(lastQuestionIndex)) {
        final lastQuestion = widget.exercise.groupQuestions![lastQuestionIndex];
        final lastQuestionCorrect = _checkQuestionAnswer(lastQuestion, lastQuestionIndex);
        _questionResults[lastQuestionIndex] = lastQuestionCorrect;
      }
      
      // Tổng hợp kết quả: tất cả questions phải đúng
      isCorrect = _questionResults.values.every((result) => result == true) && 
                  _questionResults.length == widget.exercise.groupQuestions!.length;
    } else {
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
        case ExerciseType.fillBlank:
          final content = widget.exercise.content as FillBlankContent;
          // Tạo map từ position -> correctAnswer
          final Map<int, String> correctAnswersMap = {};
          for (final blank in content.blanks) {
            correctAnswersMap[blank.position] = blank.correctAnswer;
          }
          
          // Lấy tất cả placeholder indices từ question
          final regex = RegExp(r'\{(\d+)\}');
          final matches = regex.allMatches(widget.exercise.question);
          final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
          
          if (placeholderIndices.length != correctAnswersMap.length) {
            isCorrect = false;
            break;
          }
          
          isCorrect = true;
          for (final placeholderIndex in placeholderIndices) {
            final key = 0 * 1000 + placeholderIndex; // groupIndex = 0 for standalone
            final userAnswer = _fillBlankAnswers[key]?.trim().toLowerCase() ?? '';
            final correctAnswer = correctAnswersMap[placeholderIndex]?.trim().toLowerCase() ?? '';
            if (userAnswer != correctAnswer) {
              isCorrect = false;
              break;
            }
          }
          break;
        case ExerciseType.buttonSingleChoice:
          final content = widget.exercise.content as ButtonSingleChoiceContent;
          final placeholderCount = _countPlaceholders(widget.exercise.question);
          final userAnswers = <String>[];
          for (int i = 0; i < placeholderCount; i++) {
            final answer = _selectedAnswers[i];
            if (answer != null) {
              userAnswers.add(answer);
            }
          }
          // So sánh theo thứ tự
          if (userAnswers.length != content.correctAnswers.length) {
            isCorrect = false;
          } else {
            isCorrect = true;
            for (int i = 0; i < userAnswers.length; i++) {
              if (userAnswers[i] != content.correctAnswers[i]) {
                isCorrect = false;
                break;
              }
            }
          }
          break;
        default:
          isCorrect = false;
      }
    }

    setState(() {
      _isSubmitted = true;
      _isCorrect = isCorrect;
    });

    // Kiểm tra auth state và hiển thị thông báo nếu chưa đăng nhập
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginToSync),
          backgroundColor: AppTheme.primaryColor,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.login,
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildResultSection() {
    return Card(
      margin: EdgeInsets.zero,
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
                  AppLocalizations.of(context)!.youGotPoints(_isCorrect ? widget.exercise.points : 0),
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
                child: Text(AppLocalizations.of(context)!.back),
              ),
            ),
          ],
        ),
      ),
    );
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
}


