import 'package:injectable/injectable.dart';

import '../models/story.dart';
import 'local_favorite_repository.dart';
import 'story_repository.dart';

/// Repository for favorite stories. Kids app: always uses local storage.
@injectable
class FavoriteRepository {
  FavoriteRepository(this._localRepo, this._storyRepo);
  final LocalFavoriteRepository _localRepo;
  final StoryRepository _storyRepo;

  Future<bool> isFavorite(String storyId) async {
    return _localRepo.isFavorite(storyId);
  }

  Future<Set<String>> getFavoriteIds() async {
    return _localRepo.getFavoriteIds();
  }

  /// Get favorited stories with full Story data
  Future<List<Story>> getFavorites() async {
    final ids = await _localRepo.getFavoriteIds();
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

  Future<bool> addFavorite(String storyId) async {
    return _localRepo.addFavorite(storyId);
  }

  Future<bool> removeFavorite(String storyId) async {
    return _localRepo.removeFavorite(storyId);
  }
}
