import 'package:equatable/equatable.dart';

/// Audio player states
abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object?> get props => [];
}

class AudioPlayerInitial extends AudioPlayerState {
  const AudioPlayerInitial();
}

class AudioPlayerLoading extends AudioPlayerState {
  const AudioPlayerLoading();
}

class AudioPlayerReady extends AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double speed;
  final bool isBuffering;
  final String? error;
  
  // Current track info
  final String chapterId;
  final String storyId;
  final String chapterTitle;
  final String storyTitle;
  final String? audioUrl;

  const AudioPlayerReady({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 0.85,
    this.isBuffering = false,
    this.error,
    this.chapterId = '',
    this.storyId = '',
    this.chapterTitle = '',
    this.storyTitle = '',
    this.audioUrl,
  });

  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  double get bufferedProgress => duration.inMilliseconds > 0
      ? bufferedPosition.inMilliseconds / duration.inMilliseconds
      : 0.0;

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  bool get isCompleted => position >= duration && duration > Duration.zero;

  AudioPlayerReady copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    bool? isBuffering,
    String? error,
    bool clearError = false,
    String? chapterId,
    String? storyId,
    String? chapterTitle,
    String? storyTitle,
    String? audioUrl,
  }) {
    return AudioPlayerReady(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      isBuffering: isBuffering ?? this.isBuffering,
      error: clearError ? null : (error ?? this.error),
      chapterId: chapterId ?? this.chapterId,
      storyId: storyId ?? this.storyId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      storyTitle: storyTitle ?? this.storyTitle,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  List<Object?> get props => [
        isPlaying,
        position,
        duration,
        bufferedPosition,
        speed,
        isBuffering,
        error,
        chapterId,
        storyId,
        chapterTitle,
        storyTitle,
        audioUrl,
      ];
}

class AudioPlayerError extends AudioPlayerState {
  final String message;

  const AudioPlayerError(this.message);

  @override
  List<Object?> get props => [message];
}
