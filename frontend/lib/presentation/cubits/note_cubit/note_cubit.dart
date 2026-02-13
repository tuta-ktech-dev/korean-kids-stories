import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/note_repository.dart';
import '../../../injection.dart';
import 'note_state.dart';
export 'note_state.dart';

/// Kids app: always uses local storage.
@lazySingleton
class NoteCubit extends Cubit<NoteState> {
  NoteCubit({NoteRepository? noteRepository})
    : _repo = noteRepository ?? getIt<NoteRepository>(),
      super(const NoteInitial());

  final NoteRepository _repo;

  /// Stale-while-revalidate: shows cached notes if any, fetches in background.
  Future<void> loadNotes() async {
    final current = state is NoteLoaded ? (state as NoteLoaded) : null;
    final hasCache = current != null;
    if (hasCache) {
      emit(NoteLoaded(notes: current.notes, isRefreshing: true));
    }

    try {
      final notes = await _repo.getNotes();
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      if (hasCache) {
        emit(NoteLoaded(notes: current.notes, isRefreshing: false));
      } else {
        emit(const NoteLoaded(notes: []));
      }
    }
  }

  Future<StoryNote?> addStoryNote({
    required String storyId,
    required String note,
  }) async {
    final added = await _repo.addStoryNote(storyId: storyId, note: note);
    if (added != null) {
      final current = state is NoteLoaded
          ? (state as NoteLoaded).notes
          : <StoryNote>[];
      final without = current.where(
        (n) =>
            !(n.storyId == storyId &&
                (n.chapterId == null || n.chapterId!.isEmpty)),
      );
      emit(NoteLoaded(notes: [added, ...without]));
    }
    return added;
  }

  Future<StoryNote?> addChapterNote({
    required String storyId,
    required String chapterId,
    required String note,
    double? position,
  }) async {
    final added = await _repo.addChapterNote(
      storyId: storyId,
      chapterId: chapterId,
      note: note,
      position: position,
    );
    if (added != null) {
      final current = state is NoteLoaded
          ? (state as NoteLoaded).notes
          : <StoryNote>[];
      final without = current.where((n) => n.chapterId != chapterId);
      emit(NoteLoaded(notes: [added, ...without]));
    }
    return added;
  }

  Future<StoryNote?> getStoryNote(String storyId) async {
    return _repo.getStoryNote(storyId);
  }

  Future<StoryNote?> getChapterNote(String chapterId) async {
    return _repo.getChapterNote(chapterId);
  }

  Future<bool> updateNote(String noteId, String note) async {
    final ok = await _repo.updateNote(noteId, note);
    if (ok) {
      await loadNotes();
    }
    return ok;
  }

  Future<bool> deleteNote(String noteId) async {
    final ok = await _repo.deleteNote(noteId);
    if (ok) {
      final current = state is NoteLoaded
          ? (state as NoteLoaded).notes
          : <StoryNote>[];
      emit(NoteLoaded(notes: current.where((n) => n.id != noteId).toList()));
    }
    return ok;
  }

  void clearNotes() {
    emit(const NoteLoaded(notes: []));
  }
}
