import 'package:equatable/equatable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';
import '../../../data/models/story.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

class ReaderLoading extends ReaderState {
  const ReaderLoading();
}

class ReaderLoaded extends ReaderState {
  final Chapter chapter;
  final Story? story; // For hasQuiz, category, title
  /// Previous chapter in the story, if any.
  final Chapter? prevChapter;
  /// Next chapter in the story (free), if any.
  final Chapter? nextChapter;
  /// Next chapter bị khóa (để hiện nút mở khóa thay vì chuyển chapter).
  final Chapter? nextChapterLocked;
  /// Multiple audio versions (different voices). Empty if no audio.
  final List<ChapterAudio> audios;
  /// Selected voice for playback. First item if audios not empty.
  final ChapterAudio? selectedAudio;
  final double fontSize;
  /// Reading scroll progress (0-1). Used when no audio or for scroll restore.
  final double progress;
  final bool isPlaying;
  /// Current audio position in seconds. When set, bottom bar shows audio progress.
  final double? audioPosition;
  /// Actual duration from player (when model has 0).
  final double? audioDurationSeconds;
  /// Playback speed for audio (0.75-1.0). Default 0.85 for kids.
  final double playbackSpeed;
  /// Error message when playback fails (show SnackBar, then clear).
  final String? playbackError;
  /// Seek to this position (seconds) when user hits play (from saved progress).
  final double? initialAudioPositionSec;
  /// Sleep timer: 0 = off, else minutes until auto-pause.
  final int sleepTimerMinutes;
  /// When sleep timer ends. null when off.
  final DateTime? sleepTimerEndsAt;
  /// Free daily audio limit reached - show upgrade dialog.
  final bool freeLimitReached;

  const ReaderLoaded({
    required this.chapter,
    this.story,
    this.prevChapter,
    this.nextChapter,
    this.nextChapterLocked,
    this.audios = const [],
    this.selectedAudio,
    this.fontSize = 22,
    this.progress = 0.0,
    this.isPlaying = false,
    this.audioPosition,
    this.audioDurationSeconds,
    this.playbackSpeed = 0.85,
    this.playbackError,
    this.initialAudioPositionSec,
    this.sleepTimerMinutes = 0,
    this.sleepTimerEndsAt,
    this.freeLimitReached = false,
  });

  bool get hasAudio => audios.isNotEmpty;

  bool get hasSleepTimer => sleepTimerMinutes > 0;

  /// Last chapter of story (no next free, no next locked).
  bool get isLastChapterOfStory =>
      nextChapter == null && nextChapterLocked == null;

  /// Progress to show in bottom bar: audio position when hasAudio, else scroll.
  /// When hasAudio, never show scroll - use 0 if not yet played.
  double get displayProgress {
    if (hasAudio) {
      final pos = audioPosition ?? initialAudioPositionSec ?? 0.0;
      final dur = audioDurationSeconds ?? selectedAudio?.audioDuration ?? 1.0;
      if (dur > 0) return (pos / dur).clamp(0.0, 1.0);
      return 0.0;
    }
    return progress;
  }

  ReaderLoaded copyWith({
    Chapter? chapter,
    Story? story,
    Chapter? prevChapter,
    Chapter? nextChapter,
    Chapter? nextChapterLocked,
    List<ChapterAudio>? audios,
    ChapterAudio? selectedAudio,
    double? fontSize,
    double? progress,
    bool? isPlaying,
    double? audioPosition,
    bool clearAudioPosition = false,
    double? audioDurationSeconds,
    double? playbackSpeed,
    String? playbackError,
    bool clearPlaybackError = false,
    double? initialAudioPositionSec,
    bool clearInitialAudioPosition = false,
    int? sleepTimerMinutes,
    DateTime? sleepTimerEndsAt,
    bool clearSleepTimer = false,
    bool? freeLimitReached,
  }) {
    return ReaderLoaded(
      chapter: chapter ?? this.chapter,
      story: story ?? this.story,
      prevChapter: prevChapter ?? this.prevChapter,
      nextChapter: nextChapter ?? this.nextChapter,
      nextChapterLocked: nextChapterLocked ?? this.nextChapterLocked,
      audios: audios ?? this.audios,
      selectedAudio: selectedAudio ?? this.selectedAudio,
      fontSize: fontSize ?? this.fontSize,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      audioPosition: clearAudioPosition ? null : (audioPosition ?? this.audioPosition),
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      playbackError: clearPlaybackError ? null : (playbackError ?? this.playbackError),
      initialAudioPositionSec: clearInitialAudioPosition ? null : (initialAudioPositionSec ?? this.initialAudioPositionSec),
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
      sleepTimerEndsAt: clearSleepTimer || (sleepTimerMinutes ?? this.sleepTimerMinutes) == 0
          ? null
          : (sleepTimerEndsAt ?? this.sleepTimerEndsAt),
      freeLimitReached: freeLimitReached ?? this.freeLimitReached,
    );
  }

  @override
  List<Object?> get props => [chapter, story, prevChapter, nextChapter, nextChapterLocked, audios, selectedAudio, fontSize, progress, isPlaying, audioPosition, audioDurationSeconds, playbackSpeed, playbackError, initialAudioPositionSec, sleepTimerMinutes, sleepTimerEndsAt, freeLimitReached];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
