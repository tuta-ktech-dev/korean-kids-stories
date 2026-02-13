import 'package:injectable/injectable.dart';

import '../models/quiz.dart';
import '../services/pocketbase_service.dart';

/// Repository for quiz-related operations
/// 
/// Abstracts data access and provides a clean API for the presentation layer
@injectable
class QuizRepository {
  QuizRepository(this._pbService);
  final PocketbaseService _pbService;

  /// Initialize the repository
  Future<void> initialize() async {
    await _pbService.initialize();
  }

  /// Get quizzes by chapter ID
  /// 
  /// [chapterId] - The chapter ID to fetch quizzes for
  /// 
  /// Returns list of published quizzes for the chapter
  Future<List<Quiz>> getQuizzesByChapter(String chapterId) async {
    try {
      final pb = _pbService.pb;
      final records = await pb.collection('quizzes').getFullList(
        filter: "chapter = '$chapterId' && is_published = true",
        sort: 'created',
      );
      return records.map((record) => Quiz.fromRecord(record)).toList();
    } catch (e) {
      throw PocketbaseException('Failed to load quizzes: $e');
    }
  }

  /// Get quizzes by story ID
  /// 
  /// [storyId] - The story ID to fetch quizzes for
  /// Use this when quizzes are associated with story (not specific chapter)
  /// 
  /// Returns list of published quizzes for the story
  Future<List<Quiz>> getQuizzesByStory(String storyId) async {
    try {
      final pb = _pbService.pb;
      final records = await pb.collection('quizzes').getFullList(
        filter: "story = '$storyId' && chapter = '' && is_published = true",
        sort: 'created',
      );
      return records.map((record) => Quiz.fromRecord(record)).toList();
    } catch (e) {
      throw PocketbaseException('Failed to load quizzes: $e');
    }
  }

  /// Get all quizzes for a story including both story-level and chapter-level
  /// 
  /// [storyId] - The story ID to fetch all quizzes for
  /// 
  /// Returns list of all published quizzes for the story
  Future<List<Quiz>> getAllQuizzesForStory(String storyId) async {
    try {
      final pb = _pbService.pb;
      final records = await pb.collection('quizzes').getFullList(
        filter: "story = '$storyId' && is_published = true",
        sort: 'created',
      );
      return records.map((record) => Quiz.fromRecord(record)).toList();
    } catch (e) {
      throw PocketbaseException('Failed to load quizzes: $e');
    }
  }

  /// Get a single quiz by ID
  /// 
  /// Returns null if quiz not found
  Future<Quiz?> getQuiz(String id) async {
    try {
      final pb = _pbService.pb;
      final record = await pb.collection('quizzes').getOne(id);
      return Quiz.fromRecord(record);
    } catch (e) {
      return null;
    }
  }

  /// Check if a story has any quizzes
  /// 
  /// [storyId] - The story ID to check
  /// 
  /// Returns true if the story has at least one published quiz
  Future<bool> hasQuiz(String storyId) async {
    try {
      final pb = _pbService.pb;
      final result = await pb.collection('quizzes').getList(
        filter: "story = '$storyId' && is_published = true",
        page: 1,
        perPage: 1,
      );
      return result.items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if a chapter has any quizzes
  /// 
  /// [chapterId] - The chapter ID to check
  /// 
  /// Returns true if the chapter has at least one published quiz
  Future<bool> chapterHasQuiz(String chapterId) async {
    try {
      final pb = _pbService.pb;
      final result = await pb.collection('quizzes').getList(
        filter: "chapter = '$chapterId' && is_published = true",
        page: 1,
        perPage: 1,
      );
      return result.items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Exception thrown when PocketBase operations fail
class PocketbaseException implements Exception {
  final String message;
  
  PocketbaseException(this.message);
  
  @override
  String toString() => message;
}
