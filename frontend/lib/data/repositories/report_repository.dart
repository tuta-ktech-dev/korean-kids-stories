import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../services/pocketbase_service.dart';

/// Repository for submitting reports (reports collection)
@injectable
class ReportRepository {
  ReportRepository(this._pbService);
  final PocketbaseService _pbService;

  /// Submit a report. Requires user to be authenticated.
  Future<bool> submitReport({
    required String type,
    required String reason,
    required String targetId,
    String? targetTitle,
  }) async {
    try {
      if (!_pbService.isAuthenticated) return false;

      final userId = _pbService.currentUser?.id;
      if (userId == null) return false;

      await _pbService.pb.collection('reports').create(body: {
        'user': userId,
        'type': type,
        'target_id': targetId,
        'reason': reason,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      debugPrint('ReportRepository.submitReport error: $e');
      return false;
    }
  }
}
