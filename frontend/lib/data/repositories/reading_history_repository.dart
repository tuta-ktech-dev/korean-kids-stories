import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../services/pocketbase_service.dart';

/// Logs reading events to reading_history collection for analytics.
@injectable
class ReadingHistoryRepository {
  ReadingHistoryRepository(this._pbService);
  final PocketbaseService _pbService;

  PocketBase get _pb => _pbService.pb;

  /// Log a reading action. Requires auth. Silently ignores errors.
  Future<void> logAction({
    required String storyId,
    String? chapterId,
    required String action, // 'view', 'read', 'listen', 'complete'
    int? durationSeconds,
    double? progressPercent,
  }) async {
    try {
      if (!_pbService.isAuthenticated) return;
      final userId = _pbService.currentUser?.id;
      if (userId == null) return;

      final validActions = ['view', 'read', 'listen', 'complete'];
      if (!validActions.contains(action)) return;

      final body = <String, dynamic>{
        'user': userId,
        'story': storyId,
        'action': action,
      };
      if (chapterId != null && chapterId.isNotEmpty) {
        body['chapter'] = chapterId;
      }
      if (durationSeconds != null) {
        body['duration_seconds'] = durationSeconds;
      }
      if (progressPercent != null &&
          !progressPercent.isNaN &&
          !progressPercent.isInfinite) {
        body['progress_percent'] = progressPercent.clamp(0.0, 100.0);
      }

      await _pb.collection('reading_history').create(body: body);
    } catch (e) {
      debugPrint('ReadingHistoryRepository.logAction error: $e');
    }
  }
}
