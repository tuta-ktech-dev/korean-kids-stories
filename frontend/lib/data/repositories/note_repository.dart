import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import 'local_note_repository.dart';

/// Note item (from notes collection or local)
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

/// Repository for story notes. Kids app: always uses local storage.
@injectable
class NoteRepository {
  NoteRepository(this._localRepo);
  final LocalNoteRepository _localRepo;

  Future<List<StoryNote>> getNotes() async {
    return _localRepo.getNotes();
  }

  Future<List<StoryNote>> getNotesByStory(String storyId) async {
    return _localRepo.getNotesByStory(storyId);
  }

  Future<StoryNote?> addStoryNote({
    required String storyId,
    required String note,
  }) async {
    return _localRepo.addStoryNote(storyId: storyId, note: note);
  }

  Future<StoryNote?> addChapterNote({
    required String storyId,
    required String chapterId,
    required String note,
    double? position,
  }) async {
    return _localRepo.addChapterNote(
      storyId: storyId,
      chapterId: chapterId,
      note: note,
      position: position,
    );
  }

  Future<StoryNote?> getChapterNote(String chapterId) async {
    return _localRepo.getChapterNote(chapterId);
  }

  Future<StoryNote?> getStoryNote(String storyId) async {
    return _localRepo.getStoryNote(storyId);
  }

  Future<bool> updateNote(String noteId, String note) async {
    return _localRepo.updateNote(noteId, note);
  }

  Future<bool> deleteNote(String noteId) async {
    return _localRepo.deleteNote(noteId);
  }
}
