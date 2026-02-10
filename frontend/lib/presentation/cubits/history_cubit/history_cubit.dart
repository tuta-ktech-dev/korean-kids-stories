import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/story_repository.dart';
import 'history_state.dart';
export 'history_state.dart';

/// Cubit for managing reading history
class HistoryCubit extends Cubit<HistoryState> {
  final ProgressRepository _progressRepo = ProgressRepository();
  final StoryRepository _storyRepo = StoryRepository();

  HistoryCubit() : super(const HistoryInitial());

  /// Load all reading history
  Future<void> loadHistory() async {
    emit(const HistoryLoading());

    try {
      // Get all progress from repository
      final progresses = await _progressRepo.getAllProgress();

      if (progresses.isEmpty) {
        emit(const HistoryLoaded(items: []));
        return;
      }

      // Build history items from progress
      final items = await _buildHistoryItems(progresses);

      // Calculate stats
      final stats = await _calculateStats(progresses);

      // Separate by status
      final completed = items.where((i) => i.isCompleted).toList();
      final inProgress = items.where((i) => !i.isCompleted).toList();

      emit(HistoryLoaded(
        items: items,
        completedItems: completed,
        inProgressItems: inProgress,
        stats: stats,
      ));
    } catch (e) {
      debugPrint('HistoryCubit.loadHistory error: $e');
      emit(HistoryError('Failed to load history: $e'));
    }
  }

  /// Build HistoryItem from ReadingProgress
  Future<List<HistoryItem>> _buildHistoryItems(
    List<ReadingProgress> progresses,
  ) async {
    final items = <HistoryItem>[];

    for (final progress in progresses) {
      try {
        // Get chapter info
        final chapter = await _storyRepo.getChapter(progress.chapterId);
        if (chapter == null) continue;

        // Get story info
        // Note: Chapter model currently doesn't have story relation
        // Need to fetch story from chapter or store storyId in progress
        // Temporarily use placeholder - need proper implementation

        final story = await _fetchStoryForChapter(chapter);
        if (story == null) continue;

        items.add(HistoryItem(
          id: progress.id,
          story: story,
          chapter: chapter,
          percentRead: progress.percentRead,
          isCompleted: progress.isCompleted,
          lastReadAt: progress.lastReadAt,
          lastPosition: Duration(milliseconds: progress.lastPosition.toInt()),
        ));
      } catch (e) {
        debugPrint('Error building history item: $e');
      }
    }

    // Sort by lastReadAt (newest first)
    items.sort((a, b) {
      if (a.lastReadAt == null && b.lastReadAt == null) return 0;
      if (a.lastReadAt == null) return 1;
      if (b.lastReadAt == null) return -1;
      return b.lastReadAt!.compareTo(a.lastReadAt!);
    });

    return items;
  }

  /// Fetch story for chapter
  /// Note: Need to update Chapter model to have story relation
  Future<Story?> _fetchStoryForChapter(Chapter chapter) async {
    try {
      // Temporarily return first story - need proper implementation
      final stories = await _storyRepo.getStories();
      if (stories.isNotEmpty) {
        return stories.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate reading stats
  Future<ReadingStats> _calculateStats(
    List<ReadingProgress> progresses,
  ) async {
    final completed = progresses.where((p) => p.isCompleted).length;

    // Calculate total reading time (estimate)
    // Assume ~5 minutes per chapter, based on percent_read
    var totalMinutes = 0.0;
    for (final p in progresses) {
      totalMinutes += (p.percentRead / 100) * 5; // 5 min per chapter estimate
    }

    // Calculate streak
    final streak = _calculateStreak(progresses);

    return ReadingStats(
      totalChaptersRead: progresses.length,
      completedChapters: completed,
      totalReadingTime: Duration(minutes: totalMinutes.round()),
      currentStreak: streak['current'] ?? 0,
      longestStreak: streak['longest'] ?? 0,
    );
  }

  /// Calculate reading streak
  Map<String, int> _calculateStreak(List<ReadingProgress> progresses) {
    if (progresses.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Get reading dates (without time)
    final readDates = progresses
        .where((p) => p.lastReadAt != null)
        .map((p) => DateTime(
              p.lastReadAt!.year,
              p.lastReadAt!.month,
              p.lastReadAt!.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    if (readDates.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (readDates.first == todayDate || readDates.first == yesterday) {
      currentStreak = 1;
      for (int i = 1; i < readDates.length; i++) {
        final expectedDate = readDates[i - 1].subtract(const Duration(days: 1));
        if (readDates[i] == expectedDate) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 1;
    int currentRun = 1;
    for (int i = 1; i < readDates.length; i++) {
      final diff = readDates[i - 1].difference(readDates[i]).inDays;
      if (diff == 1) {
        currentRun++;
        if (currentRun > longestStreak) {
          longestStreak = currentRun;
        }
      } else if (diff > 1) {
        currentRun = 1;
      }
    }

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  /// Refresh history
  Future<void> refresh() async {
    await loadHistory();
  }

  /// Remove an item from history (delete progress)
  Future<void> removeFromHistory(String progressId) async {
    if (state is! HistoryLoaded) return;

    final current = state as HistoryLoaded;

    try {
      final success = await _progressRepo.deleteProgress(progressId);
      if (success) {
        final newItems = current.items.where((i) => i.id != progressId).toList();
        final newCompleted = newItems.where((i) => i.isCompleted).toList();
        final newInProgress = newItems.where((i) => !i.isCompleted).toList();

        emit(current.copyWith(
          items: newItems,
          completedItems: newCompleted,
          inProgressItems: newInProgress,
        ));
      }
    } catch (e) {
      debugPrint('HistoryCubit.removeFromHistory error: $e');
    }
  }

  /// Continue reading - get most recent incomplete item
  HistoryItem? getContinueReading() {
    if (state is! HistoryLoaded) return null;

    final current = state as HistoryLoaded;
    final inProgress = current.inProgressItems;

    if (inProgress.isEmpty) return null;

    // Return most recent incomplete item
    return inProgress.first;
  }
}
