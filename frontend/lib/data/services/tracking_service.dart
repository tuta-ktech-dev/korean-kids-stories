import 'dart:math';

import 'package:flutter/foundation.dart';

/// Simple analytics tracking service
class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  String? _sessionId;
  String? _userId;
  DateTime? _sessionStart;

  String get sessionId {
    _sessionId ??= _generateSessionId();
    return _sessionId!;
  }

  void startSession(String? userId) {
    _userId = userId;
    _sessionStart = DateTime.now();
    _sessionId = _generateSessionId();
    
    // Track app open
    trackEvent('app_open');
  }

  void endSession() {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!).inSeconds;
      trackEvent('app_close', data: {'session_duration_seconds': duration});
    }
  }

  void setUserId(String? userId) {
    _userId = userId;
  }

  // Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    trackEvent('screen_view', 
      screenName: screenName,
      data: parameters,
    );
  }

  // Track button click
  void trackButtonClick(String buttonName, {Map<String, dynamic>? data}) {
    trackEvent('button_click',
      buttonName: buttonName,
      data: data,
    );
  }

  // Track story events
  void trackStoryView(String storyId, String storyTitle) {
    trackEvent('story_view',
      data: {'story_id': storyId, 'story_title': storyTitle},
    );
  }

  void trackStoryFavorite(String storyId) {
    trackEvent('story_favorite', data: {'story_id': storyId});
  }

  void trackStoryShare(String storyId, String platform) {
    trackEvent('story_share', 
      data: {'story_id': storyId, 'platform': platform},
    );
  }

  void trackStoryDownload(String storyId) {
    trackEvent('download', data: {'story_id': storyId, 'type': 'story'});
  }

  // Track reading progress
  void trackReadingProgress({
    required String storyId,
    String? chapterId,
    required String action, // 'view', 'read', 'listen', 'complete'
    int? durationSeconds,
    double? progressPercent,
  }) {
    // TODO: Send to backend reading_history collection
    trackEvent('reading_progress', data: {
      'story_id': storyId,
      'chapter_id': chapterId,
      'action': action,
      'duration_seconds': durationSeconds,
      'progress_percent': progressPercent,
    });
  }

  // Track listening session
  void trackListeningSession({
    required String chapterId,
    required int startPosition,
    required int endPosition,
    required int durationListened,
    bool completed = false,
  }) {
    trackEvent('listening_session', data: {
      'chapter_id': chapterId,
      'start_position': startPosition,
      'end_position': endPosition,
      'duration_listened': durationListened,
      'completed': completed,
    });
  }

  // Track search
  void trackSearch({
    required String query,
    String searchType = 'general',
    int? resultsCount,
    bool clickedResult = false,
  }) {
    trackEvent('search', data: {
      'query': query,
      'search_type': searchType,
      'results_count': resultsCount,
      'clicked_result': clickedResult,
    });
  }

  // Track generic event
  void trackEvent(String eventType, {
    String? screenName,
    String? buttonName,
    Map<String, dynamic>? data,
  }) {
    final event = {
      'event_type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': sessionId,
      'user_id': _userId,
      'screen_name': screenName,
      'button_name': buttonName,
      'data': data,
    };

    // TODO: Send to backend
    if (kDebugMode) {
      debugPrint('[TRACK] $event');
    }
  }

  String _generateSessionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
