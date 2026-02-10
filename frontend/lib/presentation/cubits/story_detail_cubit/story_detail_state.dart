import 'package:equatable/equatable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';

sealed class StoryDetailState extends Equatable {
  const StoryDetailState();

  @override
  List<Object?> get props => [];
}

final class StoryDetailInitial extends StoryDetailState {
  const StoryDetailInitial();
}

final class StoryDetailLoading extends StoryDetailState {
  const StoryDetailLoading();
}

final class StoryDetailLoaded extends StoryDetailState {
  final Story story;
  final List<Chapter> chapters;

  const StoryDetailLoaded({
    required this.story,
    required this.chapters,
  });

  @override
  List<Object?> get props => [story, chapters];

  bool get hasChapters => chapters.isNotEmpty;
}

final class StoryDetailNotFound extends StoryDetailState {
  const StoryDetailNotFound();
}

final class StoryDetailError extends StoryDetailState {
  final String message;

  const StoryDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
