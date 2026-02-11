import 'package:pocketbase/pocketbase.dart';

import 'sticker.dart';

class UserSticker {
  final String id;
  final String userId;
  final String stickerId;
  final Sticker? sticker; // populated when expand=sticker
  final String unlockSource; // 'level_up' | 'story_complete'
  final DateTime? unlockedAt;

  UserSticker({
    required this.id,
    required this.userId,
    required this.stickerId,
    this.sticker,
    required this.unlockSource,
    this.unlockedAt,
  });

  factory UserSticker.fromRecord(
    RecordModel record, {
    required PocketBase pb,
  }) {
    Sticker? sticker;
    final expanded = record.get<List<RecordModel>>('expand.sticker');
    if (expanded.isNotEmpty) {
      sticker = Sticker.fromRecord(expanded.first, pb: pb);
    }

    return UserSticker(
      id: record.id,
      userId: record.getStringValue('user'),
      stickerId: record.getStringValue('sticker'),
      sticker: sticker,
      unlockSource: record.getStringValue('unlock_source'),
      unlockedAt: record.data['created'] != null
          ? DateTime.tryParse(record.data['created'].toString())
          : null,
    );
  }
}
