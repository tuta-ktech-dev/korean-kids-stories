import 'package:equatable/equatable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';

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

  const ReaderLoaded({
    required this.chapter,
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
  });

  bool get hasAudio => audios.isNotEmpty;

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
  }) {
    return ReaderLoaded(
      chapter: chapter ?? this.chapter,
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
    );
  }

  @override
  List<Object?> get props => [chapter, prevChapter, nextChapter, nextChapterLocked, audios, selectedAudio, fontSize, progress, isPlaying, audioPosition, audioDurationSeconds, playbackSpeed, playbackError, initialAudioPositionSec];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
