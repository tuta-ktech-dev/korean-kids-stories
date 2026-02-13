import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/notification/notification_service.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/reading_history_repository.dart';
import '../../../injection.dart';
import 'progress_state.dart';

/// Global cubit for reading progress persistence.
/// Used by Reader (save on scroll/dispose), History, Library, etc.
@lazySingleton
class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    ProgressRepository? progressRepository,
    ReadingHistoryRepository? readingHistoryRepository,
  })  : _repo = progressRepository ?? getIt<ProgressRepository>(),
        _historyRepo =
            readingHistoryRepository ?? getIt<ReadingHistoryRepository>(),
        super(const ProgressInitial());

  final ProgressRepository _repo;
  final ReadingHistoryRepository _historyRepo;

  /// Get progress for a chapter (for initial load, History, etc.)
  Future<ReadingProgress?> getProgress(String chapterId) async {
    return _repo.getProgress(chapterId);
  }

  /// Persist progress. No emit - Reader gets progress from scroll.
  /// [storyId] - optional, when provided also logs to reading_history.
  /// [durationSeconds] - optional, reading time to log to reading_history.
  Future<void> saveProgress({
    required String chapterId,
    required double percentRead,
    double? lastPosition,
    bool? isCompleted,
    String? storyId,
    int? durationSeconds,
  }) async {
    await _repo.saveProgress(
      chapterId: chapterId,
      percentRead: percentRead,
      lastPosition: lastPosition,
      isCompleted: isCompleted,
      durationSeconds: durationSeconds,
    );

    // Mark "read today" for reminder notification (only show if no streak)
    await NotificationService.markReadToday();

    if (storyId != null && storyId.isNotEmpty) {
      _historyRepo.logAction(
        storyId: storyId,
        chapterId: chapterId,
        action: isCompleted == true ? 'complete' : 'read',
        progressPercent: percentRead,
        durationSeconds: durationSeconds,
      );
    }
  }
}
