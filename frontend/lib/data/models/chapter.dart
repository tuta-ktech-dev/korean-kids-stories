import 'package:pocketbase/pocketbase.dart';

/// Represents a word timing entry for audio-text synchronization
class WordTiming {
  final String word;
  final double startTime;
  final double endTime;

  WordTiming({
    required this.word,
    required this.startTime,
    required this.endTime,
  });

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'] as String? ?? '',
      startTime: (json['start_time'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['end_time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class Chapter {
  final String id;
  final String storyId;
  final String title;
  final int chapterNumber;
  final String content;
  final String? audioUrl;
  final double audioDuration;
  final bool isFree;
  final List<String> illustrations;
  final List<WordTiming> wordTimings;
  final DateTime created;
  final DateTime updated;

  Chapter({
    required this.id,
    required this.storyId,
    required this.title,
    required this.chapterNumber,
    required this.content,
    this.audioUrl,
    this.audioDuration = 0.0,
    required this.isFree,
    this.illustrations = const [],
    this.wordTimings = const [],
    required this.created,
    required this.updated,
  });

  factory Chapter.fromRecord(RecordModel record, {String baseUrl = ''}) {
    final audioFile = record.getStringValue('audio_file');

    // Parse word_timings from the record
    List<WordTiming> timings = [];
    final wordTimingsData = record.data['word_timings'];
    if (wordTimingsData != null && wordTimingsData is List) {
      timings = wordTimingsData
          .whereType<Map<String, dynamic>>()
          .map((json) => WordTiming.fromJson(json))
          .toList();
    }

    return Chapter(
      id: record.id,
      storyId: record.getStringValue('story'),
      title: record.getStringValue('title'),
      chapterNumber: record.getIntValue('chapter_number'),
      content: record.getStringValue('content'),
      audioUrl: audioFile.isNotEmpty
          ? '$baseUrl/api/files/${record.collectionId}/${record.id}/$audioFile'
          : null,
      audioDuration: record.getDoubleValue('audio_duration'),
      isFree: record.getBoolValue('is_free'),
      illustrations: record.getListValue<String>('illustrations'),
      wordTimings: timings,
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  Chapter copyWith({
    String? id,
    String? storyId,
    String? title,
    int? chapterNumber,
    String? content,
    String? audioUrl,
    double? audioDuration,
    bool? isFree,
    List<String>? illustrations,
    List<WordTiming>? wordTimings,
    DateTime? created,
    DateTime? updated,
  }) {
    return Chapter(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      isFree: isFree ?? this.isFree,
      illustrations: illustrations ?? this.illustrations,
      wordTimings: wordTimings ?? this.wordTimings,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
