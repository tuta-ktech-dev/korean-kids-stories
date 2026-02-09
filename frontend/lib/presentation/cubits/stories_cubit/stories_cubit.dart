import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/pocketbase_service.dart';
import 'stories_state.dart';
export 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit() : super(const StoriesInitial());

  final _pbService = PocketbaseService();

  Future<void> loadStories({String? category}) async {
    emit(const StoriesLoading());

    try {
      await _pbService.initialize();
      final stories = await _pbService.getStories(category: category);
      emit(StoriesLoaded(stories));
    } catch (e) {
      emit(StoriesError('Failed to load stories: $e'));
    }
  }

  Future<void> refresh() async {
    if (state is StoriesLoaded) {
      await loadStories();
    }
  }
}
