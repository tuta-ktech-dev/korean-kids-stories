import 'package:equatable/equatable.dart';
import '../../../data/models/chapter.dart';
import '../../../data/models/story.dart';

/// History item model - combines Story + Chapter + Progress
class HistoryItem extends Equatable {
  final String id;
  final Story story;
  final Chapter? chapter;
  final double percentRead;
  final bool isCompleted;
  final DateTime? lastReadAt;
  final Duration? lastPosition;

  const HistoryItem({
    required this.id,
    required this.story,
    this.chapter,
    this.percentRead = 0.0,
    this.isCompleted = false,
    this.lastReadAt,
    this.lastPosition,
  });

  @override
  List<Object?> get props => [
        id,
        story,
        chapter,
        percentRead,
        isCompleted,
        lastReadAt,
        lastPosition,
      ];

  String get displaySubtitle {
    if (chapter != null) {
      final chapterInfo = chapter!.title;
      if (isCompleted) {
        return '$chapterInfo • 100% 완료';
      }
      return '$chapterInfo • ${percentRead.toInt()}% 완료';
    }
    return '${percentRead.toInt()}% 완료';
  }

  String get timeAgo {
    if (lastReadAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastReadAt!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}주 전';
    } else {
      return '${(diff.inDays / 30).floor()}개월 전';
    }
  }
}

/// Reading stats
class ReadingStats extends Equatable {
  final int totalChaptersRead;
  final int completedChapters;
  final Duration totalReadingTime;
  final int currentStreak;
  final int longestStreak;

  const ReadingStats({
    this.totalChaptersRead = 0,
    this.completedChapters = 0,
    this.totalReadingTime = Duration.zero,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  @override
  List<Object?> get props => [
        totalChaptersRead,
        completedChapters,
        totalReadingTime,
        currentStreak,
        longestStreak,
      ];

  ReadingStats copyWith({
    int? totalChaptersRead,
    int? completedChapters,
    Duration? totalReadingTime,
    int? currentStreak,
    int? longestStreak,
  }) {
    return ReadingStats(
      totalChaptersRead: totalChaptersRead ?? this.totalChaptersRead,
      completedChapters: completedChapters ?? this.completedChapters,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryItem> items;
  final List<HistoryItem> completedItems;
  final List<HistoryItem> inProgressItems;
  final ReadingStats stats;

  const HistoryLoaded({
    required this.items,
    this.completedItems = const [],
    this.inProgressItems = const [],
    this.stats = const ReadingStats(),
  });

  @override
  List<Object?> get props => [
        items,
        completedItems,
        inProgressItems,
        stats,
      ];

  HistoryLoaded copyWith({
    List<HistoryItem>? items,
    List<HistoryItem>? completedItems,
    List<HistoryItem>? inProgressItems,
    ReadingStats? stats,
  }) {
    return HistoryLoaded(
      items: items ?? this.items,
      completedItems: completedItems ?? this.completedItems,
      inProgressItems: inProgressItems ?? this.inProgressItems,
      stats: stats ?? this.stats,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
