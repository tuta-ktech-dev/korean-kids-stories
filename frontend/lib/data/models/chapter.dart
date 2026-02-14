import 'package:pocketbase/pocketbase.dart';

/// Chapter model. Audio versions (multiple voices) are in chapter_audios collection.
/// [isPremium] is added by API when X-Device-ID has verified IAP (backend source of truth).
class Chapter {
  final String id;
  final String storyId;
  final String title;
  final int chapterNumber;
  final String content;
  final bool isFree;
  final List<String> illustrations;
  final DateTime created;
  final DateTime updated;
  /// From API when device has verified premium purchase. Null if not present.
  final bool? isPremium;

  Chapter({
    required this.id,
    required this.storyId,
    required this.title,
    required this.chapterNumber,
    required this.content,
    required this.isFree,
    this.illustrations = const [],
    required this.created,
    required this.updated,
    this.isPremium,
  });

  factory Chapter.fromRecord(RecordModel record, {String baseUrl = ''}) {
    return Chapter(
      id: record.id,
      storyId: record.getStringValue('story'),
      title: record.getStringValue('title'),
      chapterNumber: record.getIntValue('chapter_number'),
      content: record.getStringValue('content'),
      isFree: record.getBoolValue('is_free'),
      illustrations: record.getListValue<String>('illustrations'),
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
      isPremium: record.data['is_premium'] as bool?,
    );
  }

  Chapter copyWith({
    String? id,
    String? storyId,
    String? title,
    int? chapterNumber,
    String? content,
    bool? isFree,
    List<String>? illustrations,
    DateTime? created,
    DateTime? updated,
    bool? isPremium,
  }) {
    return Chapter(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: content ?? this.content,
      isFree: isFree ?? this.isFree,
      illustrations: illustrations ?? this.illustrations,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
