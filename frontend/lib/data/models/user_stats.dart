import 'package:pocketbase/pocketbase.dart';

class UserStats {
  final String id;
  final String userId;
  final double totalXp;
  final int level;
  final int streakDays;
  final String? lastActivityDate;
  final int chaptersRead;
  final int chaptersListened;
  final int storiesCompleted;

  UserStats({
    required this.id,
    required this.userId,
    this.totalXp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActivityDate,
    this.chaptersRead = 0,
    this.chaptersListened = 0,
    this.storiesCompleted = 0,
  });

  factory UserStats.fromRecord(RecordModel record) {
    return UserStats(
      id: record.id,
      userId: record.getStringValue('user'),
      totalXp: (record.data['total_xp'] as num?)?.toDouble() ?? 0,
      level: ((record.data['level'] as num?)?.toInt() ?? 1).clamp(1, 18),
      streakDays: (record.data['streak_days'] as num?)?.toInt() ?? 0,
      lastActivityDate: record.data['last_activity_date']?.toString(),
      chaptersRead: (record.data['chapters_read'] as num?)?.toInt() ?? 0,
      chaptersListened: (record.data['chapters_listened'] as num?)?.toInt() ?? 0,
      storiesCompleted: (record.data['stories_completed'] as num?)?.toInt() ?? 0,
    );
  }
}
