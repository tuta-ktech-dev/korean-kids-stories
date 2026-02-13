import 'package:pocketbase/pocketbase.dart';

/// Quiz model for quiz questions
class Quiz {
  final String id;
  final String? storyId;
  final String? chapterId;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final bool isPublished;
  final DateTime created;
  final DateTime updated;

  Quiz({
    required this.id,
    this.storyId,
    this.chapterId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.isPublished,
    required this.created,
    required this.updated,
  });

  factory Quiz.fromRecord(RecordModel record) {
    return Quiz(
      id: record.id,
      storyId: record.getStringValue('story'),
      chapterId: record.getStringValue('chapter'),
      question: record.getStringValue('question'),
      options: record.getListValue<String>('options'),
      correctAnswer: record.getIntValue('correct_answer'),
      explanation: record.data['explanation'] as String?,
      isPublished: record.getBoolValue('is_published'),
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      storyId: json['story'] as String?,
      chapterId: json['chapter'] as String?,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctAnswer: json['correct_answer'] as int,
      explanation: json['explanation'] as String?,
      isPublished: json['is_published'] as bool? ?? true,
      created: DateTime.tryParse(json['created'] as String? ?? '') ?? DateTime.now(),
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story': storyId,
      'chapter': chapterId,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'is_published': isPublished,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  Quiz copyWith({
    String? id,
    String? storyId,
    String? chapterId,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    bool? isPublished,
    DateTime? created,
    DateTime? updated,
  }) {
    return Quiz(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      chapterId: chapterId ?? this.chapterId,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      isPublished: isPublished ?? this.isPublished,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}

/// Extension to safely get values from RecordModel
extension RecordModelExtension on RecordModel {
  String getStringValue(String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  int getIntValue(String key) {
    final value = data[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool getBoolValue(String key) {
    final value = data[key];
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  List<T> getListValue<T>(String key) {
    final value = data[key];
    if (value == null) return [];
    if (value is List) {
      return value.whereType<T>().toList();
    }
    return [];
  }
}
