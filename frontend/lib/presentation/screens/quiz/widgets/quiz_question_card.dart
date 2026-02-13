import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/quiz.dart';
import 'answer_option.dart';

/// Widget to display a quiz question with its answer options
class QuizQuestionCard extends StatelessWidget {
  final Quiz quiz;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool isAnswerRevealed;
  final bool? isCorrect;
  final ({int questionIndex, int answerIndex, bool isCorrect})? highlightAnswer;
  final Function(int answerIndex) onSelectAnswer;

  const QuizQuestionCard({
    super.key,
    required this.quiz,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedAnswer,
    required this.isAnswerRevealed,
    this.isCorrect,
    this.highlightAnswer,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primaryPink,
                AppTheme.primaryCoral,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Question text
              Text(
                quiz.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Answer options
        ...List.generate(
          quiz.options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnswerOption(
              optionLetter: String.fromCharCode(65 + index), // A, B, C, D
              optionText: quiz.options[index],
              isSelected: selectedAnswer == index,
              isCorrectAnswer: quiz.correctAnswer == index,
              isRevealed: isAnswerRevealed,
              isHighlighted: highlightAnswer?.answerIndex == index,
              showResult: isAnswerRevealed && (selectedAnswer == index || quiz.correctAnswer == index),
              onTap: isAnswerRevealed ? null : () => onSelectAnswer(index),
            ),
          ),
        ),

        // Explanation section (shown after answering)
        if (isAnswerRevealed && quiz.explanation != null && quiz.explanation!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildExplanation(context),
        ],

        // Feedback message
        if (isAnswerRevealed) ...[
          const SizedBox(height: 16),
          _buildFeedback(context),
        ],
      ],
    );
  }

  Widget _buildExplanation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryMint.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryMint.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quiz.explanation!,
            style: AppTheme.bodyMedium(context).copyWith(
              color: AppTheme.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(BuildContext context) {
    final isRight = isCorrect ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRight
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isRight
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.error.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isRight ? Icons.check_circle : Icons.cancel,
              color: isRight ? colorScheme.primary : colorScheme.error,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRight ? 'Correct!' : 'Wrong answer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isRight ? colorScheme.primary : colorScheme.error,
                  ),
                ),
                if (!isRight)
                  Text(
                    'The correct answer is: ${quiz.options[quiz.correctAnswer]}',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
