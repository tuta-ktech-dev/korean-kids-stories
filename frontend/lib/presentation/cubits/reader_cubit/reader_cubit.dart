import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import 'reader_state.dart';
export 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final StoryRepository _storyRepository;
  final ProgressRepository _progressRepository;

  ReaderCubit({
    StoryRepository? storyRepository,
    ProgressRepository? progressRepository,
  })  : _storyRepository = storyRepository ?? StoryRepository(),
        _progressRepository = progressRepository ?? ProgressRepository(),
        super(const ReaderInitial());

  Future<void> loadChapter(String chapterId) async {
    emit(const ReaderLoading());

    try {
      await _storyRepository.initialize();
      final chapter = await _storyRepository.getChapter(chapterId);

      if (chapter != null) {
        final progress = await _progressRepository.getProgress(chapterId);
        final percent = progress?.percentRead ?? 0.0;
        emit(ReaderLoaded(
          chapter: chapter,
          progress: percent / 100,
        ));
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

  void updateProgress(double progress) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(progress: progress));
    }
  }

  void togglePlaying() {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(isPlaying: !currentState.isPlaying));
    }
  }
}
