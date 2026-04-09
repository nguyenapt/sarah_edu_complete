import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/placement_test_model.dart';
import '../../core/services/placement_test_service.dart';
import '../../core/services/placement_storage_service.dart';
import '../../providers/language_provider.dart';
import 'placement_test_result_screen.dart';
import '../../core/theme/horizon_colors.dart';

const Color _kSurface = Color(0xFFF4F6FF);
const Color _kOnSurface = Color(0xFF14304F);
const Color _kOnSurfaceVariant = Color(0xFF445D7F);
const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const Color _kSurfaceContainer = Color(0xFFDDE9FF);

const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  final PlacementTestService _testService = PlacementTestService();
  
  List<PlacementTestQuestion> _allQuestions = [];
  List<PlacementTestQuestion> _testQuestions = [];
  final List<PlacementTestAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  DateTime? _startTime;
  int _timeSpentSeconds = 0;
  Timer? _timer;

  // Answer state
  dynamic _selectedAnswer; // String for single choice, List<String> for multiple choice
  bool _showHint = false;

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
      _showHint = false;
    });
  }

  // Back/Previous navigation removed in mockup.

  void _toggleHint(String languageCode) {
    final q = _testQuestions[_currentQuestionIndex];
    final hint = q.getExplanation(languageCode).trim();
    if (hint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có gợi ý cho câu này.')),
      );
      return;
    }
    setState(() => _showHint = !_showHint);
  }

  Widget _buildAssessmentAppBar({
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _kOnSurface,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _kOnSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: _kSurfaceContainer,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: const Icon(Icons.person_rounded, size: 20),
              color: _kOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader({
    required int percent,
    required int questionNumber,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: _kOnSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFED01B),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF594700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Question ${questionNumber.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _kOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: _kSurfaceContainer),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: _kPrimaryCtaGradient),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  // Removed answer backfill helper (no Previous in mockup).

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final horizon = HorizonColors.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? horizon.surface : _kSurface,
        body: SafeArea(
          child: Column(
            children: [
              _buildAssessmentAppBar(title: 'Assessment'),
              _buildProgressHeader(
                percent: 0,
                questionNumber: 1,
                progress: 0,
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _kPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_testQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? horizon.surface : _kSurface,
        body: SafeArea(
          child: Column(
            children: [
              _buildAssessmentAppBar(title: 'Assessment'),
              const Expanded(
                child: Center(
                  child: Text(
                    'No questions available',
                    style: TextStyle(color: _kOnSurfaceVariant, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = _testQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _testQuestions.length;
    final isLastQuestion = _currentQuestionIndex >= _testQuestions.length - 1;
    final percent = (progress * 100).round();
    final canNext = _selectedAnswer != null && !_isSubmitting;

    return Scaffold(
      backgroundColor: isDark ? horizon.surface : _kSurface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAssessmentAppBar(title: 'Assessment'),
            _buildProgressHeader(
              percent: percent,
              questionNumber: _currentQuestionIndex + 1,
              progress: progress,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuestionCard(
                      questionLabel: _questionTypeLabel(question.type),
                      questionText: question.getQuestion(languageCode),
                      levelText: 'Level: ${question.level.toString()}',
                    ),
                    const SizedBox(height: 14),
                    _buildAnswerSection(question),
                    if (_showHint) ...[
                      const SizedBox(height: 14),
                      _HintCard(text: question.getExplanation(languageCode)),
                    ],
                  ],
                ),
              ),
            ),
            PositionedFooter(
              child: Row(
                children: [
                  _FooterHintButton(
                    onPressed:
                        _isSubmitting ? null : () => _toggleHint(languageCode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FooterNextButton(
                      label: isLastQuestion ? 'Submit' : 'Next',
                      isLoading: _isSubmitting,
                      onPressed: canNext
                          ? (isLastQuestion ? _handleSubmit : _handleNext)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _questionTypeLabel(PlacementTestType type) {
    switch (type) {
      case PlacementTestType.fillBlank:
        return 'Fill in the blank:';
      case PlacementTestType.multipleChoice:
        return 'Select all that apply:';
      case PlacementTestType.singleChoice:
        return 'Select one:';
    }
  }

  Widget _buildAnswerSection(PlacementTestQuestion question) {
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
      children: question.options.asMap().entries.map((e) {
        final index = e.key;
        final option = e.value;
        final isSelected = _selectedAnswer == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionTile(
            letter: String.fromCharCode('A'.codeUnitAt(0) + index),
            text: option,
            selected: isSelected,
            showCheck: isSelected,
            onTap: () => setState(() => _selectedAnswer = option),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(PlacementTestQuestion question) {
    final selectedAnswers = _selectedAnswer as List<String>? ?? [];

    return Column(
      children: question.options.asMap().entries.map((e) {
        final index = e.key;
        final option = e.value;
        final isSelected = selectedAnswers.contains(option);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionTile(
            letter: String.fromCharCode('A'.codeUnitAt(0) + index),
            text: option,
            selected: isSelected,
            showCheck: isSelected,
            onTap: () {
              setState(() {
                final current = List<String>.from(selectedAnswers);
                if (isSelected) {
                  current.remove(option);
                } else {
                  current.add(option);
                }
                _selectedAnswer = current;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlank(PlacementTestQuestion question) {
    // UI giống single choice (như mockup).
    return _buildSingleChoice(question);
  }

  // Category label helper removed (not used in mockup).
}

class PositionedFooter extends StatelessWidget {
  const PositionedFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: child,
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.questionLabel,
    required this.questionText,
    required this.levelText,
  });

  final String questionLabel;
  final String questionText;
  final String levelText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF86EFAC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  levelText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF064E3B),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _kOnSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Text(
                    questionText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      color: _kOnSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.showCheck,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final bool showCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _kPrimary.withValues(alpha: 0.85) : Colors.white;
    final border =
        selected ? Colors.transparent : Colors.grey.withValues(alpha: 0.18);
    final fg = selected ? Colors.white : _kOnSurface;

    return Material(
      color: bg,
      elevation: selected ? 2 : 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.2)
                        : _kSurfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: selected ? Colors.white : _kOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (showCheck)
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterHintButton extends StatelessWidget {
  const _FooterHintButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: enabled ? _kOnSurfaceVariant : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Hint',
                style: TextStyle(
                  color: enabled ? _kOnSurfaceVariant : Colors.grey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterNextButton extends StatelessWidget {
  const _FooterNextButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _kPrimaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: TextStyle(
          color: _kOnSurfaceVariant.withValues(alpha: 0.92),
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

