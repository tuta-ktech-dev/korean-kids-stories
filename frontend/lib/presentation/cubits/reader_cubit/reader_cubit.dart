import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/reading_history_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'reader_state.dart';
export 'reader_state.dart';

@injectable
class ReaderCubit extends Cubit<ReaderState> {
  ReaderCubit({
    StoryRepository? storyRepository,
    ProgressRepository? progressRepository,
    ReadingHistoryRepository? readingHistoryRepository,
  })  : _storyRepository = storyRepository ?? getIt<StoryRepository>(),
        _progressRepository = progressRepository ?? getIt<ProgressRepository>(),
        _historyRepository =
            readingHistoryRepository ?? getIt<ReadingHistoryRepository>(),
        super(const ReaderInitial());

  final StoryRepository _storyRepository;
  final ProgressRepository _progressRepository;
  final ReadingHistoryRepository _historyRepository;

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
        _historyRepository.logAction(
          storyId: chapter.storyId,
          chapterId: chapterId,
          action: 'view',
        );
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

  /// Add bookmark at current progress with optional note
  Future<bool> addBookmark({String? note}) async {
    if (state is! ReaderLoaded) return false;
    final s = state as ReaderLoaded;
    final position = s.progress * 100; // 0-100 scale
    final p = await _progressRepository.addBookmark(
      chapterId: s.chapter.id,
      position: position,
      note: note,
    );
    return p != null;
  }
}
