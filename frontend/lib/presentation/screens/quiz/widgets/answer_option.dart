import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Widget for a single answer option in a quiz
/// 
/// Handles different states:
/// - Normal: Default state, not selected
/// - Selected: User has selected this answer
/// - Correct: This is the correct answer (shown after revealing)
/// - Wrong: This is the wrong answer (shown after revealing)
class AnswerOption extends StatelessWidget {
  final String optionLetter;
  final String optionText;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool isRevealed;
  final bool isHighlighted;
  final bool showResult;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.optionLetter,
    required this.optionText,
    this.isSelected = false,
    this.isCorrectAnswer = false,
    this.isRevealed = false,
    this.isHighlighted = false,
    this.showResult = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine the state and colors
    final state = _getState();
    final colors = _getColors(context, state, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: colors.borderColor,
                width: isSelected || isHighlighted || showResult ? 3 : 2,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: colors.borderColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPink.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
            ),
            child: Row(
              children: [
                // Option letter circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.letterBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.letterBorderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.letterTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Option text
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: colors.textColor,
                      height: 1.4,
                    ),
                  ),
                ),
                // Status icon
                if (showResult || isHighlighted)
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      state == AnswerOptionState.correct
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: state == AnswerOptionState.correct
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Determine the current state of the option
  AnswerOptionState _getState() {
    if (!isRevealed && !isHighlighted) {
      return isSelected ? AnswerOptionState.selected : AnswerOptionState.normal;
    }

    if (isCorrectAnswer) {
      return AnswerOptionState.correct;
    }

    if (isSelected && !isCorrectAnswer) {
      return AnswerOptionState.wrong;
    }

    if (isHighlighted && !isCorrectAnswer) {
      return AnswerOptionState.wrong;
    }

    return AnswerOptionState.normal;
  }

  /// Get colors based on state
  _OptionColors _getColors(BuildContext context, AnswerOptionState state, bool isDark) {
    switch (state) {
      case AnswerOptionState.selected:
        return _OptionColors(
          backgroundColor: AppTheme.primaryPink.withValues(alpha: 0.1),
          borderColor: AppTheme.primaryPink,
          letterBackgroundColor: AppTheme.primaryPink,
          letterBorderColor: AppTheme.primaryPink,
          letterTextColor: Colors.white,
          textColor: isDark ? AppTheme.darkTextLight : AppTheme.textDark,
        );

      case AnswerOptionState.correct:
        return _OptionColors(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderColor: Theme.of(context).colorScheme.primary,
          letterBackgroundColor: Theme.of(context).colorScheme.primary,
          letterBorderColor: Theme.of(context).colorScheme.primary,
          letterTextColor: Colors.white,
          textColor: Theme.of(context).colorScheme.primary,
        );

      case AnswerOptionState.wrong:
        return _OptionColors(
          backgroundColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
          borderColor: Theme.of(context).colorScheme.error,
          letterBackgroundColor: Theme.of(context).colorScheme.error,
          letterBorderColor: Theme.of(context).colorScheme.error,
          letterTextColor: Colors.white,
          textColor: Theme.of(context).colorScheme.error,
        );

      case AnswerOptionState.normal:
        return _OptionColors(
          backgroundColor: isDark ? AppTheme.darkCard : AppTheme.surfaceColor(context),
          borderColor: isDark
              ? AppTheme.darkTextMuted.withValues(alpha: 0.3)
              : AppTheme.textMutedColor(context).withValues(alpha: 0.3),
          letterBackgroundColor: isDark
              ? AppTheme.darkSurface
              : AppTheme.surfaceColor(context),
          letterBorderColor: isDark
              ? AppTheme.darkTextMuted.withValues(alpha: 0.5)
              : AppTheme.textMutedColor(context).withValues(alpha: 0.5),
          letterTextColor: isDark
              ? AppTheme.darkTextLight
              : AppTheme.textColor(context),
          textColor: isDark
              ? AppTheme.darkTextLight
              : AppTheme.textColor(context),
        );
    }
  }
}

/// Enum for answer option states
enum AnswerOptionState {
  normal,
  selected,
  correct,
  wrong,
}

/// Helper class to hold color values
class _OptionColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color letterBackgroundColor;
  final Color letterBorderColor;
  final Color letterTextColor;
  final Color textColor;

  const _OptionColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.letterBackgroundColor,
    required this.letterBorderColor,
    required this.letterTextColor,
    required this.textColor,
  });
}
