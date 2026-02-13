import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/audio_handler.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../injection.dart';
import 'audio_player_state.dart';
export 'audio_player_state.dart';

/// Default playback speed for kids (slower = easier to follow)
const double _defaultPlaybackSpeed = 0.85;

/// Global cubit for audio playback with background support.
/// Manages audio state across the app using AudioService.
@lazySingleton
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  AudioPlayerCubit({ProgressRepository? progressRepository})
    : _progressRepository = progressRepository ?? getIt<ProgressRepository>(),
      super(const AudioPlayerInitial()) {
    _init();
  }

  final ProgressRepository _progressRepository;

  StoryAudioHandler? _audioHandler;
  StreamSubscription<PlaybackState>? _playbackStateSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;
  StreamSubscription<double>? _positionUpdateSub;
  StreamSubscription<dynamic>? _customEventSub;

  // Callbacks for chapter navigation
  VoidCallback? onSkipToNext;
  VoidCallback? onSkipToPrevious;

  /// When playback completes naturally (track ended)
  VoidCallback? onChapterComplete;

  Future<void> _init() async {
    try {
      emit(const AudioPlayerLoading());

      // Get the audio handler instance
      _audioHandler = await AudioService.init(
        builder: () => StoryAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.korean_kids_stories.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
          notificationColor: Color(0xFFFF6B9D), // Primary pink color
          artDownscaleWidth: 300,
          artDownscaleHeight: 300,
        ),
      );

      // Listen to playback state changes
      _playbackStateSub = _audioHandler?.playbackState.listen((playbackState) {
        _handlePlaybackStateChange(playbackState);
      });

      // Listen to media item changes
      _mediaItemSub = _audioHandler?.mediaItem.listen((mediaItem) {
        _handleMediaItemChange(mediaItem);
      });

      // Listen to position updates for persistence
      _positionUpdateSub = _audioHandler?.positionUpdates.listen((progress) {
        _handlePositionUpdate(progress);
      });

      // Listen to custom events (skip actions)
      _customEventSub = _audioHandler?.customEvent.listen((event) {
        _handleCustomEvent(event);
      });

      emit(const AudioPlayerReady());
    } catch (e) {
      debugPrint('[AudioPlayerCubit] Init error: $e');
      emit(AudioPlayerError('Failed to initialize audio: $e'));
    }
  }

  void _handlePlaybackStateChange(PlaybackState playbackState) {
    if (state is! AudioPlayerReady) return;

    final currentState = state as AudioPlayerReady;
    final playerState = _audioHandler?.player.playerState;

    emit(
      currentState.copyWith(
        isPlaying: playbackState.playing,
        position: playbackState.updatePosition,
        bufferedPosition: playbackState.bufferedPosition,
        speed: playbackState.speed,
        isBuffering:
            playerState?.processingState == ProcessingState.buffering ||
            playerState?.processingState == ProcessingState.loading,
      ),
    );

    // Handle completion
    if (playerState?.processingState == ProcessingState.completed) {
      _onPlaybackCompleted();
    }
  }

  void _handleMediaItemChange(MediaItem? mediaItem) {
    if (mediaItem == null || state is! AudioPlayerReady) return;

    final currentState = state as AudioPlayerReady;
    emit(
      currentState.copyWith(
        chapterId: mediaItem.id,
        storyId: mediaItem.extras?['storyId'] as String? ?? '',
        chapterTitle: mediaItem.title,
        storyTitle: mediaItem.album ?? '',
        audioUrl: mediaItem.extras?['url'] as String?,
        duration: mediaItem.duration ?? Duration.zero,
      ),
    );
  }

  Future<void> _handlePositionUpdate(double progress) async {
    if (state is! AudioPlayerReady) return;

    final currentState = state as AudioPlayerReady;
    if (currentState.chapterId.isEmpty) return;

    // Calculate position in milliseconds
    final durationMs = currentState.duration.inMilliseconds;
    final positionMs = (progress * durationMs).round();

    // Save progress every few seconds
    try {
      await _progressRepository.saveProgress(
        chapterId: currentState.chapterId,
        percentRead: (progress * 100).clamp(0.0, 100.0),
        lastPosition: positionMs.toDouble(),
        isCompleted: progress >= 0.99,
      );
    } catch (e) {
      debugPrint('[AudioPlayerCubit] Error saving progress: $e');
    }
  }

  void _handleCustomEvent(Map<String, dynamic> event) {
    final action = event['action'] as String?;
    switch (action) {
      case 'skipToNext':
        onSkipToNext?.call();
        break;
      case 'skipToPrevious':
        onSkipToPrevious?.call();
        break;
    }
  }

  void _onPlaybackCompleted() {
    if (state is! AudioPlayerReady) return;

    final currentState = state as AudioPlayerReady;

    // Save 100% completion
    _progressRepository.saveProgress(
      chapterId: currentState.chapterId,
      percentRead: 100.0,
      lastPosition: currentState.duration.inMilliseconds.toDouble(),
      isCompleted: true,
    );

    onChapterComplete?.call();
  }

  /// Load and play a chapter's audio
  Future<void> loadChapter({
    required String chapterId,
    required String storyId,
    required String chapterTitle,
    required String storyTitle,
    required String audioUrl,
    String? artworkUrl,
    double initialPositionSeconds = 0.0,
  }) async {
    try {
      if (state is AudioPlayerInitial) {
        await _init();
      }

      if (_audioHandler == null) {
        emit(const AudioPlayerError('Audio service not available'));
        return;
      }

      // Update state with loading info
      if (state is AudioPlayerReady) {
        emit((state as AudioPlayerReady).copyWith(isBuffering: true));
      }

      // Prepare audio in the handler
      await _audioHandler?.prepareAudio(
        chapterId: chapterId,
        storyId: storyId,
        chapterTitle: chapterTitle,
        storyTitle: storyTitle,
        audioUrl: audioUrl,
        artworkUrl: artworkUrl,
        initialPositionSeconds: initialPositionSeconds,
      );

      // Set default speed for kids
      await _audioHandler?.setSpeed(_defaultPlaybackSpeed);

      debugPrint('[AudioPlayerCubit] Loaded chapter: $chapterTitle');
    } catch (e) {
      debugPrint('[AudioPlayerCubit] Error loading chapter: $e');
      if (state is AudioPlayerReady) {
        emit(
          (state as AudioPlayerReady).copyWith(
            error: 'Failed to load audio: $e',
          ),
        );
      }
      rethrow;
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioHandler == null) return;

    final isPlaying =
        state is AudioPlayerReady && (state as AudioPlayerReady).isPlaying;

    if (isPlaying) {
      await _audioHandler?.pause();
    } else {
      await _audioHandler?.play();
    }
  }

  /// Start playback
  Future<void> play() async {
    await _audioHandler?.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioHandler?.pause();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioHandler?.stop();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioHandler?.seek(position);
  }

  /// Seek relative to current position (forward/backward)
  Future<void> seekRelative(Duration offset) async {
    if (state is! AudioPlayerReady) return;

    final currentState = state as AudioPlayerReady;
    final newPosition = currentState.position + offset;
    final duration = currentState.duration;
    final clampedPosition = newPosition < Duration.zero
        ? Duration.zero
        : newPosition > duration
        ? duration
        : newPosition;
    await seek(clampedPosition);
  }

  /// Skip forward by specified seconds
  Future<void> skipForward([int seconds = 10]) async {
    await seekRelative(Duration(seconds: seconds));
  }

  /// Skip backward by specified seconds
  Future<void> skipBackward([int seconds = 10]) async {
    await seekRelative(Duration(seconds: -seconds));
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _audioHandler?.setSpeed(speed);
    if (state is AudioPlayerReady) {
      emit((state as AudioPlayerReady).copyWith(speed: speed));
    }
  }

  /// Check if currently playing a specific chapter
  bool isPlayingChapter(String chapterId) {
    if (state is! AudioPlayerReady) return false;
    final currentState = state as AudioPlayerReady;
    return currentState.chapterId == chapterId && currentState.isPlaying;
  }

  /// Get current position for a chapter
  double? getCurrentPositionForChapter(String chapterId) {
    if (state is! AudioPlayerReady) return null;
    final currentState = state as AudioPlayerReady;
    if (currentState.chapterId == chapterId) {
      return currentState.position.inMilliseconds / 1000.0;
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _playbackStateSub?.cancel();
    await _mediaItemSub?.cancel();
    await _positionUpdateSub?.cancel();
    await _customEventSub?.cancel();
    await _audioHandler?.dispose();
    return super.close();
  }
}
