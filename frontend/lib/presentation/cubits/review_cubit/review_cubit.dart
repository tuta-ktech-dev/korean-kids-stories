import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/review.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../injection.dart';

import 'review_state.dart';

export 'review_state.dart';

/// Cubit for story reviews. Create per story (e.g. in StoryDetailScreen).
class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit({
    required String storyId,
    ReviewRepository? reviewRepository,
  })  : _storyId = storyId,
        _reviewRepository = reviewRepository ?? getIt<ReviewRepository>(),
        super(const ReviewInitial()) {
    loadReviews();
  }

  final String _storyId;
  final ReviewRepository _reviewRepository;

  Future<void> loadReviews() async {
    if (state is ReviewLoading) return;
    emit(const ReviewLoading());

    try {
      final results = await Future.wait([
        _reviewRepository.getReviewsByStory(_storyId),
        _reviewRepository.getMyReview(_storyId),
      ]);

      final reviews = results[0] as List<Review>;
      final myReview = results[1] as Review?;

      emit(ReviewLoaded(reviews: reviews, myReview: myReview));
    } catch (e) {
      emit(ReviewError('Failed to load reviews'));
      if (kDebugMode) debugPrint('ReviewCubit.loadReviews error: $e');
    }
  }

  Future<bool> submitReview(int rating, {String? comment}) async {
    try {
      final review = await _reviewRepository.addOrUpdateReview(
        _storyId,
        rating.clamp(1, 5),
        comment: comment?.trim().isNotEmpty == true ? comment : null,
      );
      if (review == null) return false;

      final current = state;
      if (current is ReviewLoaded) {
        final existing = current.reviews.where((r) => r.id != review.id).toList();
        final hasMyReview = existing.any((r) => r.userId == review.userId);
        final newList = hasMyReview
            ? existing.map((r) => r.userId == review.userId ? review : r).toList()
            : [review, ...existing];
        emit(ReviewLoaded(reviews: newList, myReview: review));
      } else {
        await loadReviews();
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('ReviewCubit.submitReview error: $e');
      return false;
    }
  }

  Future<bool> deleteReview() async {
    try {
      final ok = await _reviewRepository.deleteReview(_storyId);
      if (!ok) return false;
      final current = state;
      if (current is ReviewLoaded) {
        final newList =
            current.reviews.where((r) => r.id != current.myReview?.id).toList();
        emit(ReviewLoaded(reviews: newList, myReview: null));
      } else {
        await loadReviews();
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('ReviewCubit.deleteReview error: $e');
      return false;
    }
  }
}
