import 'package:equatable/equatable.dart';

import '../../../data/models/chapter.dart';
import '../../../data/models/chapter_audio.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => [];
}

class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

class ReaderLoading extends ReaderState {
  const ReaderLoading();
}

class ReaderLoaded extends ReaderState {
  final Chapter chapter;
  /// Previous chapter in the story, if any.
  final Chapter? prevChapter;
  /// Next chapter in the story (free), if any.
  final Chapter? nextChapter;
  /// Next chapter bị khóa (để hiện nút mở khóa thay vì chuyển chapter).
  final Chapter? nextChapterLocked;
  /// Multiple audio versions (different voices). Empty if no audio.
  final List<ChapterAudio> audios;
  /// Selected voice for playback. First item if audios not empty.
  final ChapterAudio? selectedAudio;
  final double fontSize;
  final bool isDarkMode;
  final double progress;
  final bool isPlaying;

  const ReaderLoaded({
    required this.chapter,
    this.prevChapter,
    this.nextChapter,
    this.nextChapterLocked,
    this.audios = const [],
    this.selectedAudio,
    this.fontSize = 22,
    this.isDarkMode = false,
    this.progress = 0.0,
    this.isPlaying = false,
  });

  bool get hasAudio => audios.isNotEmpty;

  ReaderLoaded copyWith({
    Chapter? chapter,
    Chapter? prevChapter,
    Chapter? nextChapter,
    Chapter? nextChapterLocked,
    List<ChapterAudio>? audios,
    ChapterAudio? selectedAudio,
    double? fontSize,
    bool? isDarkMode,
    double? progress,
    bool? isPlaying,
  }) {
    return ReaderLoaded(
      chapter: chapter ?? this.chapter,
      prevChapter: prevChapter ?? this.prevChapter,
      nextChapter: nextChapter ?? this.nextChapter,
      nextChapterLocked: nextChapterLocked ?? this.nextChapterLocked,
      audios: audios ?? this.audios,
      selectedAudio: selectedAudio ?? this.selectedAudio,
      fontSize: fontSize ?? this.fontSize,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [chapter, prevChapter, nextChapter, nextChapterLocked, audios, selectedAudio, fontSize, isDarkMode, progress, isPlaying];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object?> get props => [message];
}
