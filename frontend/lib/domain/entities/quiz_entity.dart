import 'package:equatable/equatable.dart';

import '../../data/models/quiz.dart';

/// Quiz Entity - Domain layer representation of a quiz
/// 
/// This is a clean architecture entity that represents a quiz question
/// in the domain layer, independent of data sources.
class QuizEntity extends Equatable {
  final String id;
  final String? storyId;
  final String? chapterId;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final bool isPublished;

  const QuizEntity({
    required this.id,
    this.storyId,
    this.chapterId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.isPublished,
  });

  /// Convert from data model to domain entity
  factory QuizEntity.fromModel(Quiz model) {
    return QuizEntity(
      id: model.id,
      storyId: model.storyId,
      chapterId: model.chapterId,
      question: model.question,
      options: model.options,
      correctAnswer: model.correctAnswer,
      explanation: model.explanation,
      isPublished: model.isPublished,
    );
  }

  /// Convert to data model
  Quiz toModel() {
    return Quiz(
      id: id,
      storyId: storyId,
      chapterId: chapterId,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: explanation,
      isPublished: isPublished,
      created: DateTime.now(),
      updated: DateTime.now(),
    );
  }

  /// Check if the given answer index is correct
  bool isCorrectAnswer(int answerIndex) {
    return answerIndex == correctAnswer;
  }

  /// Get the correct answer text
  String get correctAnswerText {
    if (correctAnswer >= 0 && correctAnswer < options.length) {
      return options[correctAnswer];
    }
    return '';
  }

  /// Get total number of options
  int get optionCount => options.length;

  /// Check if this quiz has an explanation
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    storyId,
    chapterId,
    question,
    options,
    correctAnswer,
    explanation,
    isPublished,
  ];

  QuizEntity copyWith({
    String? id,
    String? storyId,
    String? chapterId,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    bool? isPublished,
  }) {
    return QuizEntity(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      chapterId: chapterId ?? this.chapterId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

/// Extension to convert list of Quiz models to QuizEntity list
extension QuizListExtension on List<Quiz> {
  List<QuizEntity> toEntities() {
    return map((quiz) => QuizEntity.fromModel(quiz)).toList();
  }
}
