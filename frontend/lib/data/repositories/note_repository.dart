import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

/// Note item (from notes collection)
/// Note ghi cho story, có thể gắn với chapter cụ thể (khi thêm từ reader)
class StoryNote {
  final String id;
  final String storyId;
  final String note;
  final String? chapterId;
  final double? position;
  final DateTime createdAt;
  final String? storyTitle;
  final String? chapterTitle;

  StoryNote({
    required this.id,
    required this.storyId,
    required this.note,
    this.chapterId,
    this.position,
    required this.createdAt,
    this.storyTitle,
    this.chapterTitle,
  });

  factory StoryNote.fromRecord(RecordModel r) {
    String? storyTitle;
    String? chapterTitle;
    // expand = Map<String, List<RecordModel>>, mỗi relation là List
    try {
      final storyList = r.get<List<RecordModel>?>('expand.story');
      if (storyList != null && storyList.isNotEmpty) {
        storyTitle = storyList.first.getStringValue('title');
      }
    } catch (_) {}
    try {
      final chapterList = r.get<List<RecordModel>?>('expand.chapter');
      if (chapterList != null && chapterList.isNotEmpty) {
        chapterTitle = chapterList.first.getStringValue('title');
      }
    } catch (_) {}
    // Fallback: raw data (API có thể trả object thay vì list)
    if (storyTitle == null || chapterTitle == null) {
      final exp = r.data['expand'];
      if (exp is Map) {
        if (storyTitle == null) {
          final s = exp['story'];
          if (s is Map) {
            storyTitle = s['title']?.toString();
          } else if (s is RecordModel) {
            storyTitle = s.getStringValue('title');
          }
        }
        if (chapterTitle == null) {
          final c = exp['chapter'];
          if (c is Map) {
            chapterTitle = c['title']?.toString();
          } else if (c is RecordModel) {
            chapterTitle = c.getStringValue('title');
          }
        }
      }
    }
    return StoryNote(
      id: r.id,
      storyId: r.getStringValue('story'),
      note: r.getStringValue('note'),
      chapterId: r.data['chapter']?.toString(),
      position: (r.data['position'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(r.getStringValue('created')) ?? DateTime.now(),
      storyTitle: storyTitle,
      chapterTitle: chapterTitle,
    );
  }
}

/// Repository for story notes (notes collection)
@injectable
class NoteRepository {
  NoteRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get all notes for current user
  Future<List<StoryNote>> getNotes() async {
    try {
      if (!_pbService.isAuthenticated) return [];

      final userId = _pbService.currentUser?.id;
      if (userId == null) return [];

      final result = await _pb.collection('notes').getFullList(
            filter: 'user="$userId"',
            sort: '-created',
            expand: 'story,chapter',
          );
      return result.map((r) => StoryNote.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('NoteRepository.getNotes error: $e');
      return [];
    }
  }

  /// Get notes for a specific story
  Future<List<StoryNote>> getNotesByStory(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return [];

      final userId = _pbService.currentUser?.id;
      if (userId == null) return [];

      final result = await _pb.collection('notes').getFullList(
            filter: 'user="$userId" && story="$storyId"',
            sort: '-created',
          );
      return result.map((r) => StoryNote.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('NoteRepository.getNotesByStory error: $e');
      return [];
    }
  }

  /// Story note: 1 note per story (upsert). Dùng từ story detail / bookmark.
  Future<StoryNote?> addStoryNote({
    required String storyId,
    required String note,
  }) async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final existing = await _pb.collection('notes').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 50,
          );
      // Story note = không có chapter (chapterId null/empty)
      final storyNoteRecord = existing.items
          .where((r) =>
              r.data['chapter'] == null ||
              r.getStringValue('chapter').isEmpty)
          .firstOrNull;

      final body = <String, dynamic>{
        'user': userId,
        'story': storyId,
        'note': note.trim(),
      };

      RecordModel record;
      if (storyNoteRecord != null) {
        record = await _pb.collection('notes').update(
              storyNoteRecord.id,
              body: body,
            );
      } else {
        record = await _pb.collection('notes').create(body: body);
      }
      return StoryNote.fromRecord(record);
    } catch (e) {
      debugPrint('NoteRepository.addStoryNote error: $e');
      return null;
    }
  }

  /// Chapter note: 1 note per chapter (upsert). Dùng từ reader.
  Future<StoryNote?> addChapterNote({
    required String storyId,
    required String chapterId,
    required String note,
    double? position,
  }) async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final existing = await _pb.collection('notes').getList(
            filter: 'user="$userId" && chapter="$chapterId"',
            perPage: 1,
          );

      final body = <String, dynamic>{
        'user': userId,
        'story': storyId,
        'chapter': chapterId,
        'note': note.trim(),
      };
      if (position != null) body['position'] = position;

      RecordModel record;
      if (existing.items.isNotEmpty) {
        record = await _pb.collection('notes').update(
              existing.items.first.id,
              body: body,
            );
      } else {
        record = await _pb.collection('notes').create(body: body);
      }
      return StoryNote.fromRecord(record);
    } catch (e) {
      debugPrint('NoteRepository.addChapterNote error: $e');
      return null;
    }
  }

  /// Lấy chapter note (1 note per chapter)
  Future<StoryNote?> getChapterNote(String chapterId) async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('notes').getList(
            filter: 'user="$userId" && chapter="$chapterId"',
            perPage: 1,
          );
      if (result.items.isEmpty) return null;
      return StoryNote.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('NoteRepository.getChapterNote error: $e');
      return null;
    }
  }

  /// Lấy story note (1 note tổng cho story, không có chapter)
  Future<StoryNote?> getStoryNote(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return null;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('notes').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 50,
          );
      final storyNote = result.items
          .where((r) =>
              r.data['chapter'] == null ||
              r.getStringValue('chapter').isEmpty)
          .firstOrNull;
      if (storyNote == null) return null;
      return StoryNote.fromRecord(storyNote);
    } catch (e) {
      debugPrint('NoteRepository.getStoryNote error: $e');
      return null;
    }
  }

  /// Update note
  Future<bool> updateNote(String noteId, String note) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      await _pb.collection('notes').update(
            noteId,
            body: {'note': note.trim()},
          );
      return true;
    } catch (e) {
      debugPrint('NoteRepository.updateNote error: $e');
      return false;
    }
  }

  /// Delete note
  Future<bool> deleteNote(String noteId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      await _pb.collection('notes').delete(noteId);
      return true;
    } catch (e) {
      debugPrint('NoteRepository.deleteNote error: $e');
      return false;
    }
  }
}
