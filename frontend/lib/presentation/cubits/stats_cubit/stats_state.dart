import 'package:equatable/equatable.dart';

import '../../../data/models/sticker.dart';
import '../../../data/models/user_stats.dart';
import '../../../data/models/user_sticker.dart';

class StatsState extends Equatable {
  final UserStats? stats;
  final List<UserSticker> unlockedStickers;
  final List<Sticker> levelStickers;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.stats,
    this.unlockedStickers = const [],
    this.levelStickers = const [],
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    UserStats? stats,
    List<UserSticker>? unlockedStickers,
    List<Sticker>? levelStickers,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      levelStickers: levelStickers ?? this.levelStickers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [stats, unlockedStickers, levelStickers, isLoading, error];
}
