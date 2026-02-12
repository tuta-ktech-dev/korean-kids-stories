import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';
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
  }) : _storyRepository = storyRepository ?? getIt<StoryRepository>(),
       _progressRepository = progressRepository ?? getIt<ProgressRepository>(),
       _historyRepository =
           readingHistoryRepository ?? getIt<ReadingHistoryRepository>(),
       super(const ReaderInitial());

  final StoryRepository _storyRepository;
  final ProgressRepository _progressRepository;
  final ReadingHistoryRepository _historyRepository;

  /// Load a chapter. Set [skipLoading] true to avoid showing loading spinner
  /// when switching between chapters (smoother UX).
  Future<void> loadChapter(String chapterId, {bool skipLoading = false}) async {
    if (!skipLoading) emit(const ReaderLoading());

    try {
      await _storyRepository.initialize();
      final chapter = await _storyRepository.getChapter(chapterId);
      if (chapter == null) {
        emit(const ReaderError('chapterNotFound'));
        return;
      }
      // Chặn đọc chapter khóa (tránh truy cập qua URL trực tiếp)
      if (!chapter.isFree) {
        emit(const ReaderError('chapterLocked'));
        return;
      }

      Chapter? prevChapter;
      Chapter? nextChapter;
      Chapter? nextChapterLocked; // Chương tiếp bị khóa (để hiển thị paywall)
      final chapters = await _storyRepository.getChapters(chapter.storyId);
      final idx = chapters.indexWhere((c) => c.id == chapterId);
      if (idx > 0) prevChapter = chapters[idx - 1];
      if (idx >= 0 && idx < chapters.length - 1) {
        final next = chapters[idx + 1];
        if (next.isFree) {
          nextChapter = next;
        } else {
          nextChapterLocked = next;
        }
      }

      final audios = await _storyRepository.getChapterAudios(chapterId);
      final selectedAudio = audios.isNotEmpty ? audios.first : null;

      final progress = await _progressRepository.getProgress(chapterId);
      final percent = progress?.percentRead ?? 0.0;

      emit(
        ReaderLoaded(
          chapter: chapter,
          prevChapter: prevChapter,
          nextChapter: nextChapter,
          nextChapterLocked: nextChapterLocked,
          audios: audios,
          selectedAudio: selectedAudio,
          progress: percent / 100,
        ),
      );
      _historyRepository.logAction(
        storyId: chapter.storyId,
        chapterId: chapterId,
        action: 'view',
      );
    } on PocketbaseException {
      emit(ReaderError('chapterLoadError'));
    } catch (e) {
      emit(const ReaderError('chapterLoadError'));
    }
  }

  /// Switch to a different narrator/voice
  void selectAudio(ChapterAudio audio) {
    if (state is ReaderLoaded) {
      final s = state as ReaderLoaded;
      emit(s.copyWith(selectedAudio: audio));
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
