import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/quiz.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'quiz_state.dart';
export 'quiz_state.dart';

/// Cubit for managing quiz state and logic
/// 
/// Handles:
/// - Loading quizzes by chapter or story
/// - Selecting answers
/// - Navigating between questions
/// - Calculating scores
/// - Resetting quiz
@injectable
class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required QuizRepository quizRepository,
  })  : _quizRepository = quizRepository,
        super(const QuizInitial());

  final QuizRepository _quizRepository;

  /// Load quizzes for a specific chapter
  /// 
  /// [chapterId] - The chapter ID to load quizzes for
  Future<void> loadQuizzesByChapter(String chapterId) async {
    emit(const QuizLoading());

    try {
      final quizzes = await _quizRepository.getQuizzesByChapter(chapterId);
      _initializeQuiz(quizzes);
    } catch (e) {
      debugPrint('[QuizCubit] Error loading quizzes by chapter: $e');
      emit(const QuizError('Failed to load quizzes'));
    }
  }

  /// Load quizzes for a specific story
  /// 
  /// [storyId] - The story ID to load quizzes for
  Future<void> loadQuizzesByStory(String storyId) async {
    emit(const QuizLoading());

    try {
      final quizzes = await _quizRepository.getQuizzesByStory(storyId);
      _initializeQuiz(quizzes);
    } catch (e) {
      debugPrint('[QuizCubit] Error loading quizzes by story: $e');
      emit(const QuizError('Failed to load quizzes'));
    }
  }

  /// Load all quizzes for a story (both story-level and chapter-level)
  /// 
  /// [storyId] - The story ID to load all quizzes for
  Future<void> loadAllQuizzesForStory(String storyId) async {
    emit(const QuizLoading());

    try {
      final quizzes = await _quizRepository.getAllQuizzesForStory(storyId);
      _initializeQuiz(quizzes);
    } catch (e) {
      debugPrint('[QuizCubit] Error loading all quizzes: $e');
      emit(const QuizError('Failed to load quizzes'));
    }
  }

  /// Initialize quiz state with loaded quizzes
  void _initializeQuiz(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      emit(const QuizError('No quizzes available'));
      return;
    }

    emit(QuizLoaded(
      quizzes: quizzes,
      selectedAnswers: List.filled(quizzes.length, null),
      answerResults: List.filled(quizzes.length, null),
    ));
  }

  /// Select an answer for the current question
  /// 
  /// [questionIndex] - The index of the question being answered
  /// [answerIndex] - The index of the selected answer (0-3)
  void selectAnswer(int questionIndex, int answerIndex) {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    // Prevent changing answer if already answered
    if (currentState.selectedAnswers[questionIndex] != null) return;

    // Validate indices
    if (questionIndex < 0 || questionIndex >= currentState.quizzes.length) return;

    final quiz = currentState.quizzes[questionIndex];
    if (answerIndex < 0 || answerIndex >= quiz.options.length) return;
    final isCorrect = answerIndex == quiz.correctAnswer;

    // Update selected answers and results
    final newSelectedAnswers = List<int?>.from(currentState.selectedAnswers);
    final newAnswerResults = List<bool?>.from(currentState.answerResults);

    newSelectedAnswers[questionIndex] = answerIndex;
    newAnswerResults[questionIndex] = isCorrect;

    // Calculate new score
    final newScore = isCorrect ? currentState.score + 1 : currentState.score;

    emit(QuizAnswerSelected(
      currentState: currentState,
      questionIndex: questionIndex,
      answerIndex: answerIndex,
      isCorrect: isCorrect,
    ));

    // Small delay for feedback animation before transitioning to answered state
    Future.delayed(const Duration(milliseconds: 800), () {
      if (isClosed) return;
      emit(currentState.copyWith(
        selectedAnswers: newSelectedAnswers,
        answerResults: newAnswerResults,
        isAnswerRevealed: true,
        score: newScore,
      ));
    });
  }

  /// Move to the next question
  void nextQuestion() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    if (currentState.isLastQuestion) {
      // Quiz completed
      _completeQuiz(currentState);
    } else {
      // Move to next question
      emit(currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        isAnswerRevealed: false,
      ));
    }
  }

  /// Move to the previous question
  void previousQuestion() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    if (currentState.isFirstQuestion) return;

    emit(currentState.copyWith(
      currentQuestionIndex: currentState.currentQuestionIndex - 1,
      isAnswerRevealed: true, // Keep previous answers revealed
    ));
  }

  /// Go to a specific question index
  void goToQuestion(int index) {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    if (index < 0 || index >= currentState.quizzes.length) return;

    emit(currentState.copyWith(
      currentQuestionIndex: index,
      isAnswerRevealed: currentState.selectedAnswers[index] != null,
    ));
  }

  /// Complete the quiz and calculate final score
  void _completeQuiz(QuizLoaded currentState) {
    emit(QuizCompleted(
      quizzes: currentState.quizzes,
      selectedAnswers: currentState.selectedAnswers,
      answerResults: currentState.answerResults,
      score: currentState.score,
    ));
  }

  /// Submit quiz (mark as completed)
  void submitQuiz() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    _completeQuiz(currentState);
  }

  /// Reset the quiz to start over
  void resetQuiz() {
    final currentState = state;
    
    List<Quiz> quizzes = [];
    if (currentState is QuizLoaded) {
      quizzes = currentState.quizzes;
    } else if (currentState is QuizCompleted) {
      quizzes = currentState.quizzes;
    } else {
      emit(const QuizInitial());
      return;
    }

    if (quizzes.isEmpty) {
      emit(const QuizError('No quizzes available'));
      return;
    }

    emit(QuizLoaded(
      quizzes: quizzes,
      currentQuestionIndex: 0,
      selectedAnswers: List.filled(quizzes.length, null),
      answerResults: List.filled(quizzes.length, null),
      isAnswerRevealed: false,
      score: 0,
    ));
  }

  /// Skip to end and show results
  void skipToResults() {
    final currentState = state;
    if (currentState is! QuizLoaded) return;

    _completeQuiz(currentState);
  }
}
