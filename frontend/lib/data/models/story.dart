import 'package:pocketbase/pocketbase.dart';

class Story {
  final String id;
  final String title;
  final String category;
  final int ageMin;
  final int ageMax;
  final String? thumbnailUrl;
  final String summary;
  final int totalChapters;
  final List<String> tags;
  final bool isPublished;
  final bool isFeatured;
  final bool hasAudio;
  final bool hasQuiz;
  final bool hasIllustrations;
  final double? averageRating;
  final int reviewCount;
  final int viewCount;
  final DateTime created;
  final DateTime updated;

  Story({
    required this.id,
    required this.title,
    required this.category,
    required this.ageMin,
    required this.ageMax,
    this.thumbnailUrl,
    required this.summary,
    required this.totalChapters,
    required this.tags,
    required this.isPublished,
    this.isFeatured = false,
    this.hasAudio = false,
    this.hasQuiz = false,
    this.hasIllustrations = false,
    this.averageRating,
    this.reviewCount = 0,
    this.viewCount = 0,
    required this.created,
    required this.updated,
  });

  factory Story.fromRecord(RecordModel record, {required PocketBase pb}) {
    // Handle 'thumbnail' field which can be a single filename (String) or a list of filenames
    String? thumbnailFilename;
    final thumbnailData = record.data['thumbnail'];

    if (thumbnailData is String && thumbnailData.isNotEmpty) {
      thumbnailFilename = thumbnailData;
    } else if (thumbnailData is List && thumbnailData.isNotEmpty) {
      thumbnailFilename = thumbnailData.first.toString();
    }

    return Story(
      id: record.id,
      title: record.getStringValue('title'),
      category: record.getStringValue('category'),
      ageMin: record.getIntValue('age_min'),
      ageMax: record.getIntValue('age_max'),
      thumbnailUrl: thumbnailFilename != null && thumbnailFilename.isNotEmpty
          ? pb.files.getUrl(record, thumbnailFilename).toString()
          : null,
      summary: record.getStringValue('summary'),
      totalChapters: record.getIntValue('total_chapters'),
      tags: List<String>.from(record.getListValue('tags')),
      isPublished: record.getBoolValue('is_published'),
      isFeatured: record.getBoolValue('is_featured'),
      hasAudio: record.getBoolValue('has_audio'),
      hasQuiz: record.getBoolValue('has_quiz'),
      hasIllustrations: record.getBoolValue('has_illustrations'),
      averageRating: record.data['average_rating'] != null
          ? (record.data['average_rating'] as num).toDouble()
          : null,
      reviewCount: record.getIntValue('review_count'),
      viewCount: record.getIntValue('view_count'),
      created: _parseDateTime(record.data['created']),
      updated: _parseDateTime(record.data['updated']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
