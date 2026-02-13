import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/reading_history_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../data/services/premium_service.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import '../audio_player_cubit/audio_player_cubit.dart';
import 'reader_state.dart';
export 'reader_state.dart';

/// Default playback speed for kids (slower = easier to follow)
const double _defaultPlaybackSpeed = 0.85;

/// Luồng hoàn thành chapter/story:
/// - Chapter có next (free): auto load + play chapter tiếp
/// - Chapter cuối truyện (isLastChapterOfStory): gọi onStoryComplete
/// - onStoryComplete: ReaderScreen xử lý dialog, quiz, hoặc (sau) auto chuyển story

@injectable
class ReaderCubit extends Cubit<ReaderState> {
  ReaderCubit({
    StoryRepository? storyRepository,
    ProgressRepository? progressRepository,
    ReadingHistoryRepository? readingHistoryRepository,
    AudioPlayerCubit? audioPlayerCubit,
    PremiumService? premiumService,
  }) : _storyRepository = storyRepository ?? getIt<StoryRepository>(),
       _progressRepository = progressRepository ?? getIt<ProgressRepository>(),
       _historyRepository =
           readingHistoryRepository ?? getIt<ReadingHistoryRepository>(),
       _audioCubit = audioPlayerCubit ?? getIt<AudioPlayerCubit>(),
       _premiumService = premiumService ?? getIt<PremiumService>(),
       super(const ReaderInitial());

  final StoryRepository _storyRepository;
  final ProgressRepository _progressRepository;
  final ReadingHistoryRepository _historyRepository;
  final AudioPlayerCubit _audioCubit;
  final PremiumService _premiumService;

  StreamSubscription<AudioPlayerState>? _audioStateSub;
  double _lastReportedPositionSec = 0;
  Timer? _sleepTimer;
  bool _isHandlingChapterComplete = false;

  /// Called when last chapter of story completes (audio done).
  /// Enables dialog, quiz flow, và nâng cấp sau: auto chuyển story.
  /// Parameters: storyId, completedChapterId (for quiz), hasQuiz
  void Function(String storyId, String completedChapterId, bool hasQuiz)?
      onStoryComplete;

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

      final prevLoaded = state is ReaderLoaded ? state as ReaderLoaded : null;

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
      // Nhớ giọng user đang nghe: khi chuyển chương, chọn cùng narrator nếu có
      // Chưa đặt mặc định thì ưu tiên giọng nữ (여자/KSS)
      final preferredNarrator = prevLoaded?.selectedAudio?.narrator;
      ChapterAudio? selectedAudio;
      if (audios.isNotEmpty) {
        if (preferredNarrator != null && preferredNarrator.isNotEmpty) {
          try {
            selectedAudio = audios.firstWhere(
              (a) => (a.narrator ?? '').trim() == preferredNarrator.trim(),
            );
          } catch (_) {
            selectedAudio = _defaultToFemaleVoice(audios);
          }
        } else {
          selectedAudio = _defaultToFemaleVoice(audios);
        }
      }
      final story = await _storyRepository.getStory(chapter.storyId);

      final progress = await _progressRepository.getProgress(chapterId);
      final percent = progress?.percentRead ?? 0.0;
      final lastPosMs = progress?.lastPosition ?? 0.0;
      final initialSec = (audios.isNotEmpty && lastPosMs > 0)
          ? (lastPosMs / 1000.0)
          : null;

      // Stop any playback when switching chapters
      await _audioCubit.stop();
      _wireAudioCallbacks();

      final prevSpeed = prevLoaded?.playbackSpeed ?? _defaultPlaybackSpeed;
      emit(
        ReaderLoaded(
          chapter: chapter,
          story: story,
          prevChapter: prevChapter,
          nextChapter: nextChapter,
          nextChapterLocked: nextChapterLocked,
          audios: audios,
          selectedAudio: selectedAudio,
          progress: percent / 100,
          audioPosition: initialSec,
          audioDurationSeconds: null,
          playbackSpeed: prevSpeed,
          playbackError: null,
          initialAudioPositionSec: initialSec,
          sleepTimerMinutes: prevLoaded?.sleepTimerMinutes ?? 0,
          sleepTimerEndsAt: prevLoaded?.sleepTimerEndsAt,
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

  /// Mặc định chọn giọng nữ (여자/KSS) nếu có, không thì phần tử đầu
  static ChapterAudio _defaultToFemaleVoice(List<ChapterAudio> audios) {
    const femaleNames = ['여자', 'female', 'kss', 'nu', 'nữ', '새 목소리'];
    for (final a in audios) {
      final n = (a.narrator ?? '').trim();
      final nLower = n.toLowerCase();
      if (femaleNames.any((x) => n == x || nLower == x || nLower.contains(x))) {
        return a;
      }
    }
    return audios.first;
  }

  void _wireAudioCallbacks() {
    _audioCubit.onSkipToNext = () {
      if (state is ReaderLoaded) {
        _goToChapterAndPlay((state as ReaderLoaded).nextChapter);
      }
    };

    _audioCubit.onSkipToPrevious = () {
      if (state is ReaderLoaded) {
        _goToChapterAndPlay((state as ReaderLoaded).prevChapter);
      }
    };

    _audioCubit.onChapterComplete = () async {
      if (_isHandlingChapterComplete || state is! ReaderLoaded) return;
      _isHandlingChapterComplete = true;
      try {
        final s = state as ReaderLoaded;

        // Có chapter tiếp theo (free) → load và auto play
        if (s.nextChapter != null) {
          await _goToChapterAndPlay(s.nextChapter, delayBeforePlay: true);
          return;
        }

        // Hết truyện (không còn chapter) → báo story complete
        if (s.isLastChapterOfStory && onStoryComplete != null) {
          onStoryComplete!.call(
            s.chapter.storyId,
            s.chapter.id,
            s.story?.hasQuiz ?? false,
          );
        }
      } finally {
        _isHandlingChapterComplete = false;
      }
    };
  }

  /// Chuyển sang chapter và auto play. Dùng cho: skip next/prev, auto-next khi hết chapter.
  /// Chuẩn bị cho nâng cấp: chuyển story khi hết truyện (qua onStoryComplete).
  Future<void> _goToChapterAndPlay(Chapter? chapter,
      {bool delayBeforePlay = false}) async {
    if (chapter == null || state is! ReaderLoaded) return;
    try {
      await loadChapter(chapter.id, skipLoading: true);
      if (state is! ReaderLoaded) return;
      if (delayBeforePlay) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (state is ReaderLoaded && (state as ReaderLoaded).hasAudio) {
        _startPlayback();
      }
    } catch (e) {
      debugPrint('[ReaderCubit] _goToChapterAndPlay error: $e');
    }
  }

  /// Switch to a different narrator/voice
  Future<void> selectAudio(ChapterAudio audio) async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    if (s.isPlaying) await _audioCubit.pause();
    emit(s.copyWith(selectedAudio: audio, isPlaying: false, clearAudioPosition: true));
  }

  void updateSettings({double? fontSize, double? playbackSpeed}) {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(
        fontSize: fontSize,
        playbackSpeed: playbackSpeed,
      ));
      if (playbackSpeed != null && currentState.isPlaying) {
        _audioCubit.setSpeed(playbackSpeed);
      }
    }
  }

  void clearPlaybackError() {
    if (state is ReaderLoaded) {
      emit((state as ReaderLoaded).copyWith(clearPlaybackError: true));
    }
  }

  /// Dismiss the free limit reached / upgrade dialog.
  void clearFreeLimitReached() {
    if (state is ReaderLoaded) {
      emit((state as ReaderLoaded).copyWith(freeLimitReached: false));
    }
  }

  void updateProgress(double progress) {
    if (state is ReaderLoaded) {
      emit((state as ReaderLoaded).copyWith(progress: progress));
    }
  }

  Future<void> togglePlaying() async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    if (!s.hasAudio || s.selectedAudio?.audioUrl == null) {
      debugPrint('[ReaderCubit] togglePlaying: no audio or url.');
      return;
    }

    // If already playing this chapter, pause
    if (_audioCubit.isPlayingChapter(s.chapter.id)) {
      await _audioCubit.pause();
      return;
    }

    await _startPlayback();
  }

  Future<void> _startPlayback() async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    final url = s.selectedAudio?.audioUrl;
    if (url == null || url.isEmpty) return;

    // Gate: free users limited to 15 min/day
    if (!(await _premiumService.canPlayAudio())) {
      emit(s.copyWith(freeLimitReached: true));
      return;
    }

    try {
      final seekToSec = s.initialAudioPositionSec ?? 0;
      _lastReportedPositionSec = seekToSec;

      await _audioCubit.loadChapter(
        chapterId: s.chapter.id,
        storyId: s.chapter.storyId,
        chapterTitle: s.chapter.title,
        storyTitle: s.story?.title ?? '',
        audioUrl: url,
        initialPositionSeconds: seekToSec,
      );
      await _audioCubit.setSpeed(s.playbackSpeed);
      _listenToAudioCubitIfNeeded(s.chapter.id);
      await _audioCubit.play();

      emit(s.copyWith(
        isPlaying: true,
        audioPosition: seekToSec,
        clearPlaybackError: true,
        clearInitialAudioPosition: true,
      ));
    } catch (e, st) {
      debugPrint('[ReaderCubit] togglePlaying error: $e\n$st');
      emit(s.copyWith(
        isPlaying: false,
        playbackError: e.toString(),
        clearPlaybackError: false,
      ));
    }
  }

  void _listenToAudioCubitIfNeeded(String chapterId) {
    if (_audioStateSub != null) return;

    _audioStateSub = _audioCubit.stream.listen((audioState) async {
      if (state is! ReaderLoaded) return;
      final s = state as ReaderLoaded;
      if (audioState is! AudioPlayerReady) return;
      final ready = audioState;
      if (ready.chapterId != s.chapter.id) return;

      final posSec = ready.position.inMilliseconds / 1000.0;
      final durSec = ready.duration.inMilliseconds / 1000.0;

      // Track free daily usage when playing
      if (ready.isPlaying) {
        final deltaSec = (posSec - _lastReportedPositionSec).floor();
        if (deltaSec > 0) {
          _lastReportedPositionSec = posSec;
          final remaining = await _premiumService.getRemainingFreeSecondsToday();
          final toAdd = deltaSec.clamp(0, remaining);
          if (toAdd > 0) {
            await _premiumService.addAudioSecondsUsed(toAdd);
            final afterRemaining =
                await _premiumService.getRemainingFreeSecondsToday();
            if (afterRemaining <= 0) {
              await _audioCubit.pause();
              emit(s.copyWith(
                isPlaying: false,
                audioPosition: posSec,
                audioDurationSeconds: durSec > 0 ? durSec : null,
                freeLimitReached: true,
              ));
              return;
            }
          }
        }
      } else {
        _lastReportedPositionSec = posSec;
      }

      emit(s.copyWith(
        isPlaying: ready.isPlaying,
        audioPosition: posSec,
        audioDurationSeconds: durSec > 0 ? durSec : null,
      ));
    });
  }

  /// Set sleep timer: 0 = off, else minutes until auto-pause.
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;

    if (minutes <= 0) {
      emit(s.copyWith(sleepTimerMinutes: 0, clearSleepTimer: true));
      return;
    }

    final endsAt = DateTime.now().add(Duration(minutes: minutes));
    emit(s.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerEndsAt: endsAt,
    ));

    _sleepTimer = Timer(Duration(minutes: minutes), () async {
      _sleepTimer = null;
      if (state is! ReaderLoaded) return;
      final current = state as ReaderLoaded;
      if (current.isPlaying) await _audioCubit.pause();
      emit(current.copyWith(
        isPlaying: false,
        sleepTimerMinutes: 0,
        clearSleepTimer: true,
      ));
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  Future<void> close() async {
    _cancelSleepTimer();
    _audioStateSub?.cancel();
    _audioStateSub = null;
    _audioCubit.onSkipToNext = null;
    _audioCubit.onSkipToPrevious = null;
    _audioCubit.onChapterComplete = null;
    await _audioCubit.stop();
    return super.close();
  }

  /// Seek audio to position
  Future<void> seek(Duration position) async {
    if (state is! ReaderLoaded) return;
    final s = state as ReaderLoaded;
    if (!s.hasAudio || s.selectedAudio?.audioUrl == null) return;

    final posSec = position.inMilliseconds / 1000.0;

    // If audio is loaded in AudioPlayerCubit (playing or paused), seek there
    if (_audioCubit.isPlayingChapter(s.chapter.id) ||
        _audioCubit.getCurrentPositionForChapter(s.chapter.id) != null) {
      await _audioCubit.seek(position);
    } else {
      // Not yet loaded - update initial position for when user taps play
      emit(s.copyWith(
        initialAudioPositionSec: posSec,
        audioPosition: posSec,
      ));
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
