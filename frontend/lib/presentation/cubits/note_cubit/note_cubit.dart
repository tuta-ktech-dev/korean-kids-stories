import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/note_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'note_state.dart';
export 'note_state.dart';

@lazySingleton
class NoteCubit extends Cubit<NoteState> {
  NoteCubit({
    NoteRepository? noteRepository,
    PocketbaseService? pocketbaseService,
  })  : _repo = noteRepository ?? getIt<NoteRepository>(),
        _pbService = pocketbaseService ?? getIt<PocketbaseService>(),
        super(const NoteInitial());

  final NoteRepository _repo;
  final PocketbaseService _pbService;

  /// Load all notes
  Future<void> loadNotes() async {
    if (!_pbService.isAuthenticated) {
      emit(const NoteLoaded(notes: []));
      return;
    }

    try {
      await _pbService.initialize();
      final notes = await _repo.getNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      emit(const NoteLoaded(notes: []));
    }
  }

  /// Story note: 1 note per story (upsert)
  Future<StoryNote?> addStoryNote({
    required String storyId,
    required String note,
  }) async {
    if (!_pbService.isAuthenticated) return null;

    final added = await _repo.addStoryNote(storyId: storyId, note: note);
    if (added != null) {
      final current = state is NoteLoaded ? (state as NoteLoaded).notes : <StoryNote>[];
      final without = current.where((n) =>
          !(n.storyId == storyId && (n.chapterId == null || n.chapterId!.isEmpty)));
      emit(NoteLoaded(notes: [added, ...without]));
    }
    return added;
  }

  /// Chapter note: 1 note per chapter (upsert)
  Future<StoryNote?> addChapterNote({
    required String storyId,
    required String chapterId,
    required String note,
    double? position,
  }) async {
    if (!_pbService.isAuthenticated) return null;

    final added = await _repo.addChapterNote(
          storyId: storyId,
          chapterId: chapterId,
          note: note,
          position: position,
        );
    if (added != null) {
      final current = state is NoteLoaded ? (state as NoteLoaded).notes : <StoryNote>[];
      final without = current.where((n) => n.chapterId != chapterId);
      emit(NoteLoaded(notes: [added, ...without]));
    }
    return added;
  }

  /// Lấy story note (để edit khi mở sheet từ story detail)
  Future<StoryNote?> getStoryNote(String storyId) async {
    return _repo.getStoryNote(storyId);
  }

  /// Lấy chapter note (để edit khi mở sheet từ reader)
  Future<StoryNote?> getChapterNote(String chapterId) async {
    return _repo.getChapterNote(chapterId);
  }

  /// Update note
  Future<bool> updateNote(String noteId, String note) async {
    if (!_pbService.isAuthenticated) return false;

    final ok = await _repo.updateNote(noteId, note);
    if (ok) {
      await loadNotes();
    }
    return ok;
  }

  /// Delete note
  Future<bool> deleteNote(String noteId) async {
    if (!_pbService.isAuthenticated) return false;

    final ok = await _repo.deleteNote(noteId);
    if (ok) {
      final current = state is NoteLoaded ? (state as NoteLoaded).notes : <StoryNote>[];
      emit(NoteLoaded(notes: current.where((n) => n.id != noteId).toList()));
    }
    return ok;
  }

  /// Clear (e.g. on logout)
  void clearNotes() {
    emit(const NoteLoaded(notes: []));
  }
}
