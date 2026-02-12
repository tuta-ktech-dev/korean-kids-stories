import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/sticker_repository.dart';
import '../../../data/repositories/user_stats_repository.dart';
import '../../../injection.dart';
import 'stats_state.dart';
export 'stats_state.dart';

const String _lastSeenLevelKey = 'last_seen_level';

@injectable
class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    UserStatsRepository? userStatsRepo,
    StickerRepository? stickerRepo,
  })  : _userStatsRepo = userStatsRepo ?? getIt<UserStatsRepository>(),
        _stickerRepo = stickerRepo ?? getIt<StickerRepository>(),
        super(const StatsState());

  final UserStatsRepository _userStatsRepo;
  final StickerRepository _stickerRepo;

  Future<void> loadStats() async {
    emit(state.copyWith(isLoading: true, error: null, levelUpTo: null));
    try {
      final stats = await _userStatsRepo.getMyStats();
      final unlocked = await _stickerRepo.getMyUnlockedStickers();
      final levelStickers = await _stickerRepo.getLevelStickers();

      int? levelUpTo;
      final prefs = await SharedPreferences.getInstance();
      final lastLevel = prefs.getInt(_lastSeenLevelKey) ?? (stats?.level ?? 1);
      if (stats != null && stats.level > lastLevel) {
        levelUpTo = stats.level;
      }
      await prefs.setInt(_lastSeenLevelKey, stats?.level ?? 1);

      emit(state.copyWith(
        stats: stats,
        unlockedStickers: unlocked,
        levelStickers: levelStickers,
        isLoading: false,
        levelUpTo: levelUpTo,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void clearLevelUp() {
    emit(state.copyWith(levelUpTo: null));
  }
}
