import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' as ja;

/// Audio handler for background playback with media controls.
/// Handles play, pause, seek, skip, and media session updates.
class StoryAudioHandler extends BaseAudioHandler with SeekHandler {
  final ja.AudioPlayer _player = ja.AudioPlayer();

  // Stream subscriptions
  StreamSubscription<ja.PlayerState>? _playerStateSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<ja.PlaybackEvent>? _playbackEventSub;
  StreamSubscription<List<ja.IndexedAudioSource>>? _sequenceStateSub;

  // Current chapter info for media item
  String _currentChapterId = '';
  String _currentStoryId = '';
  String _chapterTitle = '';
  String _storyTitle = '';
  String? _artworkUrl;
  String? _currentAudioUrl;

  // Position tracking for persistence
  DateTime _lastPositionUpdate = DateTime.now();
  DateTime _lastPlaybackStateUpdate = DateTime.now();
  final _positionUpdateController = StreamController<double>.broadcast();
  Stream<double> get positionUpdates => _positionUpdateController.stream;

  StoryAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Configure audio session for speech content
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Listen to audio interruptions (phone calls, other apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Audio interrupted - pause playback
        if (event.type == AudioInterruptionType.duck) {
          // Lower volume temporarily (optional)
          _player.setVolume(0.3);
        } else {
          pause();
        }
      } else {
        // Interruption ended - resume if was playing
        if (event.type == AudioInterruptionType.duck) {
          _player.setVolume(1.0);
        } else if (event.type == AudioInterruptionType.pause ||
            event.type == AudioInterruptionType.unknown) {
          // Only auto-resume if we were playing before
          if (_player.playing) {
            play();
          }
        }
      }
    });

    // Handle becoming noisy (headphones unplugged)
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });

    // Listen to player state changes
    _playerStateSub = _player.playerStateStream.listen((playerState) {
      _updatePlaybackState();
    });

    // Listen to duration changes
    _durationSub = _player.durationStream.listen((duration) {
      _updateMediaItem(duration: duration);
    });

    // Listen to position changes for persistence + progress bar updates
    _positionSub = _player.positionStream.listen((position) {
      final now = DateTime.now();
      // Update playbackState for progress bar (throttle to ~4 updates/sec)
      if (now.difference(_lastPlaybackStateUpdate).inMilliseconds >= 250) {
        _lastPlaybackStateUpdate = now;
        _updatePlaybackState();
      }
      // Persistence (throttle to 1 sec)
      if (now.difference(_lastPositionUpdate).inSeconds >= 1) {
        _lastPositionUpdate = now;
        if (_player.playing) {
          final duration = _player.duration;
          if (duration != null && duration.inMilliseconds > 0) {
            final progress = position.inMilliseconds / duration.inMilliseconds;
            _positionUpdateController.add(progress);
          }
        }
      }
    });

    // Listen to playback events for buffering state
    _playbackEventSub = _player.playbackEventStream.listen((event) {
      _updatePlaybackState();
    });

    // Set initial playback state
    _updatePlaybackState();
  }

  void _updatePlaybackState() {
    final playing = _player.playing;
    final processingState = _player.processingState;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: playing,
        processingState: _mapProcessingState(processingState),
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ja.ProcessingState state) {
    switch (state) {
      case ja.ProcessingState.idle:
        return AudioProcessingState.idle;
      case ja.ProcessingState.loading:
        return AudioProcessingState.loading;
      case ja.ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ja.ProcessingState.ready:
        return AudioProcessingState.ready;
      case ja.ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  void _updateMediaItem({Duration? duration}) {
    if (_currentChapterId.isEmpty) return;

    final effectiveDuration = duration ?? _player.duration ?? Duration.zero;

    mediaItem.add(
      MediaItem(
        id: _currentChapterId,
        album: _storyTitle.isNotEmpty ? _storyTitle : 'Korean Kids Stories',
        title: _chapterTitle.isNotEmpty ? _chapterTitle : 'Story',
        artist: 'Korean Kids Stories',
        duration: effectiveDuration,
        artUri: _artworkUrl != null ? Uri.parse(_artworkUrl!) : null,
        displayTitle: _chapterTitle,
        displaySubtitle: _storyTitle,
        extras: <String, dynamic>{
          'chapterId': _currentChapterId,
          'storyId': _currentStoryId,
          'url': _currentAudioUrl,
        },
      ),
    );
  }

  /// Load and prepare audio for playback
  Future<void> prepareAudio({
    required String chapterId,
    required String storyId,
    required String chapterTitle,
    required String storyTitle,
    required String audioUrl,
    String? artworkUrl,
    double initialPositionSeconds = 0.0,
  }) async {
    _currentChapterId = chapterId;
    _currentStoryId = storyId;
    _chapterTitle = chapterTitle;
    _storyTitle = storyTitle;
    _artworkUrl = artworkUrl;
    _currentAudioUrl = audioUrl;

    try {
      // Stop any current playback
      await _player.stop();

      // Brief pause to let platform fully release (avoids "Loading interrupted")
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Set new audio source
      await _player.setUrl(audioUrl);

      // Seek to initial position if provided
      if (initialPositionSeconds > 0) {
        await _player.seek(
          Duration(milliseconds: (initialPositionSeconds * 1000).round()),
        );
      }

      // Update media item
      _updateMediaItem();
      _updatePlaybackState();
    } catch (e) {
      print('[StoryAudioHandler] Error preparing audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
    _updatePlaybackState();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _updatePlaybackState();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _updatePlaybackState();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _updatePlaybackState();
  }

  @override
  Future<void> skipToNext() async {
    // Handled by the cubit
    _broadcastCustomAction('skipToNext');
  }

  @override
  Future<void> skipToPrevious() async {
    // Handled by the cubit
    _broadcastCustomAction('skipToPrevious');
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    // Not used for single-track playback
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    _updatePlaybackState();
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case 'setSpeed':
        final speed = extras?['speed'] as double? ?? 1.0;
        await setSpeed(speed);
        break;
      case 'seekForward':
        final seconds = extras?['seconds'] as int? ?? 10;
        await _seekRelative(Duration(seconds: seconds));
        break;
      case 'seekBackward':
        final seconds = extras?['seconds'] as int? ?? 10;
        await _seekRelative(Duration(seconds: -seconds));
        break;
      case 'setChapter':
        final chapterId = extras?['chapterId'] as String? ?? '';
        final storyId = extras?['storyId'] as String? ?? '';
        final chapterTitle = extras?['chapterTitle'] as String? ?? '';
        final storyTitle = extras?['storyTitle'] as String? ?? '';
        final audioUrl = extras?['audioUrl'] as String? ?? '';
        final artworkUrl = extras?['artworkUrl'] as String?;
        final initialPosition = extras?['initialPosition'] as double? ?? 0.0;

        await prepareAudio(
          chapterId: chapterId,
          storyId: storyId,
          chapterTitle: chapterTitle,
          storyTitle: storyTitle,
          audioUrl: audioUrl,
          artworkUrl: artworkUrl,
          initialPositionSeconds: initialPosition,
        );
        break;
    }
    return null;
  }

  Future<void> _seekRelative(Duration offset) async {
    final newPosition = _player.position + offset;
    final duration = _player.duration ?? Duration.zero;
    final clampedPosition = newPosition < Duration.zero
        ? Duration.zero
        : newPosition > duration
            ? duration
            : newPosition;
    await seek(clampedPosition);
  }

  void _broadcastCustomAction(String action) {
    // This will be listened to by the cubit
    customEvent.add({'action': action});
  }

  // Getters for external access
  ja.AudioPlayer get player => _player;
  String get currentChapterId => _currentChapterId;
  String get currentStoryId => _currentStoryId;
  String? get currentAudioUrl => _currentAudioUrl;

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
    await super.onNotificationDeleted();
  }

  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _durationSub?.cancel();
    await _positionSub?.cancel();
    await _playbackEventSub?.cancel();
    await _sequenceStateSub?.cancel();
    await _positionUpdateController.close();
    await _player.dispose();
  }
}
