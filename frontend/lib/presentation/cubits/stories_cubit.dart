import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/story.dart';
import '../../data/services/pocketbase_service.dart';

// States
abstract class StoriesState {}

class StoriesInitial extends StoriesState {}

class StoriesLoading extends StoriesState {}

class StoriesLoaded extends StoriesState {
  final List<Story> stories;
  StoriesLoaded(this.stories);
}

class StoriesError extends StoriesState {
  final String message;
  StoriesError(this.message);
}

// Cubit
class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit() : super(StoriesInitial());

  final _pbService = PocketbaseService();

  Future<void> loadStories({String? category}) async {
    emit(StoriesLoading());
    
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
