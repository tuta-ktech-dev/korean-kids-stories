import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/reading_history_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'reader_state.dart';
export 'reader_state.dart';

/// Default playback speed for kids (slower = easier to follow)
const double _defaultPlaybackSpeed = 0.85;

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
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  String? _loadedAudioUrl;

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

      await _stopPlayer();
      final prevSpeed = state is ReaderLoaded ? (state as ReaderLoaded).playbackSpeed : _defaultPlaybackSpeed;
      emit(
        ReaderLoaded(
          chapter: chapter,
          prevChapter: prevChapter,
          nextChapter: nextChapter,
          nextChapterLocked: nextChapterLocked,
          audios: audios,
          selectedAudio: selectedAudio,
          progress: percent / 100,
          audioPosition: null,
          audioDurationSeconds: null,
          playbackSpeed: prevSpeed,
          playbackError: null,
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
  Future<void> selectAudio(ChapterAudio audio) async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    if (s.isPlaying) await _player.pause();
    emit(s.copyWith(selectedAudio: audio, isPlaying: false, clearAudioPosition: true));
  }

  void updateSettings({double? fontSize, bool? isDarkMode, double? playbackSpeed}) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(
        fontSize: fontSize,
        isDarkMode: isDarkMode,
        playbackSpeed: playbackSpeed,
      ));
      if (playbackSpeed != null && currentState.isPlaying) {
        _player.setSpeed(playbackSpeed);
      }
    }
  }

  void clearPlaybackError() {
    if (state is ReaderLoaded) {
      emit((state as ReaderLoaded).copyWith(clearPlaybackError: true));
    }
  }

  void updateProgress(double progress) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(progress: progress));
    }
  }

  Future<void> togglePlaying() async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    if (!s.hasAudio || s.selectedAudio?.audioUrl == null) {
      debugPrint('[ReaderCubit] togglePlaying: no audio or url. hasAudio=${s.hasAudio} url=${s.selectedAudio?.audioUrl}');
      return;
    }

    if (s.isPlaying) {
      await _player.pause();
      return;
    }

    final url = s.selectedAudio!.audioUrl!;
    debugPrint('[ReaderCubit] togglePlaying: loading url=$url');

    try {
      if (_loadedAudioUrl != url) {
        await _player.setUrl(url);
        _loadedAudioUrl = url;
      }
      await _player.setSpeed(s.playbackSpeed);
      _listenToPlayerIfNeeded(s.chapter.id);
      await _player.play();
      emit(s.copyWith(isPlaying: true, audioPosition: 0, clearPlaybackError: true));
      debugPrint('[ReaderCubit] togglePlaying: play() started');
    } catch (e, st) {
      debugPrint('[ReaderCubit] togglePlaying error: $e\n$st');
      emit(s.copyWith(isPlaying: false, playbackError: e.toString(), clearPlaybackError: false));
    }
  }

  Future<void> _stopPlayer() async {
    await _player.stop();
    _loadedAudioUrl = null;
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub = null;
    _positionSub = null;
    _durationSub = null;
  }

  void _listenToPlayerIfNeeded(String chapterId) {
    if (_stateSub != null) return;

    _stateSub = _player.playerStateStream.listen((playerState) {
      if (state is! ReaderLoaded) return;
      final s = state as ReaderLoaded;
      if (s.chapter.id != chapterId) return;
      final isPlaying = playerState.playing;
      final processing = playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering;
      emit(s.copyWith(isPlaying: isPlaying && !processing));
    });

    _positionSub = _player.positionStream.listen((position) {
      if (state is! ReaderLoaded) return;
      final s = state as ReaderLoaded;
      if (s.chapter.id != chapterId) return;
      emit(s.copyWith(audioPosition: position.inMilliseconds / 1000.0));
    });

    _durationSub = _player.durationStream.listen((duration) {
      if (state is! ReaderLoaded) return;
      final s = state as ReaderLoaded;
      if (s.chapter.id != chapterId) return;
      if (duration != null) {
        emit(s.copyWith(
            audioDurationSeconds: duration.inMilliseconds / 1000.0));
      }
    });
  }

  @override
  Future<void> close() async {
    await _stopPlayer();
    await _player.dispose();
    return super.close();
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
