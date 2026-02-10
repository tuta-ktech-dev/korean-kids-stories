import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/story.dart';
import '../services/pocketbase_service.dart';

/// Repository for read-later bookmarks (read_later collection)
@injectable
class BookmarkRepository {
  BookmarkRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get all bookmarked story IDs
  Future<Set<String>> getBookmarkIds() async {
    try {
      if (!_pbService.isAuthenticated) return {};

      final userId = _pbService.currentUser?.id;
      if (userId == null) return {};

      final result = await _pb.collection('read_later').getFullList(
            filter: 'user="$userId"',
          );
      return result.map((r) => r.getStringValue('story')).where((s) => s.isNotEmpty).toSet();
    } catch (e) {
      debugPrint('BookmarkRepository.getBookmarkIds error: $e');
      return {};
    }
  }

  /// Get bookmarked stories
  Future<List<Story>> getBookmarkedStories() async {
    final ids = await getBookmarkIds();
    if (ids.isEmpty) return [];

    final stories = <Story>[];
    for (final id in ids) {
      try {
        final record = await _pb.collection('stories').getOne(id);
        stories.add(Story.fromRecord(record, pb: _pb));
      } catch (_) {}
    }
    return stories;
  }

  /// Check if story is bookmarked
  Future<bool> isBookmarked(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final result = await _pb.collection('read_later').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );
      return result.items.isNotEmpty;
    } catch (e) {
      debugPrint('BookmarkRepository.isBookmarked error: $e');
      return false;
    }
  }

  /// Add bookmark (read later)
  Future<bool> addBookmark(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final existing = await _pb.collection('read_later').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );
      if (existing.items.isNotEmpty) return true;

      await _pb.collection('read_later').create(body: {
        'user': userId,
        'story': storyId,
      });
      return true;
    } catch (e) {
      debugPrint('BookmarkRepository.addBookmark error: $e');
      return false;
    }
  }

  /// Remove bookmark
  Future<bool> removeBookmark(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final result = await _pb.collection('read_later').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );
      if (result.items.isEmpty) return true;

      await _pb.collection('read_later').delete(result.items.first.id);
      return true;
    } catch (e) {
      debugPrint('BookmarkRepository.removeBookmark error: $e');
      return false;
    }
  }
}
