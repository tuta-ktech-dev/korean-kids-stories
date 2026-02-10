import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';

import 'story_detail_state.dart';

export 'story_detail_state.dart';

/// Route-scoped cubit - created per StoryDetailScreen with storyId.
/// Not registered with injectable (storyId is runtime param).
class StoryDetailCubit extends Cubit<StoryDetailState> {
  StoryDetailCubit({
    required String storyId,
    StoryRepository? storyRepository,
  })  : _storyId = storyId,
        _storyRepository = storyRepository ?? getIt<StoryRepository>(),
        super(const StoryDetailInitial()) {
    load();
  }

  final String _storyId;
  final StoryRepository _storyRepository;

  Future<void> load() async {
    emit(const StoryDetailLoading());

    try {
      await _storyRepository.initialize();

      final results = await Future.wait([
        _storyRepository.getStory(_storyId),
        _storyRepository.getChapters(_storyId),
      ]);

      final story = results[0] as Story?;
      final chapters = results[1] as List<Chapter>;

      if (story == null) {
        emit(const StoryDetailNotFound());
        return;
      }

      await _trackView(story);

      emit(StoryDetailLoaded(story: story, chapters: chapters));
    } on Exception catch (e) {
      emit(StoryDetailError('Failed to load story'));
      if (kDebugMode) debugPrint('StoryDetailCubit.load error: $e');
    }
  }

  Future<void> _trackView(Story story) async {
    try {
      final pb = getIt<PocketbaseService>().pb;
      await pb.collection('views').create(body: {'story': story.id});
    } catch (_) {
      // Ignore - view tracking is non-critical
    }
  }

  void refresh() => load();
}
