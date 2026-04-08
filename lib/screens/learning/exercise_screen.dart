import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/learning/question_audio_player.dart';
import '../auth/login_screen.dart';
import '../level_up/level_up_screen.dart';
import 'exercise_detail_screen.dart';

/// Màu đồng bộ với `mockup_1.html` (tailwind theme.extend.colors — Fluent Horizon).
const Color _kSurface = Color(0xFFF4F6FF); // background / surface
const Color _kOnSurface = Color(0xFF14304F); // on-surface, on-background
const Color _kOnSurfaceVariant = Color(0xFF445D7F); // on-surface-variant (nhãn phụ)
const Color _kPrimary = Color(0xFF006286); // primary — viền chọn, vòng chữ, % Progress
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const Color _kPrimaryFixedDim = Color(0xFF05A9E3); // gradient progress / nút
const Color _kSurfaceContainer = Color(0xFFDDE9FF); // vòng A/B chưa chọn; track thanh tiến độ (mockup)
const Color _kSurfaceContainerLowest = Color(0xFFFFFFFF); // thẻ câu hỏi
/// ~10% primary-container (bg-primary-container/10) cho ô đáp án đang chọn.
const Color _kOptionSelectedFill = Color(0x1A2DB7F2);
const Color _kOptionCircleIdleFg = Color(0xFF445D7F); // on-surface-variant
const Color _kTertiaryContainer = Color(0xFFFED01B); // badge New Skill
const Color _kOnTertiaryContainer = Color(0xFF594700);
/// Thẻ Grammar Note (mockup: nền be nhạt, viền trái vàng ôliu).
const Color _kGrammarNoteBg = Color(0xFFF5F0E8);
const Color _kGrammarAccent = Color(0xFF6B5A2E);
/// Vòng trang trí phía sau thẻ câu hỏi (xanh lá mờ).
const Color _kQuestionDecorGreen = Color(0x338BC34A);

/// Gradient nút Next/Submit trong mockup: `from-[#006286] to-[#2db7f2]`.
const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

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
  Map<String, GlobalKey> _optionKeys = {}; // Map<"groupIndex_optionIndex", GlobalKey>
  Map<String, GlobalKey> _placeholderKeys = {}; // Map<"groupIndex_placeholderIndex", GlobalKey>
  Map<String, AnimationController> _animationControllers = {};
  Map<String, Animation<Offset>> _animations = {};
  
  // Cho fill_blank
  Map<int, String> _fillBlankAnswers = {}; // Map<placeholderIndex, userInput>
  
  // Cho crossword
  Map<String, String> _crosswordAnswers = {}; // Map<"row_col", userInput>
  String? _activeWord; // Track word đang được focus (format: "across_1" hoặc "down_2")
  Map<String, FocusNode> _crosswordFocusNodes = {}; // Map<"row_col", FocusNode>
  
  // Cho matching exercise
  Map<int, int> _matchingPairs = {}; // Map<leftIndex, rightIndex> - các cặp đã match (cho exercise chính)
  int? _selectedLeftIndex; // Left item đang được chọn (cho exercise chính)
  // Cho matching trong group questions
  Map<int, Map<int, int>> _groupMatchingPairs = {}; // Map<groupIndex, Map<leftIndex, rightIndex>>
  Map<int, int?> _groupSelectedLeftIndex = {}; // Map<groupIndex, selectedLeftIndex>
  
  // Cho groupQuestions - chỉ hiển thị 1 question tại một thời điểm
  int _currentGroupQuestionIndex = 0;
  Map<int, bool> _questionResults = {}; // Map<questionIndex, isCorrect> - lưu kết quả từng question
  Map<int, dynamic> _groupQuestionAnswers = {}; // Map<groupIndex, selectedAnswer> - cho singleChoice và multipleChoice
  
  // Tracking time spent
  DateTime? _startTime;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  /// Nút Submit / Tiếp — gradient như footer `mockup_1.html`.
  Widget _buildGradientCtaButton({
    required VoidCallback? onPressed,
    required String label,
  }) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? _kPrimaryCtaGradient : null,
            color: enabled ? null : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 0–1: tiến độ phiên (mockup thanh %).
  double _sessionProgressFraction() {
    final gq = widget.exercise.groupQuestions;
    if (gq != null && gq.isNotEmpty) {
      final total = gq.length;
      if (total == 0) return 0;
      var submitted = 0;
      for (var i = 0; i < total; i++) {
        if (_questionResults.containsKey(i)) submitted++;
      }
      final hasCurrentAnswer =
          _groupQuestionAnswers[_currentGroupQuestionIndex] != null;
      final extra = hasCurrentAnswer && !_questionResults.containsKey(_currentGroupQuestionIndex)
          ? 0.5
          : 0.0;
      return ((submitted + extra) / total).clamp(0.0, 1.0);
    }
    if (_isSubmitted) return 1.0;
    if (_selectedAnswer != null) return 0.35;
    return 0.0;
  }

  /// Tổng điểm tối đa của exercise (sum `point` từng câu hoặc `exercise.points`).
  int _totalExercisePoints() {
    final group = widget.exercise.groupQuestions;
    if (group != null && group.isNotEmpty) {
      var sum = 0;
      for (final q in group) {
        sum += q.point;
      }
      return sum;
    }
    return widget.exercise.points;
  }

  /// Thanh tiến độ giữa AppBar (mockup exercise: bo tròn, track sáng, fill gradient).
  Widget _buildExerciseAppBarProgress() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _kSurfaceContainer),
            FractionallySizedBox(
              widthFactor: _sessionProgressFraction().clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kPrimary, _kPrimaryFixedDim],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _kOnSurface,
        iconTheme: IconThemeData(color: _kOnSurface),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: _kOnSurface,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Expanded(child: _buildExerciseAppBarProgress()),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kTertiaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: _kOnTertiaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_totalExercisePoints()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _kOnTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnswerSection(),
                  const SizedBox(height: 24),
                  if (widget.exercise.groupQuestions == null ||
                      widget.exercise.groupQuestions!.isEmpty)
                    if (widget.exercise.type != ExerciseType.buttonSingleChoice)
                      _buildExplanationBox(widget.exercise.explanation),
                  if (!_isSubmitted &&
                      (widget.exercise.groupQuestions == null ||
                          widget.exercise.groupQuestions!.isEmpty))
                    _buildGradientCtaButton(
                      onPressed: _canSubmit() ? _handleSubmit : null,
                      label: loc.submit,
                    ),
                  if (_isSubmitted) _buildResultSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _crosswordFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Check if exercise has title or image
  bool _hasTitleOrImage() {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final exerciseTitle = widget.exercise.getTitle(languageCode);
    final hasTitle = exerciseTitle.isNotEmpty;
    final hasImage = widget.exercise.imageUrl != null && widget.exercise.imageUrl!.isNotEmpty;
    return hasTitle || hasImage;
  }

  /// Build title and image section (without Card wrapper)
  Widget _buildTitleAndImageSection({bool wrapInCard = false}) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final exerciseTitle = widget.exercise.getTitle(languageCode);
    final hasTitle = exerciseTitle.isNotEmpty;
    final hasImage = widget.exercise.imageUrl != null && widget.exercise.imageUrl!.isNotEmpty;

    if (!hasTitle && !hasImage) {
      return const SizedBox.shrink();
    }
    
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Title
            if (hasTitle) ...[
              Text(
                exerciseTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              const SizedBox(height: 16),
            ],
        // Image
        if (hasImage) ...[
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.exercise.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => _showImageZoomDialog(widget.exercise.imageUrl!),
                      borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
    
    if (wrapInCard) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D2D2D) // Màu sáng hơn cho dark mode
              : Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      );
    }
    
    return content;
  }

  /// Show image zoom dialog
  void _showImageZoomDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.red, size: 48),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image section for GroupQuestion
  Widget _buildGroupQuestionImage(String imageUrl) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _showImageZoomDialog(imageUrl),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    // Nếu là sequentialQuestions, hiển thị sequential questions
    if (widget.exercise.type == ExerciseType.sequentialQuestions) {
      return _buildSequentialQuestions();
    }
    
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
      case ExerciseType.crossword:
        return _buildCrossword();
      case ExerciseType.wordMatching:
        return _buildWordMatching();
      case ExerciseType.definitionMatching:
        return _buildDefinitionMatching();
      case ExerciseType.wordFormationExercise:
        return _buildWordFormation();
      case ExerciseType.wordPatternExercise:
        return _buildWordPattern();
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
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final currentExplanation = currentQuestion.getExplanation(languageCode);
    final isLastQuestion = _currentGroupQuestionIndex == groupQuestions.length - 1;
    final hasMultipleQuestions = groupQuestions.length > 1;
    
    return Column(
      children: [
        // Title and Image Section for group questions
        _buildTitleAndImageSection(wrapInCard: true),
        if (_hasTitleOrImage()) const SizedBox(height: 16),
        // Chỉ hiển thị question hiện tại
        if (currentQuestion.type == ExerciseType.buttonSingleChoice)
          _buildButtonSingleChoiceForGroup(currentQuestion, _currentGroupQuestionIndex)
        else if (currentQuestion.type == ExerciseType.fillBlank)
          _buildFillBlankForGroup(currentQuestion, _currentGroupQuestionIndex)
        else if (currentQuestion.type == ExerciseType.singleChoice)
          _buildSingleChoiceForGroup(currentQuestion, _currentGroupQuestionIndex)
        else if (currentQuestion.type == ExerciseType.multipleChoice)
          _buildMultipleChoiceForGroup(currentQuestion, _currentGroupQuestionIndex)
        else if (currentQuestion.type == ExerciseType.matching)
          _buildMatchingForGroup(currentQuestion, _currentGroupQuestionIndex),

        if (currentExplanation != null &&
            currentExplanation.isNotEmpty &&
            currentQuestion.type != ExerciseType.buttonSingleChoice) ...[
          const SizedBox(height: 12),
          _buildExplanationBox(currentExplanation),
        ],
        
        const SizedBox(height: 24),
        
        // Nút điều hướng
        if (!_isSubmitted)
          _buildGradientCtaButton(
            onPressed: _canSubmitCurrentQuestion()
                ? (isLastQuestion ? _handleSubmit : _goToNextQuestion)
                : null,
            label: isLastQuestion
                ? AppLocalizations.of(context)!.submit
                : AppLocalizations.of(context)!.continueText,
          ),
      ],
    );
  }

  Widget _buildSequentialQuestions() {
    final groupQuestions = widget.exercise.groupQuestions!;
    
    // Tính số question đã unlock: question đầu tiên luôn unlock, 
    // question tiếp theo unlock khi question trước đó đã có đáp án
    int lastUnlockedIndex = 0;
    for (int i = 0; i < groupQuestions.length; i++) {
      final question = groupQuestions[i];
      bool hasAnswer = false;
      
      if (question.type == ExerciseType.buttonSingleChoice) {
        final placeholderCount = _countPlaceholders(question.question);
        bool hasAllAnswers = true;
        for (int j = 0; j < placeholderCount; j++) {
          final key = i * 1000 + j;
          if (_selectedAnswers[key] == null) {
            hasAllAnswers = false;
            break;
          }
        }
        hasAnswer = hasAllAnswers;
      } else if (question.type == ExerciseType.singleChoice) {
        hasAnswer = _groupQuestionAnswers[i] != null;
      } else if (question.type == ExerciseType.multipleChoice) {
        final selectedAnswers = _groupQuestionAnswers[i] as List<String>?;
        hasAnswer = selectedAnswers != null && selectedAnswers.isNotEmpty;
      }
      
      if (hasAnswer && i < groupQuestions.length - 1) {
        lastUnlockedIndex = i + 1;
      } else if (!hasAnswer) {
        break;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hiển thị paragraph nếu có (từ exercise.question)
        if (widget.exercise.question.isNotEmpty) ...[
          Stack(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D) // Màu sáng hơn cho dark mode
                      : Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildParagraphWithSpeakers(widget.exercise.question),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: QuestionAudioPlayer(
                  questionText: widget.exercise.question,
                  speakerVoices: widget.exercise.speakerVoices,
                  defaultVoice: widget.exercise.defaultVoice,
                  autoPlay: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        // Hiển thị tất cả questions đã unlock
        ...List.generate(lastUnlockedIndex + 1, (index) {
          final question = groupQuestions[index];
          final languageCode =
              Provider.of<LanguageProvider>(context, listen: false)
                  .currentLanguageCode;
          final explanation = question.getExplanation(languageCode);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.type == ExerciseType.buttonSingleChoice)
                _buildButtonSingleChoiceForGroup(question, index)
              else if (question.type == ExerciseType.singleChoice)
                _buildSingleChoiceForGroup(question, index)
              else if (question.type == ExerciseType.multipleChoice)
                _buildMultipleChoiceForGroup(question, index),
              if (explanation != null &&
                  explanation.isNotEmpty &&
                  question.type != ExerciseType.buttonSingleChoice) ...[
                const SizedBox(height: 12),
                _buildExplanationBox(explanation),
              ],
              if (index < lastUnlockedIndex) const SizedBox(height: 24),
            ],
          );
        }),
        
        // Nút Submit khi tất cả questions đã được trả lời
        if (lastUnlockedIndex == groupQuestions.length - 1 && !_isSubmitted) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmitSequentialQuestions() ? _handleSubmit : null,
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
        ],
      ],
    );
  }

  bool _canSubmitSequentialQuestions() {
    final groupQuestions = widget.exercise.groupQuestions!;
    for (int i = 0; i < groupQuestions.length; i++) {
      final question = groupQuestions[i];
      if (question.type == ExerciseType.buttonSingleChoice) {
        final placeholderCount = _countPlaceholders(question.question);
        for (int j = 0; j < placeholderCount; j++) {
          final key = i * 1000 + j;
          if (_selectedAnswers[key] == null) {
            return false;
          }
        }
      } else if (question.type == ExerciseType.singleChoice) {
        if (_groupQuestionAnswers[i] == null) {
          return false;
        }
      } else if (question.type == ExerciseType.multipleChoice) {
        final selectedAnswers = _groupQuestionAnswers[i] as List<String>?;
        if (selectedAnswers == null || selectedAnswers.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }
  
  void _goToNextQuestion() {
    // Check và lưu kết quả question hiện tại trước khi chuyển
    final currentQuestion = widget.exercise.groupQuestions![_currentGroupQuestionIndex];
    
    // Log câu hỏi và đáp án user đã chọn
    print('=== TIẾP TỤC - Question ${_currentGroupQuestionIndex + 1} ===');
    print('Question: ${currentQuestion.question}');
    print('Type: ${currentQuestion.type}');
    
    if (currentQuestion.type == ExerciseType.fillBlank) {
      final regex = RegExp(r'\{(\d+)\}');
      final matches = regex.allMatches(currentQuestion.question);
      final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
      
      print('Placeholder indices: $placeholderIndices');
      for (final placeholderIndex in placeholderIndices) {
        final key = _currentGroupQuestionIndex * 1000 + placeholderIndex;
        final userAnswer = _fillBlankAnswers[key];
        print('  Placeholder {${placeholderIndex}}: User answer = "$userAnswer"');
      }
      
      // Log correct answers
      Map<int, String> correctAnswersMap = {};
      if (currentQuestion.content is FillBlankContent) {
        final content = currentQuestion.content as FillBlankContent;
        final regex2 = RegExp(r'\{(\d+)\}');
        final matches2 = regex2.allMatches(currentQuestion.question);
        final placeholderIndices2 = matches2.map((m) => int.parse(m.group(1)!)).toList();
        if (content.blanks.isNotEmpty) {
          final sortedBlanks = List<BlankItem>.from(content.blanks);
          sortedBlanks.sort((a, b) => a.position.compareTo(b.position));
          for (int idx = 0; idx < placeholderIndices2.length && idx < sortedBlanks.length; idx++) {
            final placeholderIndex = placeholderIndices2[idx];
            correctAnswersMap[placeholderIndex] = sortedBlanks[idx].correctAnswer;
          }
        }
      } else if (currentQuestion.content is Map) {
        final contentMap = currentQuestion.content as Map<String, dynamic>;
        if (contentMap['correctAnswers'] != null) {
          final answers = contentMap['correctAnswers'] as List<dynamic>;
          final regex2 = RegExp(r'\{(\d+)\}');
          final matches2 = regex2.allMatches(currentQuestion.question);
          final placeholderIndices2 = matches2.map((m) => int.parse(m.group(1)!)).toList();
          for (int idx = 0; idx < placeholderIndices2.length && idx < answers.length; idx++) {
            correctAnswersMap[placeholderIndices2[idx]] = answers[idx].toString();
          }
        }
      }
      print('Correct answers map: $correctAnswersMap');
      for (final entry in correctAnswersMap.entries) {
        print('  Placeholder {${entry.key}}: Correct answer = "${entry.value}"');
      }
    } else if (currentQuestion.type == ExerciseType.buttonSingleChoice) {
      final content = currentQuestion.content as ButtonSingleChoiceContent;
      final placeholderCount = _countPlaceholders(currentQuestion.question);
      final userAnswers = <String>[];
      for (int j = 0; j < placeholderCount; j++) {
        final key = _currentGroupQuestionIndex * 1000 + j;
        final answer = _selectedAnswers[key];
        if (answer != null) {
          userAnswers.add(answer);
        }
        print('  Placeholder $j: User answer = "${answer ?? "null"}"');
      }
      print('User answers: $userAnswers');
      print('Correct answers: ${content.correctAnswers}');
    } else if (currentQuestion.type == ExerciseType.singleChoice) {
      final content = currentQuestion.content as ChoiceContent;
      final userAnswer = _groupQuestionAnswers[_currentGroupQuestionIndex] as String?;
      print('User answer: "$userAnswer"');
      print('Correct answers: ${content.correctAnswers}');
    } else if (currentQuestion.type == ExerciseType.multipleChoice) {
      final content = currentQuestion.content as ChoiceContent;
      final userAnswers = (_groupQuestionAnswers[_currentGroupQuestionIndex] as List<String>?) ?? [];
      print('User answers: $userAnswers');
      print('Correct answers: ${content.correctAnswers}');
    }
    
    final isCorrect = _checkQuestionAnswer(currentQuestion, _currentGroupQuestionIndex);
    print('Result: ${isCorrect ? "ĐÚNG" : "SAI"}');
    print('==========================================\n');
    
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
    } else if (groupQuestion.type == ExerciseType.singleChoice) {
      final content = groupQuestion.content as ChoiceContent;
      final userAnswer = _groupQuestionAnswers[questionIndex] as String?;
      return content.correctAnswers.contains(userAnswer);
    } else if (groupQuestion.type == ExerciseType.multipleChoice) {
      final content = groupQuestion.content as ChoiceContent;
      final userAnswers = (_groupQuestionAnswers[questionIndex] as List<String>?) ?? [];
      if (userAnswers.length != content.correctAnswers.length) {
        return false;
      }
      return userAnswers.every((answer) => content.correctAnswers.contains(answer)) &&
             content.correctAnswers.every((answer) => userAnswers.contains(answer));
    } else if (groupQuestion.type == ExerciseType.matching) {
      final content = groupQuestion.content as MatchingContent;
      final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
      final matchingPairs = _groupMatchingPairs[questionIndex] ?? {};
      
      // Kiểm tra xem tất cả left items đã được match chưa
      if (matchingPairs.length != content.leftItems.length) {
        return false;
      }
      
      // Kiểm tra từng pair
      for (final correctPair in content.correctPairs) {
        final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
        if (correctLeftIndex == -1) continue;
        
        final userRightIndex = matchingPairs[correctLeftIndex];
        if (userRightIndex == null) return false;
        
        // Lấy right value theo language code
        final correctRightValue = correctPair.getRight(languageCode);
        final userRightValue = content.getRightItem(userRightIndex, languageCode);
        
        if (correctRightValue != userRightValue) {
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
    } else if (currentQuestion.type == ExerciseType.singleChoice) {
      return _groupQuestionAnswers[_currentGroupQuestionIndex] != null;
    } else if (currentQuestion.type == ExerciseType.multipleChoice) {
      final selectedAnswers = _groupQuestionAnswers[_currentGroupQuestionIndex] as List<String>?;
      return selectedAnswers != null && selectedAnswers.isNotEmpty;
    } else if (currentQuestion.type == ExerciseType.matching) {
      final content = currentQuestion.content as MatchingContent;
      final matchingPairs = _groupMatchingPairs[_currentGroupQuestionIndex] ?? {};
      // Kiểm tra xem tất cả left items đã được match chưa
      return matchingPairs.length == content.leftItems.length;
    }
    
    return false;
  }

  /// Ghi chú ngữ pháp (viền trái đậm + icon) — chỉ dùng cho button single choice.
  Widget _buildGrammarNoteCard(String explanation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : _kGrammarNoteBg,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: isDark ? Colors.amber.shade700 : _kGrammarAccent, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: isDark ? Colors.amber.shade600 : _kGrammarAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                loc.grammarNoteTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.amber.shade600 : _kGrammarAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _looksLikeHtml(explanation)
              ? Html(
                  data: explanation,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      color: isDark ? Colors.white70 : _kOnSurfaceVariant,
                      fontSize: FontSize(14),
                      lineHeight: const LineHeight(1.35),
                    ),
                  },
                )
              : Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: isDark ? Colors.white70 : _kOnSurfaceVariant,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildButtonSingleChoiceForGroup(GroupQuestion groupQuestion, int groupIndex) {
    final content = groupQuestion.content as ButtonSingleChoiceContent;
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final grammarExplanation = groupQuestion.getExplanation(languageCode);

    // Initialize keys và animations cho group này
    final placeholderCount = _countPlaceholders(groupQuestion.question);
    for (int i = 0; i < content.options.length; i++) {
      final key = '${groupIndex}_option_$i';
      if (!_optionKeys.containsKey(key)) {
        _optionKeys[key] = GlobalKey();
      }
    }
    for (int i = 0; i < placeholderCount; i++) {
      final key = '${groupIndex}_placeholder_$i';
      if (!_placeholderKeys.containsKey(key)) {
        _placeholderKeys[key] = GlobalKey();
      }
    }
    
    // Kiểm tra xem question này đã có đáp án chưa (cho sequential questions)
    bool isQuestionAnswered = false;
    if (widget.exercise.type == ExerciseType.sequentialQuestions) {
      bool hasAllAnswers = true;
      for (int j = 0; j < placeholderCount; j++) {
        final key = groupIndex * 1000 + j;
        if (_selectedAnswers[key] == null) {
          hasAllAnswers = false;
          break;
        }
      }
      isQuestionAnswered = hasAllAnswers;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupQuestion.imageUrl != null && groupQuestion.imageUrl!.isNotEmpty) ...[
          _buildGroupQuestionImage(groupQuestion.imageUrl!),
          const SizedBox(height: 16),
        ],
        _buildQuestionContent(groupQuestion.question, groupIndex, content),
        if (grammarExplanation != null && grammarExplanation.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildGrammarNoteCard(grammarExplanation.trim()),
        ],
        if (!isQuestionAnswered) ...[
          const SizedBox(height: 24),
          _buildOptionsButtons(content.options, groupIndex, content),
        ],
      ],
    );
  }

  Widget _buildButtonSingleChoice() {
    final content = widget.exercise.content as ButtonSingleChoiceContent;
    final placeholderCount = _countPlaceholders(widget.exercise.question);
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final instructionTitle = widget.exercise.getTitle(languageCode);
    final grammarExplanation = widget.exercise.explanation;

    // Initialize keys (groupIndex = -1 cho standalone)
    for (int i = 0; i < content.options.length; i++) {
      final key = '-1_option_$i';
      if (!_optionKeys.containsKey(key)) {
        _optionKeys[key] = GlobalKey();
      }
    }
    for (int i = 0; i < placeholderCount; i++) {
      final key = '-1_placeholder_$i';
      if (!_placeholderKeys.containsKey(key)) {
        _placeholderKeys[key] = GlobalKey();
      }
    }

    final loc = AppLocalizations.of(context)!;
    final instructionStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: _kOnSurface,
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            instructionTitle.trim().isNotEmpty
                ? instructionTitle
                : loc.selectCorrectForm,
            style: instructionStyle,
          ),
        ),
        _buildQuestionContent(widget.exercise.question, -1, content),
        if (grammarExplanation != null && grammarExplanation.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildGrammarNoteCard(grammarExplanation.trim()),
        ],
        const SizedBox(height: 24),
        _buildOptionsButtons(content.options, -1, content),
      ],
    );
  }

  int _countPlaceholders(String question) {
    final regex = RegExp(r'\{(\d+)\}');
    final matches = regex.allMatches(question);
    if (matches.isEmpty) return 0;
    final maxIndex = matches.map((m) => int.parse(m.group(1)!)).reduce((a, b) => a > b ? a : b);
    return maxIndex + 1;
  }

  // Parse speaker từ question text (format: "SpeakerName: dialogue text" hoặc "SpeakerName:")
  // Returns: (speaker, dialogue) hoặc (null, question) nếu không có speaker
  (String?, String) _parseSpeaker(String question) {
    // Check format có dialogue: "SpeakerName: dialogue text"
    final speakerWithDialogueRegex = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s+(.+)$');
    final matchWithDialogue = speakerWithDialogueRegex.firstMatch(question);
    if (matchWithDialogue != null) {
      return (matchWithDialogue.group(1)?.trim(), matchWithDialogue.group(2) ?? '');
    }
    
    // Check format chỉ có speaker name: "SpeakerName:"
    final speakerOnlyRegex = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s*$');
    final matchOnly = speakerOnlyRegex.firstMatch(question);
    if (matchOnly != null) {
      return (matchOnly.group(1)?.trim(), '');
    }
    
    return (null, question);
  }

  bool _looksLikeHtml(String text) {
    return RegExp(r'<[^>]+>').hasMatch(text);
  }

  String _normalizeQuestionText(String text) {
    if (!_looksLikeHtml(text)) {
      return text;
    }

    var normalized = text;
    normalized = normalized.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    normalized = normalized.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n');
    normalized = normalized.replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '');
    normalized = normalized.replaceAll(RegExp(r'</h\d\s*>', caseSensitive: false), '\n');
    normalized = normalized.replaceAll(RegExp(r'<h\d[^>]*>', caseSensitive: false), '');
    normalized = normalized.replaceAll(RegExp(r'<[^>]+>'), '');
    normalized = normalized.replaceAll('&nbsp;', ' ');
    normalized = normalized.replaceAll('&amp;', '&');
    normalized = normalized.replaceAll('&quot;', '"');
    normalized = normalized.replaceAll('&#39;', "'");
    return normalized.trim();
  }

  Widget _buildHtmlContent(String html) {
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;
    return Html(
      data: html,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(bodyStyle?.fontSize ?? 16),
          color: bodyStyle?.color ?? Colors.black,
        ),
        "p": Style(
          margin: Margins.only(bottom: 8),
          color: bodyStyle?.color ?? Colors.black,
        ),
        "span": Style(
          color: bodyStyle?.color ?? Colors.black,
        ),
        "h1": Style(
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
        ),
        "h2": Style(
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
        ),
        "h3": Style(
          fontWeight: FontWeight.bold,
          margin: Margins.only(bottom: 8),
        ),
      },
    );
  }

  // Build paragraph với speakers (có thể có nhiều dòng, mỗi dòng có thể có speaker)
  Widget _buildParagraphWithSpeakers(String paragraph) {
    if (_looksLikeHtml(paragraph)) {
      return _buildHtmlContent(paragraph);
    }

    final lines = paragraph.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        }
        final (speaker, dialogue) = _parseSpeaker(line.trim());
        if (speaker != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$speaker:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dialogue,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
      }).toList(),
    );
  }

  // Build content cho multiple speakers (xử lý trường hợp dòng chỉ có speaker name)
  List<Widget> _buildMultipleSpeakerContent(List<String> lines, int groupIndex, ButtonSingleChoiceContent content) {
    List<Widget> widgets = [];
    String? currentSpeaker;
    List<String> currentDialogue = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final (speaker, dialogue) = _parseSpeaker(line);
      
      if (speaker != null) {
        // Nếu có speaker mới, render speaker cũ trước (nếu có)
        if (currentSpeaker != null && currentDialogue.isNotEmpty) {
          widgets.add(_buildSpeakerDialogueWidget(currentSpeaker!, currentDialogue.join(' '), groupIndex, content));
          widgets.add(const SizedBox(height: 12));
          currentDialogue.clear();
        }
        currentSpeaker = speaker;
        if (dialogue.isNotEmpty && dialogue != line) {
          currentDialogue.add(dialogue);
        }
      } else if (currentSpeaker != null) {
        // Nếu đang có speaker, thêm dòng này vào dialogue
        currentDialogue.add(line);
      } else {
        // Không có speaker, chỉ hiển thị text
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ));
      }
    }
    
    // Render speaker cuối cùng (nếu có)
    if (currentSpeaker != null && currentDialogue.isNotEmpty) {
      widgets.add(_buildSpeakerDialogueWidget(currentSpeaker!, currentDialogue.join(' '), groupIndex, content));
    }
    
    return widgets;
  }
  
  Widget _buildSpeakerDialogueWidget(String speaker, String dialogue, int groupIndex, ButtonSingleChoiceContent content) {
    final placeholderCount = _countPlaceholders(dialogue);
    final parts = dialogue.split(RegExp(r'\{(\d+)\}'));
    final placeholders = RegExp(r'\{(\d+)\}').allMatches(dialogue).toList();
    final questionText = '$speaker: $dialogue';
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: IgnorePointer(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kQuestionDecorGreen,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : _kSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$speaker:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _kPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < parts.length; i++) ...[
                      if (parts[i].trim().isNotEmpty)
                        Text(
                          parts[i].trim(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _kOnSurface,
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
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: QuestionAudioPlayer(
              questionText: questionText,
              speakerVoices: widget.exercise.speakerVoices,
              defaultVoice: widget.exercise.defaultVoice,
              autoPlay: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWithPlaceholders(String question, int groupIndex, ButtonSingleChoiceContent content) {
    final placeholderCount = _countPlaceholders(question);
    final parts = question.split(RegExp(r'\{(\d+)\}'));
    final placeholders = RegExp(r'\{(\d+)\}').allMatches(question).toList();
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D2D) // Màu sáng hơn cho dark mode
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 8,
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              if (parts[i].trim().isNotEmpty)
                Text(
                  parts[i].trim(),
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
    final normalizedQuestion = _normalizeQuestionText(question);
    // Kiểm tra xem question có nhiều dòng với nhiều speakers không
    final lines = normalizedQuestion.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    int speakerCount = 0;
    for (final line in lines) {
      final (speaker, _) = _parseSpeaker(line);
      if (speaker != null) {
        speakerCount++;
      }
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Nếu có từ 2 speakers trở lên, xử lý như paragraph
    if (speakerCount >= 2) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: IgnorePointer(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kQuestionDecorGreen,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : _kSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildMultipleSpeakerContent(lines, groupIndex, content),
            ),
          ),
        ],
      );
    }
    
    // Logic cũ cho single speaker
    final (speaker, dialogue) = _parseSpeaker(normalizedQuestion);
    final placeholderCount = _countPlaceholders(dialogue);
    final parts = dialogue.split(RegExp(r'\{(\d+)\}'));
    final placeholders = RegExp(r'\{(\d+)\}').allMatches(dialogue).toList();
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -8,
          top: -8,
          child: IgnorePointer(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kQuestionDecorGreen,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : _kSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (speaker != null) ...[
                Text(
                  '$speaker:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _kPrimary,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < parts.length; i++) ...[
                    if (parts[i].trim().isNotEmpty)
                      Text(
                        parts[i].trim(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _kOnSurface,
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
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: QuestionAudioPlayer(
            questionText: normalizedQuestion,
            speakerVoices: widget.exercise.speakerVoices,
            defaultVoice: widget.exercise.defaultVoice,
            autoPlay: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderWidget(int placeholderIndex, int groupIndex, ButtonSingleChoiceContent content) {
    final selectedOption = groupIndex == -1 
        ? _selectedAnswers[placeholderIndex]
        : _selectedAnswers[groupIndex * 1000 + placeholderIndex];
    
    // Lấy key cho placeholder này
    final placeholderKeyStr = groupIndex == -1 
        ? '-1_placeholder_$placeholderIndex'
        : '${groupIndex}_placeholder_$placeholderIndex';
    if (!_placeholderKeys.containsKey(placeholderKeyStr)) {
      _placeholderKeys[placeholderKeyStr] = GlobalKey();
    }
    final placeholderKey = _placeholderKeys[placeholderKeyStr]!;

    final correctAnswer = content.correctAnswers.length > placeholderIndex
        ? content.correctAnswers[placeholderIndex]
        : '';
    final placeholderTextStyle = Theme.of(context).textTheme.labelLarge ??
        DefaultTextStyle.of(context).style;
    const placeholderHorizontalPadding = 20.0;
    const placeholderVerticalPadding = 12.0;
    final placeholderWidth = _calculatePlaceholderWidth(
      correctAnswer,
      placeholderTextStyle,
      horizontalPadding: placeholderHorizontalPadding,
    );
    final placeholderHeight = _calculatePlaceholderHeight(
      placeholderTextStyle,
      verticalPadding: placeholderVerticalPadding,
    );
    
    // Kiểm tra xem question này đã có đáp án chưa (cho sequential questions)
    bool isQuestionAnswered = false;
    if (widget.exercise.type == ExerciseType.sequentialQuestions && groupIndex >= 0) {
      final question = widget.exercise.groupQuestions![groupIndex];
      if (question.type == ExerciseType.buttonSingleChoice) {
        final placeholderCount = _countPlaceholders(question.question);
        bool hasAllAnswers = true;
        for (int j = 0; j < placeholderCount; j++) {
          final key = groupIndex * 1000 + j;
          if (_selectedAnswers[key] == null) {
            hasAllAnswers = false;
            break;
          }
        }
        isQuestionAnswered = hasAllAnswers;
      }
    }
    
    // Chưa chọn: viền nét đứt + gợi ý (mockup button single choice).
    // Trong Wrap, maxWidth còn lại trên dòng có thể nhỏ hơn width mong muốn — phải
    // khớp constraints và cho phép xuống dòng để không cắt chữ ("Tap a"…).
    if (selectedOption == null) {
      final loc = AppLocalizations.of(context)!;
      final hintText = loc.buttonSingleChoiceTapHint;
      final hintStyle = TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white54
            : _kOnSurfaceVariant,
      );
      final scaler = MediaQuery.textScalerOf(context);
      final desiredMinW = math.max(
        placeholderWidth,
        _measureHintMinWidth(hintText, hintStyle, placeholderHorizontalPadding, scaler),
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final effectiveW =
              maxW.isFinite ? math.min(desiredMinW, maxW) : desiredMinW;
          final innerMaxW = math.max(
            0.0,
            effectiveW - placeholderHorizontalPadding * 2,
          );
          final layoutPainter = TextPainter(
            text: TextSpan(text: hintText, style: hintStyle),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
            maxLines: 4,
          )..layout(maxWidth: innerMaxW);
          final useH = math.max(
            placeholderHeight,
            layoutPainter.height + placeholderVerticalPadding * 2,
          );

          return Container(
            key: placeholderKey,
            margin: EdgeInsets.zero,
            width: effectiveW,
            height: useH,
            child: CustomPaint(
              painter: _DashedRoundedRectPainter(
                color: _kPrimary.withValues(alpha: 0.42),
                radius: 8,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: placeholderHorizontalPadding,
                    vertical: placeholderVerticalPadding,
                  ),
                  child: Text(
                    hintText,
                    style: hintStyle,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 4,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Kiểm tra đáp án đúng/sai sau khi submit
    Color borderColor = _kPrimary;
    Color backgroundColor = _kOptionSelectedFill;
    
    if (_isSubmitted) {
      final correctAnswer = content.correctAnswers.length > placeholderIndex 
          ? content.correctAnswers[placeholderIndex]
          : null;
        if (correctAnswer != null) {
        if (selectedOption == correctAnswer) {
          borderColor = Colors.green;
          backgroundColor = Colors.green.withValues(alpha: 0.1);
        } else {
          borderColor = Colors.red;
          backgroundColor = Colors.red.withValues(alpha: 0.1);
        }
      }
    }
    
    final isDisabled = _isSubmitted || isQuestionAnswered;
    
    final selectedOptionWidth = _calculatePlaceholderWidth(
      selectedOption,
      placeholderTextStyle,
      horizontalPadding: placeholderHorizontalPadding,
    );
    final appliedWidth = selectedOptionWidth > placeholderWidth
        ? selectedOptionWidth
        : placeholderWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: appliedWidth),
      child: Container(
        key: placeholderKey,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: placeholderHorizontalPadding,
          vertical: placeholderVerticalPadding,
        ),
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
              onTap: isDisabled ? null : () => _removeFromPlaceholder(placeholderIndex, groupIndex, selectedOption),
              child: Text(
                selectedOption,
                style: placeholderTextStyle.copyWith(
                  color: _isSubmitted && selectedOption == (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null)
                      ? Colors.green
                      : _isSubmitted && selectedOption != (content.correctAnswers.length > placeholderIndex ? content.correctAnswers[placeholderIndex] : null)
                          ? Colors.red
                          : _kPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePlaceholderWidth(
    String answer,
    TextStyle textStyle, {
    double horizontalPadding = 0,
  }) {
    if (answer.trim().isEmpty) {
      return 24;
    }
    final painter = TextPainter(
      text: TextSpan(text: answer, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    )..layout();
    final textWidth = painter.width.ceilToDouble();
    // +2px để tránh chữ dính sát viền do rounding
    return textWidth + (horizontalPadding * 2) + 2;
  }

  double _calculatePlaceholderHeight(
    TextStyle textStyle, {
    double verticalPadding = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ay', style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    )..layout();
    final textHeight = painter.height.ceilToDouble();
    return textHeight + (verticalPadding * 2);
  }

  double _measureHintMinWidth(
    String hintText,
    TextStyle hintStyle,
    double horizontalPadding,
    TextScaler scaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: hintText, style: hintStyle),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    return painter.width + horizontalPadding * 2 + 2;
  }

  Widget _buildOptionsButtons(List<String> options, int groupIndex, ButtonSingleChoiceContent content) {
    // Kiểm tra xem question này đã có đáp án chưa (cho sequential questions)
    bool isQuestionAnswered = false;
    if (widget.exercise.type == ExerciseType.sequentialQuestions && groupIndex >= 0) {
      final question = widget.exercise.groupQuestions![groupIndex];
      if (question.type == ExerciseType.buttonSingleChoice) {
        final placeholderCount = _countPlaceholders(question.question);
        bool hasAllAnswers = true;
        for (int j = 0; j < placeholderCount; j++) {
          final key = groupIndex * 1000 + j;
          if (_selectedAnswers[key] == null) {
            hasAllAnswers = false;
            break;
          }
        }
        isQuestionAnswered = hasAllAnswers;
      }
    }
    
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _isOptionSelected(option, groupIndex);
          
          return _buildOptionButton(option, index, isSelected, groupIndex, content, isQuestionAnswered);
        }).toList(),
      ),
    );
  }

  Widget _buildOptionButton(String option, int index, bool isSelected, int groupIndex, ButtonSingleChoiceContent content, bool isQuestionAnswered) {
    final buttonKey = '${groupIndex}_$index';
    
    // Lấy key cho option button này
    final optionKeyStr = groupIndex == -1 
        ? '-1_option_$index'
        : '${groupIndex}_option_$index';
    if (!_optionKeys.containsKey(optionKeyStr)) {
      _optionKeys[optionKeyStr] = GlobalKey();
    }
    final optionKey = _optionKeys[optionKeyStr]!;
    
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
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor =
        isDark ? const Color(0xFF3A3A3A) : _kSurfaceContainerLowest;
    Color foregroundColor = isDark ? Colors.white : _kOnSurface;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (isSelected && !_isSubmitted) {
      borderColor = _kPrimary;
      borderWidth = 2;
    }

    if (_isSubmitted && isSelected) {
      final correctAnswers = content.correctAnswers;
      if (correctAnswers.contains(option)) {
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        foregroundColor = Colors.green.shade900;
        borderColor = Colors.green.shade700;
        borderWidth = 2;
      } else {
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        foregroundColor = Colors.red.shade900;
        borderColor = Colors.red.shade700;
        borderWidth = 2;
      }
    }

    final isDisabled = _isSubmitted || isQuestionAnswered;
    final shadow = isDisabled
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        key: optionKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: isDisabled ? null : () => _handleOptionTap(option, index, groupIndex, content),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isSubmitted && isSelected && content.correctAnswers.contains(option))
                      Icon(Icons.check_circle, size: 18, color: foregroundColor),
                    if (_isSubmitted && isSelected && !content.correctAnswers.contains(option))
                      Icon(Icons.cancel, size: 18, color: foregroundColor),
                    if (_isSubmitted && isSelected) const SizedBox(width: 4),
                    Text(
                      option,
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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
        } else if (groupQuestion.type == ExerciseType.singleChoice) {
          if (_groupQuestionAnswers[i] == null) {
            return false;
          }
        } else if (groupQuestion.type == ExerciseType.multipleChoice) {
          final selectedAnswers = _groupQuestionAnswers[i] as List<String>?;
          if (selectedAnswers == null || selectedAnswers.isEmpty) {
            return false;
          }
        } else if (groupQuestion.type == ExerciseType.matching) {
          final content = groupQuestion.content as MatchingContent;
          final matchingPairs = _groupMatchingPairs[i] ?? {};
          // Kiểm tra xem tất cả left items đã được match chưa
          if (matchingPairs.length != content.leftItems.length) {
            return false;
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
    
    // Nếu là matching
    if (widget.exercise.type == ExerciseType.matching) {
      final content = widget.exercise.content as MatchingContent;
      // Tất cả left items phải được match
      return _matchingPairs.length == content.leftItems.length;
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
    
    // Nếu là crossword - kiểm tra tất cả words đã được điền đầy đủ
    if (widget.exercise.type == ExerciseType.crossword) {
      final content = widget.exercise.content as CrosswordContent;
      for (final word in content.words) {
        for (int i = 0; i < word.length; i++) {
          int row = word.startRow;
          int col = word.startCol;
          if (word.direction == 'across') {
            col += i;
          } else {
            row += i;
          }
          final key = '${row}_$col';
          final answer = _crosswordAnswers[key];
          if (answer == null || answer.trim().isEmpty) {
            return false;
          }
        }
      }
      return true;
    }
    
    // Các loại khác
    return _selectedAnswer != null;
  }

  /// Đáp án A/B/C… — mockup: chọn = viền navy + nền trắng + vòng chữ navy trắng; sau submit giữ feedback xanh/đỏ.
  Widget _buildMockupChoiceRows({
    required ChoiceContent content,
    required bool isSubmitted,
    required String? selectedAnswer,
    required void Function(String option) onSelect,
  }) {
    const letterCodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return Column(
      children: content.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final letter = index < letterCodes.length ? letterCodes[index] : '${index + 1}';
        final isSelected = selectedAnswer == option;
        final isCorrectAnswer = content.correctAnswers.contains(option);

        Color bg;
        Color borderColor;
        Color textColor;
        Color circleBg;
        Color circleFg;
        IconData? trail;

        if (isSubmitted) {
          if (isCorrectAnswer) {
            bg = Colors.green.withOpacity(0.18);
            borderColor = Colors.green.shade700;
            textColor = Colors.green.shade900;
            circleBg = Colors.green.shade100;
            circleFg = Colors.green.shade800;
            trail = Icons.check_circle_rounded;
          } else if (isSelected) {
            bg = Colors.red.withOpacity(0.16);
            borderColor = Colors.red.shade700;
            textColor = Colors.red.shade900;
            circleBg = Colors.red.shade100;
            circleFg = Colors.red.shade800;
            trail = Icons.cancel_rounded;
          } else {
            bg = _kSurface;
            borderColor = Colors.transparent;
            textColor = Colors.grey.shade600;
            circleBg = _kSurfaceContainer;
            circleFg = _kOnSurfaceVariant;
          }
        } else if (isSelected) {
          bg = _kOptionSelectedFill;
          borderColor = _kPrimary;
          textColor = _kOnSurface;
          circleBg = _kPrimary;
          circleFg = Colors.white;
        } else {
          bg = _kSurface;
          borderColor = Colors.transparent;
          textColor = _kOnSurface;
          circleBg = _kSurfaceContainer;
          circleFg = _kOptionCircleIdleFg;
        }

        final thickBorder = isSubmitted
            ? (isCorrectAnswer || (isSelected && !isCorrectAnswer))
            : isSelected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isSubmitted ? null : () => onSelect(option),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: thickBorder ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleBg,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: circleFg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (trail != null)
                      Icon(
                        trail,
                        color: isCorrectAnswer
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleChoice() {
    final content = widget.exercise.content as ChoiceContent;
    final loc = AppLocalizations.of(context)!;
    final (speaker, dialogue) = _parseSpeaker(widget.exercise.question);
    final totalQ = 1;
    final currentQ = 1;
    final showBadge = widget.exercise.skillTypes.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kSurfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        loc.questionNumber(currentQ, totalQ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                    if (showBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kTertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          loc.newSkillBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: _kOnTertiaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (speaker != null) ...[
                  Text(
                    '$speaker:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  dialogue,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kOnSurface,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _buildMockupChoiceRows(
                  content: content,
                  isSubmitted: _isSubmitted,
                  selectedAnswer: _selectedAnswer as String?,
                  onSelect: (o) {
                    setState(() {
                      _selectedAnswer = o;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        if (widget.exercise.audioUrl != null && widget.exercise.audioUrl!.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: QuestionAudioPlayer(
              questionText: widget.exercise.question,
              speakerVoices: widget.exercise.speakerVoices,
              defaultVoice: widget.exercise.defaultVoice,
              autoPlay: false,
            ),
          ),
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

  Widget _buildSingleChoiceForGroup(GroupQuestion groupQuestion, int groupIndex) {
    final content = groupQuestion.content as ChoiceContent;
    final selectedAnswer = _groupQuestionAnswers[groupIndex] as String?;
    final isSubmitted = _questionResults.containsKey(groupIndex);
    final (speaker, dialogue) = _parseSpeaker(groupQuestion.question);
    final loc = AppLocalizations.of(context)!;
    final gq = widget.exercise.groupQuestions!;
    final totalQ = gq.length;
    final currentQ = groupIndex + 1;
    final showBadge =
        widget.exercise.skillTypes.isNotEmpty && groupIndex == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupQuestion.imageUrl != null && groupQuestion.imageUrl!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _kSurfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGroupQuestionImage(groupQuestion.imageUrl!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _kSurfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            loc.questionNumber(currentQ, totalQ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                        if (showBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kTertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              loc.newSkillBadge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: _kOnTertiaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (speaker != null) ...[
                      Text(
                        '$speaker:',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _kPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      dialogue,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _kOnSurface,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildMockupChoiceRows(
                      content: content,
                      isSubmitted: isSubmitted,
                      selectedAnswer: selectedAnswer,
                      onSelect: (o) {
                        setState(() {
                          _groupQuestionAnswers[groupIndex] = o;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: QuestionAudioPlayer(
                questionText: groupQuestion.question,
                speakerVoices: widget.exercise.speakerVoices,
                defaultVoice: widget.exercise.defaultVoice,
                autoPlay: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceForGroup(GroupQuestion groupQuestion, int groupIndex) {
    final content = groupQuestion.content as ChoiceContent;
    final selectedAnswers = (_groupQuestionAnswers[groupIndex] as List<String>?) ?? [];
    final isSubmitted = _questionResults.containsKey(groupIndex);
    final (speaker, dialogue) = _parseSpeaker(groupQuestion.question);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image của GroupQuestion (nếu có)
        if (groupQuestion.imageUrl != null && groupQuestion.imageUrl!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGroupQuestionImage(groupQuestion.imageUrl!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Card hiển thị question text
        Stack(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2D2D2D) // Màu sáng hơn cho dark mode
                    : Theme.of(context).cardTheme.color ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (speaker != null) ...[
                      Text(
                        '$speaker:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      dialogue,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: QuestionAudioPlayer(
                questionText: groupQuestion.question,
                speakerVoices: widget.exercise.speakerVoices,
                defaultVoice: widget.exercise.defaultVoice,
                autoPlay: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Options buttons
        ...content.options.map((option) {
          final isSelected = selectedAnswers.contains(option);
          final isCorrectAnswer = content.correctAnswers.contains(option);

          Color? backgroundColor;
          Color? foregroundColor;
          IconData? iconData;
          Color? iconColor;

          if (isSubmitted) {
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withOpacity(0.2);
              foregroundColor = Colors.green[900];
              iconData = Icons.check_circle;
              iconColor = Colors.green;
            } else if (isSelected && !isCorrectAnswer) {
              backgroundColor = Colors.red.withOpacity(0.2);
              foregroundColor = Colors.red[900];
              iconData = Icons.cancel;
              iconColor = Colors.red;
            } else {
              backgroundColor = Colors.grey[200];
              foregroundColor = Colors.grey[600];
            }
          } else {
            backgroundColor = Colors.grey[200];
            foregroundColor = Colors.black87;
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: isSubmitted
                  ? null
                  : () {
                      setState(() {
                        final current = List<String>.from(selectedAnswers);
                        if (isSelected) {
                          current.remove(option);
                        } else {
                          current.add(option);
                        }
                        _groupQuestionAnswers[groupIndex] = current;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                children: [
                  if (iconData != null) ...[
                    Icon(iconData, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Nhãn danh mục (uppercase) cho fill blank — mockup: "VERB CONJUGATION".
  String? _fillBlankCategoryLabel() {
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final t = widget.exercise.getTitle(languageCode);
    if (t.trim().isNotEmpty) return t.trim().toUpperCase();
    if (widget.exercise.skillTypes.isNotEmpty) {
      return widget.exercise.skillTypes.first.toUpperCase();
    }
    if (widget.exercise.grammarTopics.isNotEmpty) {
      return widget.exercise.grammarTopics.first.replaceAll('_', ' ').toUpperCase();
    }
    return null;
  }

  static const BoxDecoration _kFillBlankCardDecoration = BoxDecoration(
    color: Color(0xFFFFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(32)),
    boxShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );

  Widget _buildFillBlank() {
    final content = widget.exercise.content as FillBlankContent;

    final Map<int, String> correctAnswersMap = {};
    for (final blank in content.blanks) {
      correctAnswersMap[blank.position] = blank.correctAnswer;
    }

    final category = _fillBlankCategoryLabel();

    return Container(
      width: double.infinity,
      decoration: _kFillBlankCardDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category != null) ...[
              Text(
                category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: _kOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _buildQuestionWithTextFields(
              widget.exercise.question,
              0,
              correctAnswersMap,
              forceSubmitted: _isSubmitted,
              fillBlankContent: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlankForGroup(GroupQuestion groupQuestion, int groupIndex) {
    Map<int, String> correctAnswersMap = {};
    FillBlankContent? fillContent;
    if (groupQuestion.content is FillBlankContent) {
      fillContent = groupQuestion.content as FillBlankContent;
      for (final blank in fillContent.blanks) {
        correctAnswersMap[blank.position] = blank.correctAnswer;
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

    final category = _fillBlankCategoryLabel();

    return Container(
      width: double.infinity,
      decoration: _kFillBlankCardDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupQuestion.imageUrl != null && groupQuestion.imageUrl!.isNotEmpty) ...[
              _buildGroupQuestionImage(groupQuestion.imageUrl!),
              const SizedBox(height: 16),
            ],
            if (category != null) ...[
              Text(
                category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: _kOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _buildQuestionWithTextFields(
              groupQuestion.question,
              groupIndex,
              correctAnswersMap,
              forceSubmitted: _isSubmitted || _questionResults.containsKey(groupIndex),
              fillBlankContent: fillContent,
            ),
          ],
        ),
      ),
    );
  }

  void _showFillBlankHintsDialog(FillBlankContent content) {
    final loc = AppLocalizations.of(context)!;
    final lines = <String>[];
    for (final b in content.blanks) {
      if (b.hints.isEmpty) continue;
      for (final h in b.hints) {
        lines.add('• $h');
      }
    }
    if (lines.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.fillBlankNeedHint),
        content: SingleChildScrollView(
          child: Text(lines.join('\n'), style: const TextStyle(height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWithTextFields(
    String question,
    int groupIndex,
    Map<int, String> correctAnswersMap, {
    bool? forceSubmitted,
    FillBlankContent? fillBlankContent,
  }) {
    String? instructionLine;
    var body = question;
    final nl = question.indexOf('\n');
    if (nl != -1) {
      instructionLine = question.substring(0, nl).trim();
      body = question.substring(nl + 1).trim();
    }

    final fc = fillBlankContent;
    final hasHints = fc != null && fc.blanks.any((b) => b.hints.isNotEmpty);
    final contentForHints = fc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (instructionLine != null && instructionLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              instructionLine,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kOnSurface,
                height: 1.35,
              ),
            ),
          ),
        _buildFillBlankInlineSentence(
          body,
          groupIndex,
          correctAnswersMap,
          forceSubmitted,
        ),
        if (hasHints && contentForHints != null) ...[
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => _showFillBlankHintsDialog(contentForHints),
            icon: const Icon(Icons.lightbulb_outline_rounded, color: _kPrimary, size: 22),
            label: Text(
              AppLocalizations.of(context)!.fillBlankNeedHint,
              style: const TextStyle(
                color: _kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _kPrimary,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFillBlankInlineSentence(
    String question,
    int groupIndex,
    Map<int, String> correctAnswersMap,
    bool? forceSubmitted,
  ) {
    final regex = RegExp(r'(\{(\d+)\})');
    final matches = regex.allMatches(question);

    if (matches.isEmpty) {
      return Text(
        question,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: _kOnSurface,
          height: 1.45,
        ),
      );
    }

    final List<Widget> widgets = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        final textBefore = question.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          widgets.add(
            Text(
              textBefore,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: _kOnSurface,
                height: 1.45,
              ),
            ),
          );
        }
      }

      final placeholderIndex = int.parse(match.group(2)!);
      final storageKey = groupIndex * 1000 + placeholderIndex;
      final userAnswer = _fillBlankAnswers[storageKey] ?? '';
      final isSubmitted = forceSubmitted ??
          (_isSubmitted ||
              (widget.exercise.groupQuestions != null &&
                  _questionResults.containsKey(groupIndex)));
      final correctAnswer = correctAnswersMap[placeholderIndex] ?? '';
      final isCorrect =
          isSubmitted && userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
      final isWrong = isSubmitted && !isCorrect;

      final minChars = math.max(correctAnswer.length, 4);
      final slotWidth = (minChars * 13.0 + 36).clamp(72.0, 220.0);

      Color fillBg = _kSurfaceContainer;
      Color underline = _kPrimary;
      if (isSubmitted) {
        if (isCorrect) {
          fillBg = Colors.green.withValues(alpha: 0.14);
          underline = Colors.green.shade700;
        } else if (isWrong) {
          fillBg = Colors.red.withValues(alpha: 0.12);
          underline = Colors.red.shade700;
        }
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 2, right: 6, top: 2, bottom: 2),
          child: _FillBlankSlot(
            width: slotWidth,
            fillColor: fillBg,
            underlineColor: underline,
            underlineHeight: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey('fb_${groupIndex}_$placeholderIndex'),
                    enabled: !isSubmitted,
                    controller: TextEditingController(text: userAnswer)
                      ..selection = TextSelection.collapsed(offset: userAnswer.length),
                    onChanged: (value) {
                      setState(() {
                        _fillBlankAnswers[storageKey] = value;
                      });
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSubmitted && isCorrect ? FontWeight.w700 : FontWeight.w600,
                      color: isSubmitted && isWrong ? Colors.red.shade900 : _kOnSurface,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      hintText: '----',
                      hintStyle: TextStyle(
                        color: _kOnSurfaceVariant,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (isSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < question.length) {
      final textAfter = question.substring(lastEnd);
      if (textAfter.isNotEmpty) {
        widgets.add(
          Text(
            textAfter,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: _kOnSurface,
              height: 1.45,
            ),
          ),
        );
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      runSpacing: 10,
      children: widgets,
    );
  }

  Widget _buildMatching() {
    final content = widget.exercise.content as MatchingContent;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    // Tính toán màu sắc cho từng pair sau khi submit
    Color? getLeftItemColor(int leftIndex) {
      if (!_isSubmitted) {
        final isMatched = _matchingPairs.containsKey(leftIndex);
        final isSelected = _selectedLeftIndex == leftIndex;
        if (isMatched) return Colors.green[100];
        if (isSelected) return AppTheme.primaryColor.withOpacity(0.3);
        return Colors.grey[200];
      }
      
      // Sau khi submit, kiểm tra xem pair có đúng không
      final userRightIndex = _matchingPairs[leftIndex];
      if (userRightIndex == null) return Colors.red[100];
      
      // Tìm correct pair
      for (final correctPair in content.correctPairs) {
        final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
        if (correctLeftIndex != leftIndex) continue;
        
        // Lấy right value theo language code
        final correctRightValue = correctPair.getRight(languageCode);
        
        // Tìm index của right item
        int? correctRightIndex;
        for (int i = 0; i < content.rightItems.length; i++) {
          final rightItem = content.getRightItem(i, languageCode);
          if (rightItem == correctRightValue) {
            correctRightIndex = i;
            break;
          }
        }
        
        if (correctRightIndex != null && correctRightIndex == userRightIndex) {
          return Colors.green[100];
        }
      }
      return Colors.red[100];
    }
    
    Color? getRightItemColor(int rightIndex) {
      if (!_isSubmitted) {
        final isMatched = _matchingPairs.containsValue(rightIndex);
        final isSelectedForCurrentLeft = _selectedLeftIndex != null && 
                                          _matchingPairs[_selectedLeftIndex] == rightIndex;
        if (isMatched) return Colors.green[100];
        if (isSelectedForCurrentLeft) return AppTheme.primaryColor.withOpacity(0.3);
        return Colors.grey[200];
      }
      
      // Sau khi submit, kiểm tra xem pair có đúng không
      final leftIndex = _matchingPairs.entries
          .where((e) => e.value == rightIndex)
          .map((e) => e.key)
          .firstOrNull;
      if (leftIndex == null) return Colors.grey[200];
      
      // Tìm correct pair
      for (final correctPair in content.correctPairs) {
        final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
        if (correctLeftIndex != leftIndex) continue;
        
        // Lấy right value theo language code
        final correctRightValue = correctPair.getRight(languageCode);
        
        // Tìm index của right item
        int? correctRightIndex;
        for (int i = 0; i < content.rightItems.length; i++) {
          final rightItem = content.getRightItem(i, languageCode);
          if (rightItem == correctRightValue) {
            correctRightIndex = i;
            break;
          }
        }
        
        if (correctRightIndex != null && correctRightIndex == rightIndex) {
          return Colors.green[100];
        }
      }
      return Colors.red[100];
    }
    
    IconData? getLeftItemIcon(int leftIndex) {
      if (!_isSubmitted) {
        if (_matchingPairs.containsKey(leftIndex)) {
          return Icons.check_circle;
        }
        return null;
      }
      
      final color = getLeftItemColor(leftIndex);
      if (color == Colors.green[100]) return Icons.check_circle;
      if (color == Colors.red[100]) return Icons.cancel;
      return null;
    }
    
    IconData? getRightItemIcon(int rightIndex) {
      if (!_isSubmitted) {
        if (_matchingPairs.containsValue(rightIndex)) {
          return Icons.check_circle;
        }
        return null;
      }
      
      final color = getRightItemColor(rightIndex);
      if (color == Colors.green[100]) return Icons.check_circle;
      if (color == Colors.red[100]) return Icons.cancel;
      return null;
    }
    
    Color? getLeftItemIconColor(int leftIndex) {
      if (!_isSubmitted) return Colors.green;
      final color = getLeftItemColor(leftIndex);
      if (color == Colors.green[100]) return Colors.green;
      if (color == Colors.red[100]) return Colors.red;
      return null;
    }
    
    Color? getRightItemIconColor(int rightIndex) {
      if (!_isSubmitted) return Colors.green;
      final color = getRightItemColor(rightIndex);
      if (color == Colors.green[100]) return Colors.green;
      if (color == Colors.red[100]) return Colors.red;
      return null;
    }
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.matchItems,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left items column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...content.leftItems.asMap().entries.map((entry) {
                        final leftIndex = entry.key;
                        final leftItem = entry.value;
                        final isMatched = _matchingPairs.containsKey(leftIndex);
                        final isSelected = _selectedLeftIndex == leftIndex;
                        final itemColor = getLeftItemColor(leftIndex);
                        final icon = getLeftItemIcon(leftIndex);
                        final iconColor = getLeftItemIconColor(leftIndex);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: _isSubmitted || isMatched ? null : () {
                              setState(() {
                                if (_selectedLeftIndex == leftIndex) {
                                  // Deselect nếu đã chọn
                                  _selectedLeftIndex = null;
                                } else {
                                  _selectedLeftIndex = leftIndex;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: itemColor ?? Colors.grey[200],
                              foregroundColor: isSelected && !_isSubmitted
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    leftItem,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelected && !_isSubmitted ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(icon, color: iconColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right items column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...content.rightItems.asMap().entries.map((entry) {
                        final rightIndex = entry.key;
                        final rightItem = content.getRightItem(rightIndex, languageCode);
                        final isMatched = _matchingPairs.containsValue(rightIndex);
                        final isSelectedForCurrentLeft = _selectedLeftIndex != null && 
                                                          _matchingPairs[_selectedLeftIndex] == rightIndex;
                        final itemColor = getRightItemColor(rightIndex);
                        final icon = getRightItemIcon(rightIndex);
                        final iconColor = getRightItemIconColor(rightIndex);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: _isSubmitted || isMatched ? null : () {
                              if (_selectedLeftIndex != null) {
                                setState(() {
                                  // Xóa match cũ nếu right item đã được match với left item khác
                                  _matchingPairs.removeWhere((key, value) => value == rightIndex);
                                  // Thêm match mới
                                  _matchingPairs[_selectedLeftIndex!] = rightIndex;
                                  _selectedLeftIndex = null;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: itemColor ?? Colors.grey[200],
                              foregroundColor: isSelectedForCurrentLeft && !_isSubmitted
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rightItem,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelectedForCurrentLeft && !_isSubmitted ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(icon, color: iconColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedLeftIndex != null && !_isSubmitted)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Selected: ${content.leftItems[_selectedLeftIndex!]} - Now select a right item',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingForGroup(GroupQuestion groupQuestion, int groupIndex) {
    final content = groupQuestion.content as MatchingContent;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    // Lấy matching pairs và selected left index cho group này
    final matchingPairs = _groupMatchingPairs[groupIndex] ?? {};
    final selectedLeftIndex = _groupSelectedLeftIndex[groupIndex];
    final isSubmitted = _questionResults.containsKey(groupIndex);
    
    // Tính toán màu sắc cho từng pair sau khi submit
    Color? getLeftItemColor(int leftIndex) {
      if (!isSubmitted) {
        final isMatched = matchingPairs.containsKey(leftIndex);
        final isSelected = selectedLeftIndex == leftIndex;
        if (isMatched) return Colors.green[100];
        if (isSelected) return AppTheme.primaryColor.withOpacity(0.3);
        return Colors.grey[200];
      }
      
      // Sau khi submit, kiểm tra xem pair có đúng không
      final userRightIndex = matchingPairs[leftIndex];
      if (userRightIndex == null) return Colors.red[100];
      
      // Tìm correct pair
      for (final correctPair in content.correctPairs) {
        final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
        if (correctLeftIndex != leftIndex) continue;
        
        // Lấy right value theo language code
        final correctRightValue = correctPair.getRight(languageCode);
        
        // Tìm index của right item
        int? correctRightIndex;
        for (int i = 0; i < content.rightItems.length; i++) {
          final rightItem = content.getRightItem(i, languageCode);
          if (rightItem == correctRightValue) {
            correctRightIndex = i;
            break;
          }
        }
        
        if (correctRightIndex != null && correctRightIndex == userRightIndex) {
          return Colors.green[100];
        }
      }
      return Colors.red[100];
    }
    
    Color? getRightItemColor(int rightIndex) {
      if (!isSubmitted) {
        final isMatched = matchingPairs.containsValue(rightIndex);
        final isSelectedForCurrentLeft = selectedLeftIndex != null && 
                                        matchingPairs[selectedLeftIndex] == rightIndex;
        if (isMatched) return Colors.green[100];
        if (isSelectedForCurrentLeft) return AppTheme.primaryColor.withOpacity(0.3);
        return Colors.grey[200];
      }
      
      // Sau khi submit, kiểm tra xem pair có đúng không
      final leftIndex = matchingPairs.entries
          .where((e) => e.value == rightIndex)
          .map((e) => e.key)
          .firstOrNull;
      if (leftIndex == null) return Colors.grey[200];
      
      // Tìm correct pair
      for (final correctPair in content.correctPairs) {
        final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
        if (correctLeftIndex != leftIndex) continue;
        
        // Lấy right value theo language code
        final correctRightValue = correctPair.getRight(languageCode);
        
        // Tìm index của right item
        int? correctRightIndex;
        for (int i = 0; i < content.rightItems.length; i++) {
          final rightItem = content.getRightItem(i, languageCode);
          if (rightItem == correctRightValue) {
            correctRightIndex = i;
            break;
          }
        }
        
        if (correctRightIndex != null && correctRightIndex == rightIndex) {
          return Colors.green[100];
        }
      }
      return Colors.red[100];
    }
    
    IconData? getLeftItemIcon(int leftIndex) {
      if (!isSubmitted) {
        if (matchingPairs.containsKey(leftIndex)) {
          return Icons.check_circle;
        }
        return null;
      }
      
      final color = getLeftItemColor(leftIndex);
      if (color == Colors.green[100]) return Icons.check_circle;
      if (color == Colors.red[100]) return Icons.cancel;
      return null;
    }
    
    IconData? getRightItemIcon(int rightIndex) {
      if (!isSubmitted) {
        if (matchingPairs.containsValue(rightIndex)) {
          return Icons.check_circle;
        }
        return null;
      }
      
      final color = getRightItemColor(rightIndex);
      if (color == Colors.green[100]) return Icons.check_circle;
      if (color == Colors.red[100]) return Icons.cancel;
      return null;
    }
    
    Color? getLeftItemIconColor(int leftIndex) {
      if (!isSubmitted) return Colors.green;
      final color = getLeftItemColor(leftIndex);
      if (color == Colors.green[100]) return Colors.green;
      if (color == Colors.red[100]) return Colors.red;
      return null;
    }
    
    Color? getRightItemIconColor(int rightIndex) {
      if (!isSubmitted) return Colors.green;
      final color = getRightItemColor(rightIndex);
      if (color == Colors.green[100]) return Colors.green;
      if (color == Colors.red[100]) return Colors.red;
      return null;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image của GroupQuestion (nếu có)
        if (groupQuestion.imageUrl != null && groupQuestion.imageUrl!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGroupQuestionImage(groupQuestion.imageUrl!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.matchItems,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left items column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...content.leftItems.asMap().entries.map((entry) {
                            final leftIndex = entry.key;
                            final leftItem = entry.value;
                            final isMatched = matchingPairs.containsKey(leftIndex);
                            final isSelected = selectedLeftIndex == leftIndex;
                            final itemColor = getLeftItemColor(leftIndex);
                            final icon = getLeftItemIcon(leftIndex);
                            final iconColor = getLeftItemIconColor(leftIndex);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ElevatedButton(
                                onPressed: isSubmitted || isMatched ? null : () {
                                  setState(() {
                                    if (selectedLeftIndex == leftIndex) {
                                      // Deselect nếu đã chọn
                                      _groupSelectedLeftIndex[groupIndex] = null;
                                    } else {
                                      _groupSelectedLeftIndex[groupIndex] = leftIndex;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: itemColor ?? Colors.grey[200],
                                  foregroundColor: isSelected && !isSubmitted
                                      ? AppTheme.primaryColor
                                      : Colors.black87,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        leftItem,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: isSelected && !isSubmitted ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (icon != null)
                                      Icon(icon, color: iconColor, size: 20),
                                  ],
                                ),
                              ),
                            );
                      }).toList(),
                    ],
                  ),
                ),
                    const SizedBox(width: 16),
                    // Right items column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...content.rightItems.asMap().entries.map((entry) {
                        final rightIndex = entry.key;
                        final rightItem = content.getRightItem(rightIndex, languageCode);
                        final isMatched = matchingPairs.containsValue(rightIndex);
                        final isSelectedForCurrentLeft = selectedLeftIndex != null && 
                                                          matchingPairs[selectedLeftIndex] == rightIndex;
                        final itemColor = getRightItemColor(rightIndex);
                        final icon = getRightItemIcon(rightIndex);
                        final iconColor = getRightItemIconColor(rightIndex);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: isSubmitted || isMatched ? null : () {
                              if (selectedLeftIndex != null) {
                                setState(() {
                                  // Đảm bảo _groupMatchingPairs[groupIndex] tồn tại
                                  if (!_groupMatchingPairs.containsKey(groupIndex)) {
                                    _groupMatchingPairs[groupIndex] = {};
                                  }
                                  
                                  // Xóa match cũ nếu right item đã được match với left item khác
                                  _groupMatchingPairs[groupIndex]!.removeWhere((key, value) => value == rightIndex);
                                  // Thêm match mới
                                  _groupMatchingPairs[groupIndex]![selectedLeftIndex!] = rightIndex;
                                  _groupSelectedLeftIndex[groupIndex] = null;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: itemColor ?? Colors.grey[200],
                              foregroundColor: isSelectedForCurrentLeft && !isSubmitted
                                  ? AppTheme.primaryColor
                                  : Colors.black87,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rightItem,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: isSelectedForCurrentLeft && !isSubmitted ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null)
                                  Icon(icon, color: iconColor, size: 20),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                  ],
                ),
                if (selectedLeftIndex != null && !isSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Selected: ${content.leftItems[selectedLeftIndex!]} - Now select a right item',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method để lấy FocusNode cho một cell
  FocusNode _getFocusNode(String key) {
    if (!_crosswordFocusNodes.containsKey(key)) {
      _crosswordFocusNodes[key] = FocusNode();
    }
    return _crosswordFocusNodes[key]!;
  }

  // Helper method để focus vào ô đầu tiên của word
  void _focusWordFirstCell(CrosswordContent content, String direction, int number) {
    final word = content.words.firstWhere(
      (w) => w.direction == direction && w.number == number,
      orElse: () => content.words.first,
    );
    
    final firstKey = '${word.startRow}_${word.startCol}';
    final focusNode = _getFocusNode(firstKey);
    Future.microtask(() => focusNode.requestFocus());
  }

  // Helper method để chuyển focus sang ô tiếp theo trong word
  void _moveToNextCell(CrosswordContent content, int currentRow, int currentCol, String direction, int wordNumber) {
    final word = content.words.firstWhere(
      (w) => w.direction == direction && w.number == wordNumber,
      orElse: () => content.words.first,
    );
    
    // Tìm vị trí hiện tại trong word
    int currentIndex = -1;
    if (direction == 'across') {
      currentIndex = currentCol - word.startCol;
    } else {
      currentIndex = currentRow - word.startRow;
    }
    
    // Nếu chưa đến cuối word, chuyển sang ô tiếp theo
    if (currentIndex >= 0 && currentIndex < word.length - 1) {
      int nextRow = word.startRow;
      int nextCol = word.startCol;
      if (direction == 'across') {
        nextCol = word.startCol + currentIndex + 1;
      } else {
        nextRow = word.startRow + currentIndex + 1;
      }
      
      final nextKey = '${nextRow}_$nextCol';
      final nextFocusNode = _getFocusNode(nextKey);
      Future.microtask(() => nextFocusNode.requestFocus());
    }
  }

  // Helper method để chuyển focus về ô trước trong word (khi backspace)
  void _moveToPreviousCell(CrosswordContent content, int currentRow, int currentCol, String direction, int wordNumber) {
    final word = content.words.firstWhere(
      (w) => w.direction == direction && w.number == wordNumber,
      orElse: () => content.words.first,
    );
    
    // Tìm vị trí hiện tại trong word
    int currentIndex = -1;
    if (direction == 'across') {
      currentIndex = currentCol - word.startCol;
    } else {
      currentIndex = currentRow - word.startRow;
    }
    
    // Nếu chưa ở đầu word, chuyển về ô trước
    if (currentIndex > 0) {
      int prevRow = word.startRow;
      int prevCol = word.startCol;
      if (direction == 'across') {
        prevCol = word.startCol + currentIndex - 1;
      } else {
        prevRow = word.startRow + currentIndex - 1;
      }
      
      final prevKey = '${prevRow}_$prevCol';
      final prevFocusNode = _getFocusNode(prevKey);
      Future.microtask(() {
        prevFocusNode.requestFocus();
        // Xóa nội dung ô trước
        setState(() {
          _crosswordAnswers.remove(prevKey);
        });
      });
    }
  }

  // Helper method để tìm word chứa một cell
  CrosswordWord? _findWordContainingCell(CrosswordContent content, int row, int col) {
    for (final word in content.words) {
      for (int i = 0; i < word.length; i++) {
        int wordRow = word.startRow;
        int wordCol = word.startCol;
        if (word.direction == 'across') {
          wordCol += i;
        } else {
          wordRow += i;
        }
        
        if (wordRow == row && wordCol == col) {
          return word;
        }
      }
    }
    return null;
  }

  Widget _buildCrossword() {
    final content = widget.exercise.content as CrosswordContent;
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(content.rows, (row) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(content.cols, (col) {
                          final cellValue = content.grid[row][col];
                          final key = '${row}_$col';
                          final userInput = _crosswordAnswers[key] ?? '';
                          
                          // Kiểm tra xem ô này có nằm trong word nào không
                          bool isCellInWord = false;
                          int? wordNumberAtStart = cellValue; // Số ở ô bắt đầu (nếu có)
                          
                          for (final word in content.words) {
                            for (int i = 0; i < word.length; i++) {
                              int wordRow = word.startRow;
                              int wordCol = word.startCol;
                              if (word.direction == 'across') {
                                wordCol += i;
                              } else {
                                wordRow += i;
                              }
                              
                              if (wordRow == row && wordCol == col) {
                                isCellInWord = true;
                                // Nếu là ô bắt đầu, lấy số của word
                                if (i == 0) {
                                  wordNumberAtStart = word.number;
                                }
                                break;
                              }
                            }
                            if (isCellInWord) break;
                          }
                          
                          // Nếu không nằm trong word nào, là blocker (ô đen)
                          if (!isCellInWord) {
                            return Container(
                              width: 31,
                              height: 31,
                              margin: const EdgeInsets.all(0.5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.grey),
                              ),
                            );
                          }
                          
                          // Nếu là ô có thể điền (nằm trong word)
                          final wordNumber = wordNumberAtStart;
                          
                          return Container(
                            width: 31,
                            height: 31,
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Stack(
                              children: [
                                // Word number ở góc trên bên trái
                                if (wordNumber != null)
                                  Positioned(
                                    top: 2,
                                    left: 2,
                                    child: Text(
                                      '$wordNumber',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                // TextField để nhập
                                Center(
                                  child: TextField(
                                    key: ValueKey(key),
                                    focusNode: _getFocusNode(key),
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    enabled: !_isSubmitted,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      fillColor: _isSubmitted ? Colors.grey[200] : Colors.white,
                                      filled: _isSubmitted,
                                    ),
                                    controller: TextEditingController(text: userInput)
                                      ..selection = TextSelection.collapsed(offset: userInput.length),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isNotEmpty) {
                                          final upperValue = value.toUpperCase();
                                          _crosswordAnswers[key] = upperValue;
                                          
                                          // Tìm word chứa cell này
                                          final word = _findWordContainingCell(content, row, col);
                                          if (word != null) {
                                            // Tự động chuyển sang ô tiếp theo
                                            _moveToNextCell(content, row, col, word.direction, word.number);
                                          }
                                        } else {
                                          _crosswordAnswers.remove(key);
                                          
                                          // Khi backspace, chuyển về ô trước
                                          final word = _findWordContainingCell(content, row, col);
                                          if (word != null) {
                                            _moveToPreviousCell(content, row, col, word.direction, word.number);
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Clues section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Across clues
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Across',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: content.words.where((w) => w.direction == 'across').length,
                          itemBuilder: (context, index) {
                            final acrossWords = content.words.where((w) => w.direction == 'across').toList()..sort((a, b) => a.number.compareTo(b.number));
                            final word = acrossWords[index];
                            final isActive = _activeWord == 'across_${word.number}';
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _activeWord = 'across_${word.number}';
                                  _focusWordFirstCell(content, 'across', word.number);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${word.number}. ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(word.clue),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Down clues
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Down',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: content.words.where((w) => w.direction == 'down').length,
                          itemBuilder: (context, index) {
                            final downWords = content.words.where((w) => w.direction == 'down').toList()..sort((a, b) => a.number.compareTo(b.number));
                            final word = downWords[index];
                            final isActive = _activeWord == 'down_${word.number}';
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _activeWord = 'down_${word.number}';
                                  _focusWordFirstCell(content, 'down', word.number);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${word.number}. ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(word.clue),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordMatching() {
    final content = widget.exercise.content as WordMatchingContent;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    // State để lưu các cặp đã match
    Map<int, int> matchedPairs = {}; // wordIndex -> definitionIndex
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match each word with its definition',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Words column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Words',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...content.pairs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pair = entry.value;
                        final isMatched = matchedPairs.containsKey(index);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: isMatched ? null : () {
                              // TODO: Implement matching logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMatched ? Colors.green[100] : Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                            child: Row(
                              children: [
                                Text(pair.word),
                                if (pair.audioUrl != null) ...[
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 16),
                                    onPressed: () {
                                      // TODO: Implement audio playback
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Definitions column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Definitions',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...(content.shuffleOptions 
                          ? (content.pairs.map((p) => p.getDefinition(languageCode)).toList()..shuffle())
                          : content.pairs.map((p) => p.getDefinition(languageCode)).toList()
                      ).asMap().entries.map((entry) {
                        final index = entry.key;
                        final definition = entry.value;
                        final isMatched = matchedPairs.containsValue(index);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: isMatched ? null : () {
                              // TODO: Implement matching logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMatched ? Colors.green[100] : Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(definition),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionMatching() {
    final content = widget.exercise.content as DefinitionMatchingContent;
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match each definition with its word',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Definitions column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Definitions',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...content.pairs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pair = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pair.getDefinition(languageCode),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (pair.example != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Example: ${pair.example}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Words column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Words',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...(content.pairs.map((p) => p.word).toList()..shuffle()).asMap().entries.map((entry) {
                        final index = entry.key;
                        final word = entry.value;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement matching logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(word),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordFormation() {
    final content = widget.exercise.content as WordFormationContent;
    
    String? selectedForm;
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.completeSentenceWithForm(content.baseWord),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              content.sentence,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedForm,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.selectCorrectForm,
                border: OutlineInputBorder(),
              ),
              items: content.options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedForm = value;
                });
              },
            ),
            if (content.explanation != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    content.explanation!,
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordPattern() {
    final content = widget.exercise.content as WordPatternContent;
    
    String? selectedPreposition;
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the correct preposition for the pattern "${content.pattern}"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              content.sentence,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: content.options.map((option) {
                final isSelected = selectedPreposition == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedPreposition = selected ? option : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pattern: ${content.pattern}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Word: ${content.word}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    bool isCorrect = false;

    // Nếu là sequentialQuestions
    if (widget.exercise.type == ExerciseType.sequentialQuestions) {
      print('=== SUBMIT - Sequential Questions ===');
      
      final groupQuestions = widget.exercise.groupQuestions!;
      _questionResults.clear();
      
      // Check tất cả questions
      for (int i = 0; i < groupQuestions.length; i++) {
        final question = groupQuestions[i];
        final isQuestionCorrect = _checkQuestionAnswer(question, i);
        _questionResults[i] = isQuestionCorrect;
        print('Question ${i + 1}: ${question.question}');
        print('  Result: ${isQuestionCorrect ? "ĐÚNG" : "SAI"}');
      }
      
      // Tổng hợp kết quả: tất cả questions phải đúng
      isCorrect = _questionResults.values.every((result) => result == true) && 
                  _questionResults.length == groupQuestions.length;
      
      print('Tổng hợp: ${isCorrect ? "ĐÚNG" : "SAI"}');
      print('==========================================\n');
    } else if (widget.exercise.groupQuestions != null && widget.exercise.groupQuestions!.isNotEmpty) {
      print('=== SUBMIT - Tất cả questions ===');
      
      // Check question cuối cùng (question hiện tại) nếu chưa check
      final lastQuestionIndex = widget.exercise.groupQuestions!.length - 1;
      if (!_questionResults.containsKey(lastQuestionIndex)) {
        final lastQuestion = widget.exercise.groupQuestions![lastQuestionIndex];
        
        // Log question cuối cùng
        print('Question ${lastQuestionIndex + 1} (chưa check):');
        print('  Question: ${lastQuestion.question}');
        print('  Type: ${lastQuestion.type}');
        
        if (lastQuestion.type == ExerciseType.fillBlank) {
          final regex = RegExp(r'\{(\d+)\}');
          final matches = regex.allMatches(lastQuestion.question);
          final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
          
          // Lấy correct answers
          Map<int, String> correctAnswersMap = {};
          if (lastQuestion.content is FillBlankContent) {
            final content = lastQuestion.content as FillBlankContent;
            final regex2 = RegExp(r'\{(\d+)\}');
            final matches2 = regex2.allMatches(lastQuestion.question);
            final placeholderIndices2 = matches2.map((m) => int.parse(m.group(1)!)).toList();
            if (content.blanks.isNotEmpty) {
              final sortedBlanks = List<BlankItem>.from(content.blanks);
              sortedBlanks.sort((a, b) => a.position.compareTo(b.position));
              for (int idx = 0; idx < placeholderIndices2.length && idx < sortedBlanks.length; idx++) {
                final placeholderIndex = placeholderIndices2[idx];
                correctAnswersMap[placeholderIndex] = sortedBlanks[idx].correctAnswer;
              }
            }
          } else if (lastQuestion.content is Map) {
            final contentMap = lastQuestion.content as Map<String, dynamic>;
            if (contentMap['correctAnswers'] != null) {
              final answers = contentMap['correctAnswers'] as List<dynamic>;
              final regex2 = RegExp(r'\{(\d+)\}');
              final matches2 = regex2.allMatches(lastQuestion.question);
              final placeholderIndices2 = matches2.map((m) => int.parse(m.group(1)!)).toList();
              for (int idx = 0; idx < placeholderIndices2.length && idx < answers.length; idx++) {
                correctAnswersMap[placeholderIndices2[idx]] = answers[idx].toString();
              }
            }
          }
          
          for (final placeholderIndex in placeholderIndices) {
            final key = lastQuestionIndex * 1000 + placeholderIndex;
            final userAnswer = _fillBlankAnswers[key];
            final correctAnswer = correctAnswersMap[placeholderIndex];
            print('    Placeholder {${placeholderIndex}}: User answer = "$userAnswer", Correct answer = "$correctAnswer"');
          }
        } else if (lastQuestion.type == ExerciseType.buttonSingleChoice) {
          final content = lastQuestion.content as ButtonSingleChoiceContent;
          final placeholderCount = _countPlaceholders(lastQuestion.question);
          for (int j = 0; j < placeholderCount; j++) {
            final key = lastQuestionIndex * 1000 + j;
            final answer = _selectedAnswers[key];
            final correctAnswer = j < content.correctAnswers.length ? content.correctAnswers[j] : null;
            print('    Placeholder $j: User answer = "${answer ?? "null"}", Correct answer = "$correctAnswer"');
          }
        } else if (lastQuestion.type == ExerciseType.singleChoice) {
          final content = lastQuestion.content as ChoiceContent;
          final userAnswer = _groupQuestionAnswers[lastQuestionIndex] as String?;
          print('    User answer: "$userAnswer"');
          print('    Correct answers: ${content.correctAnswers}');
        } else if (lastQuestion.type == ExerciseType.multipleChoice) {
          final content = lastQuestion.content as ChoiceContent;
          final userAnswers = (_groupQuestionAnswers[lastQuestionIndex] as List<String>?) ?? [];
          print('    User answers: $userAnswers');
          print('    Correct answers: ${content.correctAnswers}');
        } else if (lastQuestion.type == ExerciseType.matching) {
          final content = lastQuestion.content as MatchingContent;
          final matchingPairs = _groupMatchingPairs[lastQuestionIndex] ?? {};
          print('    Matching pairs: $matchingPairs');
          print('    Left items: ${content.leftItems}');
          print('    Correct pairs: ${content.correctPairs.length}');
        }
        
        final lastQuestionCorrect = _checkQuestionAnswer(lastQuestion, lastQuestionIndex);
        print('  Result: ${lastQuestionCorrect ? "ĐÚNG" : "SAI"}');
        _questionResults[lastQuestionIndex] = lastQuestionCorrect;
      }
      
      // Log tất cả questions
      for (int i = 0; i < widget.exercise.groupQuestions!.length; i++) {
        final question = widget.exercise.groupQuestions![i];
        print('Question ${i + 1}: ${question.question}');
        print('  Result: ${_questionResults[i] == true ? "ĐÚNG" : "SAI"}');
      }
      
      // Tổng hợp kết quả: tất cả questions phải đúng
      isCorrect = _questionResults.values.every((result) => result == true) && 
                  _questionResults.length == widget.exercise.groupQuestions!.length;
      
      print('Tổng hợp: ${isCorrect ? "ĐÚNG" : "SAI"}');
      print('==========================================\n');
    } else {
      print('=== SUBMIT - Standalone exercise ===');
      print('Question: ${widget.exercise.question}');
      print('Type: ${widget.exercise.type}');

    switch (widget.exercise.type) {
      case ExerciseType.singleChoice:
        final content = widget.exercise.content as ChoiceContent;
          print('User answer: $_selectedAnswer');
          print('Correct answers: ${content.correctAnswers}');
        isCorrect = content.correctAnswers.contains(_selectedAnswer);
        break;
      case ExerciseType.multipleChoice:
        final content = widget.exercise.content as ChoiceContent;
        final selected = _selectedAnswer as List<String>? ?? [];
          print('User answers: $selected');
          print('Correct answers: ${content.correctAnswers}');
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
          
          print('Placeholder indices: $placeholderIndices');
          for (final placeholderIndex in placeholderIndices) {
            final key = 0 * 1000 + placeholderIndex; // groupIndex = 0 for standalone
            final userAnswer = _fillBlankAnswers[key];
            final correctAnswer = correctAnswersMap[placeholderIndex];
            print('  Placeholder {${placeholderIndex}}: User = "$userAnswer", Correct = "$correctAnswer"');
          }
          
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
            print('  Placeholder $i: User answer = "${answer ?? "null"}"');
          }
          print('User answers: $userAnswers');
          print('Correct answers: ${content.correctAnswers}');
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
        case ExerciseType.matching:
          final content = widget.exercise.content as MatchingContent;
          final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
          print('User matching pairs: $_matchingPairs');
          print('Correct pairs: ${content.correctPairs}');
          
          // Kiểm tra số lượng pairs
          if (_matchingPairs.length != content.correctPairs.length) {
            isCorrect = false;
            break;
          }
          
          // Kiểm tra từng pair
          isCorrect = true;
          for (final correctPair in content.correctPairs) {
            // Tìm leftIndex từ correctPair
            final leftIndex = content.leftItems.indexOf(correctPair.left);
            if (leftIndex == -1) {
              isCorrect = false;
              break;
            }
            
            // Lấy right value theo language code từ correctPair
            final correctRightValue = correctPair.getRight(languageCode);
            
            // Tìm index của right item trong rightItems
            int? correctRightIndex;
            for (int i = 0; i < content.rightItems.length; i++) {
              final rightItem = content.getRightItem(i, languageCode);
              if (rightItem == correctRightValue) {
                correctRightIndex = i;
                break;
              }
            }
            
            if (correctRightIndex == null) {
              isCorrect = false;
              break;
            }
            
            // Kiểm tra xem user có match đúng không
            final userRightIndex = _matchingPairs[leftIndex];
            if (userRightIndex != correctRightIndex) {
              isCorrect = false;
              print('  Mismatch: left[$leftIndex]="${correctPair.left}" should match right[$correctRightIndex]="$correctRightValue", but user matched with right[$userRightIndex]');
              break;
            }
            print('  Match: left[$leftIndex]="${correctPair.left}" -> right[$correctRightIndex]="$correctRightValue" ✓');
          }
          break;
        case ExerciseType.crossword:
          final content = widget.exercise.content as CrosswordContent;
          isCorrect = true;
          for (final word in content.words) {
            String userAnswer = '';
            for (int i = 0; i < word.length; i++) {
              int row = word.startRow;
              int col = word.startCol;
              if (word.direction == 'across') {
                col += i;
              } else {
                row += i;
              }
              final key = '${row}_$col';
              final char = _crosswordAnswers[key] ?? '';
              userAnswer += char;
            }
            final correctAnswer = word.answer.toUpperCase();
            if (userAnswer.trim().toUpperCase() != correctAnswer) {
              isCorrect = false;
              break;
            }
          }
          break;
      default:
        isCorrect = false;
      }
      
      print('Result: ${isCorrect ? "ĐÚNG" : "SAI"}');
      print('==========================================\n');
    }

    setState(() {
      _isSubmitted = true;
      _isCorrect = isCorrect;
    });

    // Kiểm tra auth state và lưu progress nếu đã đăng nhập
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('=== SAVE PROGRESS DEBUG ===');
    print('isAuthenticated: ${authProvider.isAuthenticated}');
    print('user: ${authProvider.user}');
    print('user.id: ${authProvider.user?.id}');
    
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Tính time spent
      final timeSpent = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;

      int totalCount = 1;
      int correctCount = isCorrect ? 1 : 0;
      if (widget.exercise.type == ExerciseType.sequentialQuestions &&
          widget.exercise.groupQuestions != null &&
          widget.exercise.groupQuestions!.isNotEmpty) {
        totalCount = widget.exercise.groupQuestions!.length;
        correctCount = _questionResults.values.where((result) => result).length;
      }
      
      print('Saving progress for user: ${authProvider.user!.id}');
      print('Exercise: ${widget.exercise.id}');
      print('isCorrect: $isCorrect');
      print('timeSpent: $timeSpent seconds');
      
      // Lưu progress lên Firestore (async, không block UI)
      _firestoreService.saveExerciseProgress(
        authProvider.user!.id,
        widget.exercise,
        isCorrect,
        timeSpent,
        correctCount: correctCount,
        totalCount: totalCount,
      ).then((result) {
        print('✅ Progress saved successfully!');
        
        // Refresh user data để cập nhật streak và XP
        authProvider.refreshUser();
        
        // Check nếu có level-up
        if (result is SaveExerciseProgressResult && 
            result.levelUp && 
            result.oldLevel != null && 
            result.newLevel != null) {
          // Show level-up screen
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LevelUpScreen(
                  oldLevel: result.oldLevel!,
                  newLevel: result.newLevel!,
                ),
              ),
            );
          }
        } else {
          // Normal success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.progressSaved),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }).catchError((error) {
        // Log error nhưng không block UI
        print('❌ Error saving exercise progress: $error');
        print('Error stack trace: ${StackTrace.current}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorSavingProgress(error.toString())),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      print('⚠️ User not authenticated, skipping save');
      if (mounted) {
        // Hiển thị thông báo nếu chưa đăng nhập
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
  }

  Widget _buildResultSection() {
    // Tính tổng điểm trước
    int totalUserPoints = 0;
    int totalExercisePoints = 0;
    
    if (widget.exercise.groupQuestions != null && widget.exercise.groupQuestions!.isNotEmpty) {
      for (int i = 0; i < widget.exercise.groupQuestions!.length; i++) {
        final question = widget.exercise.groupQuestions![i];
        totalExercisePoints += question.point;
        if (_questionResults[i] == true) {
          totalUserPoints += question.point;
        }
      }
    } else {
      totalExercisePoints = widget.exercise.points;
      totalUserPoints = _isCorrect ? widget.exercise.points : 0;
    }
    
    // Xác định màu sắc và trạng thái dựa trên tỷ lệ điểm
    final scorePercentage = totalExercisePoints > 0 
        ? (totalUserPoints / totalExercisePoints) 
        : 0.0;
    final isPerfect = scorePercentage >= 1.0;
    final isGood = scorePercentage >= 0.7;
    
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    String statusText;
    IconData statusIcon;
    
    if (isPerfect) {
      backgroundColor = const Color(0xFFE8F5E9); // Light green
      iconColor = const Color(0xFF4CAF50); // Green
      textColor = const Color(0xFF2E7D32); // Dark green
      statusText = AppLocalizations.of(context)!.perfect;
      statusIcon = Icons.check_circle;
    } else if (isGood) {
      backgroundColor = const Color(0xFFE3F2FD); // Light blue
      iconColor = const Color(0xFF2196F3); // Blue
      textColor = const Color(0xFF1565C0); // Dark blue
      statusText = AppLocalizations.of(context)!.goodJob;
      statusIcon = Icons.thumb_up;
    } else {
      backgroundColor = const Color(0xFFFFF3E0); // Light orange
      iconColor = const Color(0xFFFF9800); // Orange
      textColor = const Color(0xFFE65100); // Dark orange
      statusText = AppLocalizations.of(context)!.needToTryHarder;
      statusIcon = Icons.trending_up;
    }
    
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng điểm - Style từ detail screen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withOpacity(0.15),
                    iconColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.star, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalUserPoints / $totalExercisePoints',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                      ),
                      Text(
                        ' ${AppLocalizations.of(context)!.points}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Header với icon và status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.exercise.explanation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.explanation,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.exercise.explanation!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Nút hành động
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailScreen(
                            exercise: widget.exercise,
                            questionResults: _questionResults,
                            groupQuestionAnswers: _groupQuestionAnswers,
                            groupMatchingPairs: _groupMatchingPairs,
                            selectedAnswers: _selectedAnswers,
                            fillBlankAnswers: _fillBlankAnswers,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.viewDetails,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.back,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildExplanationBox(String? explanation) {
    if (explanation == null || explanation.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.explanation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _looksLikeHtml(explanation)
              ? Html(data: explanation)
              : Text(explanation),
        ],
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

/// Ô điền inline fill blank: nền `#dde9ff`, bo góc trên, gạch dưới primary (mockup).
class _FillBlankSlot extends StatelessWidget {
  const _FillBlankSlot({
    required this.width,
    required this.fillColor,
    required this.underlineColor,
    required this.underlineHeight,
    required this.child,
  });

  final double width;
  final Color fillColor;
  final Color underlineColor;
  final double underlineHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border(
          bottom: BorderSide(color: underlineColor, width: underlineHeight),
        ),
      ),
      child: child,
    );
  }
}

/// Viền nét đứt bo góc cho ô placeholder (button single choice).
class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;
  static const double _strokeWidth = 1.25;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _strokeWidth / 2,
        _strokeWidth / 2,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        const dash = 5.0;
        const gap = 4.0;
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}


