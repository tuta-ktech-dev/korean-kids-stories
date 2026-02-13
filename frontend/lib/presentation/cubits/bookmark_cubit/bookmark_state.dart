import 'package:equatable/equatable.dart';

import '../../../data/models/story.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

class BookmarkLoaded extends BookmarkState {
  final Set<String> bookmarkIds;
  final List<Story>? stories;
  final bool isRefreshing;

  const BookmarkLoaded({
    required this.bookmarkIds,
    this.stories,
    this.isRefreshing = false,
  });

  bool isBookmarked(String storyId) => bookmarkIds.contains(storyId);

  @override
  List<Object?> get props => [bookmarkIds, stories, isRefreshing];

  BookmarkLoaded copyWith({
    Set<String>? bookmarkIds,
    List<Story>? stories,
    bool? isRefreshing,
  }) {
    return BookmarkLoaded(
      bookmarkIds: bookmarkIds ?? this.bookmarkIds,
      stories: stories ?? this.stories,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
