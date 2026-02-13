import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/reader_auto_play.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../injection.dart';
import '../../cubits/quiz_cubit/quiz_cubit.dart';
import '../../../utils/extensions/context_extension.dart';
import 'widgets/quiz_question_card.dart';
import 'widgets/quiz_result.dart';

@RoutePage()
class QuizScreen extends StatelessWidget {
  final String? storyId;
  final String? chapterId;
  /// Khi có giá trị: sau khi xong quiz, "Tiếp tục" → chuyển sang truyện tiếp theo
  final String? nextStoryId;
  final String? nextChapterId;

  const QuizScreen({
    super.key,
    this.storyId,
    this.chapterId,
    this.nextStoryId,
    this.nextChapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(
        quizRepository: getIt<QuizRepository>(),
      ),
      child: QuizView(
        storyId: storyId,
        chapterId: chapterId,
        nextStoryId: nextStoryId,
        nextChapterId: nextChapterId,
      ),
    );
  }
}

class QuizView extends StatefulWidget {
  final String? storyId;
  final String? chapterId;
  final String? nextStoryId;
  final String? nextChapterId;

  const QuizView({
    super.key,
    this.storyId,
    this.chapterId,
    this.nextStoryId,
    this.nextChapterId,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  @override
  void initState() {
    super.initState();
    // Load quizzes based on provided ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chapterId != null) {
        context.read<QuizCubit>().loadQuizzesByChapter(widget.chapterId!);
      } else if (widget.storyId != null) {
        context.read<QuizCubit>().loadQuizzesByStory(widget.storyId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          context.l10n.doQuiz,
          style: AppTheme.headingMedium(context),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<QuizCubit, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            QuizInitial() => const _LoadingView(),
            QuizLoading() => const _LoadingView(),
            QuizError() => _ErrorView(
                message: state.message,
                onRetry: () => _retryLoading(),
              ),
            QuizLoaded() => _QuizContentView(state: state),
            QuizAnswerSelected() => _QuizContentView(
                state: state.currentState,
                highlightAnswer: (
                  questionIndex: state.questionIndex,
                  answerIndex: state.answerIndex,
                  isCorrect: state.isCorrect,
                ),
              ),
            QuizCompleted() => QuizResultView(
                state: state,
                onRetry: () => context.read<QuizCubit>().resetQuiz(),
                onClose: () => _handleQuizClose(context),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  void _retryLoading() {
    if (widget.chapterId != null) {
      context.read<QuizCubit>().loadQuizzesByChapter(widget.chapterId!);
    } else if (widget.storyId != null) {
      context.read<QuizCubit>().loadQuizzesByStory(widget.storyId!);
    }
  }

  void _handleQuizClose(BuildContext context) {
    if (widget.nextStoryId != null && widget.nextChapterId != null) {
      ReaderAutoPlay.request();
      context.router.replace(
        ReaderRoute(
          storyId: widget.nextStoryId!,
          chapterId: widget.nextChapterId!,
        ),
      );
    } else {
      context.router.maybePop();
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading quiz...'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizContentView extends StatelessWidget {
  final QuizLoaded state;
  final ({int questionIndex, int answerIndex, bool isCorrect})? highlightAnswer;

  const _QuizContentView({
    required this.state,
    this.highlightAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = state.currentQuiz;
    if (quiz == null) {
      return const Center(child: Text('No questions available'));
    }

    return Column(
      children: [
        // Progress bar
        _ProgressBar(
          current: state.currentQuestionNumber,
          total: state.totalQuestions,
          progress: state.progress,
        ),
        
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: QuizQuestionCard(
              quiz: quiz,
              questionNumber: state.currentQuestionNumber,
              totalQuestions: state.totalQuestions,
              selectedAnswer: state.currentSelectedAnswer,
              isAnswerRevealed: state.isAnswerRevealed,
              isCorrect: state.isCurrentAnswerCorrect,
              highlightAnswer: highlightAnswer?.questionIndex == state.currentQuestionIndex
                  ? highlightAnswer
                  : null,
              onSelectAnswer: (answerIndex) {
                context.read<QuizCubit>().selectAnswer(
                  state.currentQuestionIndex,
                  answerIndex,
                );
              },
            ),
          ),
        ),

        // Bottom navigation
        _BottomNavigation(
          state: state,
          onNext: () => context.read<QuizCubit>().nextQuestion(),
          onPrevious: state.isFirstQuestion
              ? null
              : () => context.read<QuizCubit>().previousQuestion(),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double progress;

  const _ProgressBar({
    required this.current,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: AppTheme.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTheme.caption(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.primaryMint.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryPink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final QuizLoaded state;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const _BottomNavigation({
    required this.state,
    required this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswered = state.hasAnsweredCurrent;
    final isLastQuestion = state.isLastQuestion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            if (onPrevious != null)
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                ),
              )
            else
              const Spacer(flex: 1),

            const SizedBox(width: 16),

            // Next/Submit button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: hasAnswered ? onNext : null,
                icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                label: Text(
                  isLastQuestion ? 'Submit' : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: hasAnswered
                      ? AppTheme.primaryPink
                      : AppTheme.surfaceColor(context),
                  foregroundColor: hasAnswered ? Colors.white : AppTheme.textMutedColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
