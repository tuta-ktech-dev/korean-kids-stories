import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/review.dart';
import '../services/pocketbase_service.dart';

@injectable
class ReviewRepository {
  ReviewRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Get all reviews for a story (with expand user for name)
  Future<List<Review>> getReviewsByStory(String storyId) async {
    try {
      final result = await _pb.collection('reviews').getList(
            filter: 'story="$storyId"',
            sort: '-created',
            expand: 'user',
          );
      return result.items.map((r) => Review.fromRecord(r)).toList();
    } catch (e) {
      debugPrint('ReviewRepository.getReviewsByStory error: $e');
      return [];
    }
  }

  /// Get current user's review for a story (if any)
  Future<Review?> getMyReview(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return null;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final result = await _pb.collection('reviews').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );
      if (result.items.isEmpty) return null;
      return Review.fromRecord(result.items.first);
    } catch (e) {
      debugPrint('ReviewRepository.getMyReview error: $e');
      return null;
    }
  }

  /// Add or update review (1 per user per story)
  Future<Review?> addOrUpdateReview(String storyId, int rating, {String? comment}) async {
    try {
      if (!_pbService.isAuthenticated) return null;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return null;

      final existing = await _pb.collection('reviews').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );

      final body = <String, dynamic>{
        'user': userId,
        'story': storyId,
        'rating': rating.clamp(1, 5),
      };
      if (comment != null && comment.trim().isNotEmpty) {
        body['comment'] = comment.trim();
      }

      RecordModel record;
      if (existing.items.isEmpty) {
        record = await _pb.collection('reviews').create(body: body);
      } else {
        record = await _pb.collection('reviews').update(existing.items.first.id, body: body);
      }
      return Review.fromRecord(record);
    } catch (e) {
      debugPrint('ReviewRepository.addOrUpdateReview error: $e');
      return null;
    }
  }

  /// Delete current user's review for a story
  Future<bool> deleteReview(String storyId) async {
    try {
      if (!_pbService.isAuthenticated) return false;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      final result = await _pb.collection('reviews').getList(
            filter: 'user="$userId" && story="$storyId"',
            perPage: 1,
          );
      if (result.items.isEmpty) return true;

      await _pb.collection('reviews').delete(result.items.first.id);
      return true;
    } catch (e) {
      debugPrint('ReviewRepository.deleteReview error: $e');
      return false;
    }
  }
}
