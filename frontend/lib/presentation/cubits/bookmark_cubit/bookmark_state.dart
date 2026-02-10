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

  const BookmarkLoaded({
    required this.bookmarkIds,
    this.stories,
  });

  bool isBookmarked(String storyId) => bookmarkIds.contains(storyId);

  @override
  List<Object?> get props => [bookmarkIds, stories];
}
