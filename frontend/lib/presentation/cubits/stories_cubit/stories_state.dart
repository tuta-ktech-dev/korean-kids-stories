import 'package:equatable/equatable.dart';
import '../../../data/models/story.dart';

abstract class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => [];
}

class StoriesInitial extends StoriesState {
  const StoriesInitial();
}

class StoriesLoading extends StoriesState {
  const StoriesLoading();
}

class StoriesLoaded extends StoriesState {
  final List<Story> stories;

  const StoriesLoaded(this.stories);

  @override
  List<Object?> get props => [stories];

  StoriesLoaded copyWith({
    List<Story>? stories,
  }) {
    return StoriesLoaded(stories ?? this.stories);
  }
}

class StoriesError extends StoriesState {
  final String message;

  const StoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
