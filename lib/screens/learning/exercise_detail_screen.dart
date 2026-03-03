import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;
  final Map<int, bool> questionResults; // Map<questionIndex, isCorrect>
  final Map<int, dynamic> groupQuestionAnswers; // Map<questionIndex, userAnswer>
  final Map<int, Map<int, int>> groupMatchingPairs; // Map<questionIndex, Map<leftIndex, rightIndex>>
  final Map<int, String?> selectedAnswers; // Map<placeholderKey, selectedOption> for buttonSingleChoice
  final Map<int, String> fillBlankAnswers; // Map<placeholderIndex, userInput> for fillBlank

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.questionResults,
    required this.groupQuestionAnswers,
    required this.groupMatchingPairs,
    required this.selectedAnswers,
    required this.fillBlankAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).currentLanguageCode;
    
    // Tính tổng điểm
    int totalUserPoints = 0;
    int totalExercisePoints = 0;
    
    if (exercise.groupQuestions != null && exercise.groupQuestions!.isNotEmpty) {
      for (int i = 0; i < exercise.groupQuestions!.length; i++) {
        final question = exercise.groupQuestions![i];
        totalExercisePoints += question.point;
        if (questionResults[i] == true) {
          totalUserPoints += question.point;
        }
      }
    } else {
      totalExercisePoints = exercise.points;
      totalUserPoints = questionResults.values.contains(true) ? exercise.points : 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exerciseDetails),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng điểm
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.15),
                    AppTheme.primaryColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
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
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.star, color: Colors.amber[700], size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalUserPoints / $totalExercisePoints',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
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
            const SizedBox(height: 24),
            
            // Chi tiết từng câu hỏi
            if (exercise.groupQuestions != null && exercise.groupQuestions!.isNotEmpty)
              ...exercise.groupQuestions!.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                final isCorrect = questionResults[index] ?? false;
                
                return _buildQuestionDetail(
                  context,
                  languageCode,
                  index + 1,
                  question,
                  isCorrect,
                );
              })
            else
              _buildSingleQuestionDetail(
                context,
                languageCode,
                exercise,
                questionResults.values.contains(true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDetail(
    BuildContext context,
    String languageCode,
    int questionNumber,
    GroupQuestion question,
    bool isCorrect,
  ) {
    final statusColor = isCorrect 
        ? const Color(0xFF4CAF50) // Green
        : const Color(0xFFF44336); // Red
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
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
            // Header với số câu và kết quả
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCorrect
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFFF44336), const Color(0xFFEF5350)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.question(questionNumber),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${question.point} ${AppLocalizations.of(context)!.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Câu hỏi
            Text(
              _formatQuestionText(question.question),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Chi tiết đáp án theo loại câu hỏi
            if (question.type == ExerciseType.buttonSingleChoice)
              _buildButtonSingleChoiceDetail(context, languageCode, question, questionNumber - 1)
            else if (question.type == ExerciseType.fillBlank)
              _buildFillBlankDetail(context, languageCode, question, questionNumber - 1)
            else if (question.type == ExerciseType.singleChoice)
              _buildSingleChoiceDetail(context, languageCode, question, questionNumber - 1)
            else if (question.type == ExerciseType.multipleChoice)
              _buildMultipleChoiceDetail(context, languageCode, question, questionNumber - 1)
            else if (question.type == ExerciseType.matching)
              _buildMatchingDetail(context, languageCode, question, questionNumber - 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleQuestionDetail(
    BuildContext context,
    String languageCode,
    ExerciseModel exercise,
    bool isCorrect,
  ) {
    final statusColor = isCorrect 
        ? const Color(0xFF4CAF50) // Green
        : const Color(0xFFF44336); // Red
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isCorrect ? AppLocalizations.of(context)!.perfect : AppLocalizations.of(context)!.incorrect,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.points} ${AppLocalizations.of(context)!.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exercise.question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // TODO: Thêm chi tiết đáp án cho single exercise
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSingleChoiceDetail(
    BuildContext context,
    String languageCode,
    GroupQuestion question,
    int questionIndex,
  ) {
    final content = question.content as ButtonSingleChoiceContent;
    final placeholderCount = _countPlaceholders(question.question);
    final userAnswers = <String>[];
    for (int j = 0; j < placeholderCount; j++) {
      final key = questionIndex * 1000 + j;
      final answer = selectedAnswers[key];
      if (answer != null) {
        userAnswers.add(answer);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...List.generate(placeholderCount, (index) {
          final userAnswer = index < userAnswers.length ? userAnswers[index] : null;
          final correctAnswer = index < content.correctAnswers.length 
              ? content.correctAnswers[index] 
              : null;
          final isCorrect = userAnswer == correctAnswer;

          final answerColor = isCorrect 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFF44336);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: answerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: answerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: answerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: answerColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.position(index + 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (userAnswer != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: answerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: answerColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.youChose(userAnswer),
                                  style: TextStyle(
                                    color: answerColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.youHaventChosen,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: const Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.correctAnswer(correctAnswer ?? ''),
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFillBlankDetail(
    BuildContext context,
    String languageCode,
    GroupQuestion question,
    int questionIndex,
  ) {
    final content = question.content as FillBlankContent;
    final regex = RegExp(r'\{(\d+)\}');
    final matches = regex.allMatches(question.question);
    final placeholderIndices = matches.map((m) => int.parse(m.group(1)!)).toList();
    
    final correctAnswersMap = <int, String>{};
    for (final blank in content.blanks) {
      correctAnswersMap[blank.position] = blank.correctAnswer;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...placeholderIndices.asMap().entries.map((entry) {
          final index = entry.key;
          final placeholderIndex = entry.value;
          final userAnswer = fillBlankAnswers[questionIndex * 1000 + placeholderIndex];
          final correctAnswer = correctAnswersMap[placeholderIndex] ?? '';
          final isCorrect = userAnswer?.toLowerCase().trim() == correctAnswer.toLowerCase().trim();

          final answerColor = isCorrect 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFF44336);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: answerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: answerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: answerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: answerColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.position(index + 1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (userAnswer != null && userAnswer.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: answerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: answerColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.youFilled(userAnswer),
                                  style: TextStyle(
                                    color: answerColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.youHaventFilled,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: const Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.correctAnswer('"$correctAnswer"'),
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSingleChoiceDetail(
    BuildContext context,
    String languageCode,
    GroupQuestion question,
    int questionIndex,
  ) {
    final content = question.content as ChoiceContent;
    final userAnswer = groupQuestionAnswers[questionIndex] as String?;
    final isCorrect = content.correctAnswers.contains(userAnswer);

    final answerColor = isCorrect 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFFF44336);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: answerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: answerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: answerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: answerColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userAnswer != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: answerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: answerColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.youChose(userAnswer),
                            style: TextStyle(
                              color: answerColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.youHaventChosen,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.correctAnswer(content.correctAnswers.join(", ")),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceDetail(
    BuildContext context,
    String languageCode,
    GroupQuestion question,
    int questionIndex,
  ) {
    final content = question.content as ChoiceContent;
    final userAnswers = (groupQuestionAnswers[questionIndex] as List<String>?) ?? [];
    final correctAnswers = content.correctAnswers;
    
    final allCorrect = userAnswers.length == correctAnswers.length &&
        userAnswers.every((answer) => correctAnswers.contains(answer)) &&
        correctAnswers.every((answer) => userAnswers.contains(answer));

    final answerColor = allCorrect 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFFF44336);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: answerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: answerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: answerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: answerColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              allCorrect ? Icons.check : Icons.close,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userAnswers.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: answerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          allCorrect ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: answerColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.youChose(userAnswers.join(", ")),
                            style: TextStyle(
                              color: answerColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.youHaventChosen,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.correctAnswer(correctAnswers.join(", ")),
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingDetail(
    BuildContext context,
    String languageCode,
    GroupQuestion question,
    int questionIndex,
  ) {
    final content = question.content as MatchingContent;
    final matchingPairs = groupMatchingPairs[questionIndex] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...content.leftItems.asMap().entries.map((entry) {
          final leftIndex = entry.key;
          final leftItem = entry.value;
          final userRightIndex = matchingPairs[leftIndex];
          
          // Tìm correct pair
          String? correctRightValue;
          String? userRightValue;
          bool isCorrect = false;
          
          for (final correctPair in content.correctPairs) {
            final correctLeftIndex = content.leftItems.indexOf(correctPair.left);
            if (correctLeftIndex == leftIndex) {
              correctRightValue = correctPair.getRight(languageCode);
              if (userRightIndex != null) {
                userRightValue = content.getRightItem(userRightIndex, languageCode);
                isCorrect = correctRightValue == userRightValue;
              }
              break;
            }
          }

          final answerColor = isCorrect 
              ? const Color(0xFF4CAF50) 
              : const Color(0xFFF44336);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: answerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: answerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: answerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: answerColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$leftItem',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (userRightValue != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: answerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: answerColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.youChose(userRightValue),
                                  style: TextStyle(
                                    color: answerColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.youHaventChosen,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (correctRightValue != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: const Color(0xFF4CAF50)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.correctAnswer(correctRightValue),
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  int _countPlaceholders(String question) {
    final regex = RegExp(r'\{(\d+)\}');
    final matches = regex.allMatches(question);
    if (matches.isEmpty) return 0;
    final indices = matches.map((m) => int.parse(m.group(1)!)).toList();
    return indices.isEmpty ? 0 : (indices.reduce((a, b) => a > b ? a : b) + 1);
  }

  /// Format question text: thay thế {0}, {1}, {2}... bằng "..."
  String _formatQuestionText(String question) {
    final regex = RegExp(r'\{(\d+)\}');
    return question.replaceAll(regex, '...');
  }
}
