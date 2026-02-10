import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import 'reader_state.dart';
export 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final StoryRepository _storyRepository;

  ReaderCubit({StoryRepository? storyRepository})
      : _storyRepository = storyRepository ?? StoryRepository(),
        super(const ReaderInitial());

  Future<void> loadChapter(String chapterId) async {
    emit(const ReaderLoading());

    try {
      await _storyRepository.initialize();
      final chapter = await _storyRepository.getChapter(chapterId);

      if (chapter != null) {
        emit(ReaderLoaded(chapter: chapter));
      } else {
        emit(const ReaderError('챕터를 찾을 수 없습니다'));
      }
    } on PocketbaseException catch (e) {
      emit(ReaderError('챕터 로드 실패: ${e.message}'));
    } catch (e) {
      emit(ReaderError('챕터 로드 실패: ${e.toString()}'));
    }
  }

  void updateSettings({double? fontSize, bool? isDarkMode}) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(fontSize: fontSize, isDarkMode: isDarkMode));
    }
  }
}
