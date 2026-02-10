import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/story.dart';
import '../services/pocketbase_service.dart';

/// Repository for favorite stories (bookmarks collection, type=favorite)
@injectable
class FavoriteRepository {
  FavoriteRepository(this._pbService);
  final PocketbaseService _pbService;
  static const String _typeFavorite = 'favorite';

  PocketBase get _pb => _pbService.pb;

  /// Check if user has favorited a story
  Future<bool> isFavorite(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final result = await _pb.collection('bookmarks').getList(
            filter: 'user="$userId" && story="$storyId" && type="$_typeFavorite"',
            perPage: 1,
          );
      return result.items.isNotEmpty;
    } catch (e) {
      debugPrint('FavoriteRepository.isFavorite error: $e');
      return false;
    }
  }

  /// Get all favorited story IDs
  Future<Set<String>> getFavoriteIds() async {
    try {
      if (!_pbService.isAuthenticated) return {};

      final userId = _pbService.currentUser?.id;
      if (userId == null) return {};

      final result = await _pb.collection('bookmarks').getFullList(
            filter: 'user="$userId" && type="$_typeFavorite"',
          );
      return result.map((r) => r.getStringValue('story')).where((s) => s.isNotEmpty).toSet();
    } catch (e) {
      debugPrint('FavoriteRepository.getFavoriteIds error: $e');
      return {};
    }
  }

  /// Get favorited stories with full Story data
  Future<List<Story>> getFavorites() async {
    final ids = await getFavoriteIds();
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

  /// Add story to favorites
  Future<bool> addFavorite(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      // Check if already exists
      final existing = await _pb.collection('bookmarks').getList(
            filter: 'user="$userId" && story="$storyId" && type="$_typeFavorite"',
            perPage: 1,
          );
      if (existing.items.isNotEmpty) return true;

      await _pb.collection('bookmarks').create(body: {
        'user': userId,
        'story': storyId,
        'type': _typeFavorite,
      });
      return true;
    } catch (e) {
      debugPrint('FavoriteRepository.addFavorite error: $e');
      return false;
    }
  }

  /// Remove story from favorites
  Future<bool> removeFavorite(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final result = await _pb.collection('bookmarks').getList(
            filter: 'user="$userId" && story="$storyId" && type="$_typeFavorite"',
            perPage: 1,
          );
      if (result.items.isEmpty) return true;

      await _pb.collection('bookmarks').delete(result.items.first.id);
      return true;
    } catch (e) {
      debugPrint('FavoriteRepository.removeFavorite error: $e');
      return false;
    }
  }
}
