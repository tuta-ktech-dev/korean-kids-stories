import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/sticker_repository.dart';
import '../../../data/repositories/user_stats_repository.dart';
import '../../../injection.dart';
import 'stats_state.dart';
export 'stats_state.dart';

const String _lastSeenLevelKey = 'last_seen_level';

/// Cache TTL - skip refetch if data is younger than this
const Duration _cacheTtl = Duration(minutes: 5);

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
  DateTime? _lastFetchedAt;

  /// Load stats. Uses cache if data exists and is younger than [_cacheTtl].
  /// Set [forceRefresh] true (e.g. pull-to-refresh) to always fetch.
  Future<void> loadStats({bool forceRefresh = false}) async {
    final hasValidCache = !forceRefresh &&
        _lastFetchedAt != null &&
        state.stats != null &&
        DateTime.now().difference(_lastFetchedAt!) < _cacheTtl;

    if (hasValidCache) {
      return; // Use cached data, no loading
    }

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

      _lastFetchedAt = DateTime.now();
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
