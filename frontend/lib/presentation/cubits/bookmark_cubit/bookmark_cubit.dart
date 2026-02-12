import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/bookmark_repository.dart';
import '../../../injection.dart';
import 'bookmark_state.dart';
export 'bookmark_state.dart';

/// Kids app: always uses local storage.
@lazySingleton
class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit({BookmarkRepository? bookmarkRepository})
      : _repo = bookmarkRepository ?? getIt<BookmarkRepository>(),
        super(const BookmarkInitial());

  final BookmarkRepository _repo;

  Future<void> loadBookmarks() async {
    try {
      final ids = await _repo.getBookmarkIds();
      final current = state is BookmarkLoaded ? (state as BookmarkLoaded) : null;
      emit(BookmarkLoaded(
        bookmarkIds: ids,
        stories: current?.stories,
      ));
    } catch (e) {
      emit(const BookmarkLoaded(bookmarkIds: {}));
    }
  }

  Future<void> loadBookmarkedStories() async {
    try {
      final stories = await _repo.getBookmarkedStories();
      final ids = stories.map((s) => s.id).toSet();
      emit(BookmarkLoaded(bookmarkIds: ids, stories: stories));
    } catch (e) {
      emit(const BookmarkLoaded(bookmarkIds: {}));
    }
  }

  Future<bool> toggleBookmark(String storyId) async {
    final current = state is BookmarkLoaded ? (state as BookmarkLoaded) : null;
    final ids = current?.bookmarkIds ?? {};
    final isBookmarked = ids.contains(storyId);

    final ok = isBookmarked
        ? await _repo.removeBookmark(storyId)
        : await _repo.addBookmark(storyId);

    if (ok) {
      if (isBookmarked) {
        final newIds = Set<String>.from(ids)..remove(storyId);
        final newStories = current?.stories?.where((s) => s.id != storyId).toList();
        emit(BookmarkLoaded(bookmarkIds: newIds, stories: newStories));
      } else {
        await loadBookmarkedStories();
      }
    }
    return ok;
  }

  void clearBookmarks() {
    emit(const BookmarkLoaded(bookmarkIds: {}));
  }
}
