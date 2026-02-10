import 'package:equatable/equatable.dart';

import '../../../data/models/user_stats.dart';
import '../../../data/models/user_sticker.dart';

class StatsState extends Equatable {
  final UserStats? stats;
  final List<UserSticker> unlockedStickers;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.stats,
    this.unlockedStickers = const [],
    this.isLoading = false,
    this.error,
  });

  StatsState copyWith({
    UserStats? stats,
    List<UserSticker>? unlockedStickers,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [stats, unlockedStickers, isLoading, error];
}
