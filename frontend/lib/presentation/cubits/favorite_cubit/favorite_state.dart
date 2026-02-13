import 'package:equatable/equatable.dart';
import '../../../data/models/story.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoaded extends FavoriteState {
  final Set<String> favoriteIds;
  final List<Story>? stories; // optional, for Library tab
  final bool isRefreshing;

  const FavoriteLoaded({
    required this.favoriteIds,
    this.stories,
    this.isRefreshing = false,
  });

  bool isFavorite(String storyId) => favoriteIds.contains(storyId);

  @override
  List<Object?> get props => [favoriteIds, stories, isRefreshing];
}
