import 'package:injectable/injectable.dart';

import '../models/story.dart';
import 'local_bookmark_repository.dart';
import 'story_repository.dart';

/// Repository for read-later bookmarks. Kids app: always uses local storage.
@injectable
class BookmarkRepository {
  BookmarkRepository(this._localRepo, this._storyRepo);
  final LocalBookmarkRepository _localRepo;
  final StoryRepository _storyRepo;

  Future<Set<String>> getBookmarkIds() async {
    return _localRepo.getBookmarkIds();
  }

  Future<List<Story>> getBookmarkedStories() async {
    final ids = await _localRepo.getBookmarkIds();
    if (ids.isEmpty) return [];

    final stories = <Story>[];
    for (final id in ids) {
      try {
        final story = await _storyRepo.getStory(id);
        if (story != null) stories.add(story);
      } catch (_) {}
    }
    return stories;
  }

  Future<bool> isBookmarked(String storyId) async {
    return _localRepo.isBookmarked(storyId);
  }

  Future<bool> addBookmark(String storyId) async {
    return _localRepo.addBookmark(storyId);
  }

  Future<bool> removeBookmark(String storyId) async {
    return _localRepo.removeBookmark(storyId);
  }
}
