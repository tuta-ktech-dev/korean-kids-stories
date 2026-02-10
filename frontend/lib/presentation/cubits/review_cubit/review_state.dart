import '../../../../data/models/review.dart';

sealed class ReviewState {
  const ReviewState();
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<Review> reviews;
  final Review? myReview;

  const ReviewLoaded({required this.reviews, this.myReview});

  List<Review> get allReviews {
    if (myReview == null) return reviews;
    final myId = myReview!.id;
    return reviews.map((r) => r.id == myId ? myReview! : r).toList();
  }
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);
}
