import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'bookmark_state.dart';
export 'bookmark_state.dart';

@lazySingleton
class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit({
    BookmarkRepository? bookmarkRepository,
    PocketbaseService? pocketbaseService,
  })  : _repo = bookmarkRepository ?? getIt<BookmarkRepository>(),
        _pbService = pocketbaseService ?? getIt<PocketbaseService>(),
        super(const BookmarkInitial());

  final BookmarkRepository _repo;
  final PocketbaseService _pbService;

  /// Load bookmark IDs (lightweight). Preserves stories for Library tab.
  Future<void> loadBookmarks() async {
    if (!_pbService.isAuthenticated) {
      emit(const BookmarkLoaded(bookmarkIds: {}));
      return;
    }

    try {
      await _pbService.initialize();
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

  /// Load bookmarked stories (for Library tab)
  Future<void> loadBookmarkedStories() async {
    if (!_pbService.isAuthenticated) {
      emit(const BookmarkLoaded(bookmarkIds: {}));
      return;
    }

    try {
      await _pbService.initialize();
      final stories = await _repo.getBookmarkedStories();
      final ids = stories.map((s) => s.id).toSet();
      emit(BookmarkLoaded(bookmarkIds: ids, stories: stories));
    } catch (e) {
      emit(const BookmarkLoaded(bookmarkIds: {}));
    }
  }

  /// Toggle bookmark (read later)
  Future<bool> toggleBookmark(String storyId) async {
    if (!_pbService.isAuthenticated) return false;

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

  /// Clear (e.g. on logout)
  void clearBookmarks() {
    emit(const BookmarkLoaded(bookmarkIds: {}));
  }
}
