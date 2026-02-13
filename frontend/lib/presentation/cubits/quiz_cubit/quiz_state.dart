import 'package:equatable/equatable.dart';

import '../../../data/models/quiz.dart';

/// Base class for quiz states
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any quiz is loaded
class QuizInitial extends QuizState {
  const QuizInitial();
}

/// Loading state while fetching quizzes
class QuizLoading extends QuizState {
  const QuizLoading();
}

/// State when quizzes are loaded and ready
class QuizLoaded extends QuizState {
  final List<Quiz> quizzes;
  final int currentQuestionIndex;
  final List<int?> selectedAnswers; // null = chưa chọn, -1 = đang loading
  final List<bool?> answerResults; // null = chưa trả lờ
  final bool isAnswerRevealed;
  final int score;

  const QuizLoaded({
    required this.quizzes,
    this.currentQuestionIndex = 0,
    required this.selectedAnswers,
    required this.answerResults,
    this.isAnswerRevealed = false,
    this.score = 0,
  });

  /// Get current quiz question
  Quiz? get currentQuiz {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < quizzes.length) {
      return quizzes[currentQuestionIndex];
    }
    return null;
  }

  /// Get total number of questions
  int get totalQuestions => quizzes.length;

  /// Get current question number (1-based)
  int get currentQuestionNumber => currentQuestionIndex + 1;

  /// Get progress (0.0 to 1.0)
  double get progress {
    if (quizzes.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / quizzes.length;
  }

  /// Check if this is the last question
  bool get isLastQuestion => currentQuestionIndex >= quizzes.length - 1;

  /// Check if this is the first question
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Check if current question has been answered
  bool get hasAnsweredCurrent {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < selectedAnswers.length) {
      return selectedAnswers[currentQuestionIndex] != null;
    }
    return false;
  }

  /// Get selected answer for current question
  int? get currentSelectedAnswer {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < selectedAnswers.length) {
      return selectedAnswers[currentQuestionIndex];
    }
    return null;
  }

  /// Check if current answer is correct
  bool? get isCurrentAnswerCorrect {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < answerResults.length) {
      return answerResults[currentQuestionIndex];
    }
    return null;
  }

  /// Get number of correct answers
  int get correctCount {
    return answerResults.where((result) => result == true).length;
  }

  /// Get number of wrong answers
  int get wrongCount {
    return answerResults.where((result) => result == false).length;
  }

  /// Get number of unanswered questions
  int get unansweredCount {
    return selectedAnswers.where((answer) => answer == null).length;
  }

  /// Calculate percentage score (0-100)
  int get percentageScore {
    if (quizzes.isEmpty) return 0;
    return ((correctCount / quizzes.length) * 100).round();
  }

  /// Get star rating based on score
  /// 3 stars: >= 80%, 2 stars: >= 60%, 1 star: >= 40%, 0 stars: < 40%
  int get starRating {
    final percentage = percentageScore;
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
  }

  QuizLoaded copyWith({
    List<Quiz>? quizzes,
    int? currentQuestionIndex,
    List<int?>? selectedAnswers,
    List<bool?>? answerResults,
    bool? isAnswerRevealed,
    int? score,
  }) {
    return QuizLoaded(
      quizzes: quizzes ?? this.quizzes,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      answerResults: answerResults ?? this.answerResults,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [
    quizzes,
    currentQuestionIndex,
    selectedAnswers,
    answerResults,
    isAnswerRevealed,
    score,
  ];
}

/// State when an answer has been selected (for animation/feedback)
class QuizAnswerSelected extends QuizState {
  final QuizLoaded currentState;
  final int questionIndex;
  final int answerIndex;
  final bool isCorrect;

  const QuizAnswerSelected({
    required this.currentState,
    required this.questionIndex,
    required this.answerIndex,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [currentState, questionIndex, answerIndex, isCorrect];
}

/// State when quiz is completed
class QuizCompleted extends QuizState {
  final List<Quiz> quizzes;
  final List<int?> selectedAnswers;
  final List<bool?> answerResults;
  final int score;

  const QuizCompleted({
    required this.quizzes,
    required this.selectedAnswers,
    required this.answerResults,
    required this.score,
  });

  /// Get total number of questions
  int get totalQuestions => quizzes.length;

  /// Get number of correct answers
  int get correctCount {
    return answerResults.where((result) => result == true).length;
  }

  /// Get number of wrong answers
  int get wrongCount {
    return answerResults.where((result) => result == false).length;
  }

  /// Calculate percentage score (0-100)
  int get percentageScore {
    if (quizzes.isEmpty) return 0;
    return ((correctCount / quizzes.length) * 100).round();
  }

  /// Get star rating based on score
  int get starRating {
    final percentage = percentageScore;
    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
  }

  /// Get feedback message based on score
  String getFeedbackMessage() {
    final percentage = percentageScore;
    if (percentage >= 90) return '🎉 Excellent! You\'re amazing!';
    if (percentage >= 80) return '👏 Great job! Well done!';
    if (percentage >= 60) return '👍 Good work! Keep it up!';
    if (percentage >= 40) return '💪 Nice try! Practice more!';
    return '📚 Keep learning! You can do it!';
  }

  @override
  List<Object?> get props => [quizzes, selectedAnswers, answerResults, score];
}

/// Error state when quiz loading fails
class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
