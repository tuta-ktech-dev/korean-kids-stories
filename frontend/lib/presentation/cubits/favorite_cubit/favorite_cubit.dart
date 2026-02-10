import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/favorite_repository.dart';
import '../../../data/services/pocketbase_service.dart';
import '../../../injection.dart';
import 'favorite_state.dart';
export 'favorite_state.dart';

/// Global cubit for user favorites (favorites collection).
/// Load when auth changes, expose isFavorite(storyId), toggleFavorite(storyId).
@lazySingleton
class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit({
    FavoriteRepository? favoriteRepository,
    PocketbaseService? pocketbaseService,
  })  : _repo = favoriteRepository ?? getIt<FavoriteRepository>(),
        _pbService = pocketbaseService ?? getIt<PocketbaseService>(),
        super(const FavoriteInitial());

  final FavoriteRepository _repo;
  final PocketbaseService _pbService;

  /// Load favorites. Call when user logs in or app starts (if authenticated).
  /// Preserves existing stories so Library tab doesn't show loading when back.
  Future<void> loadFavorites() async {
    if (!_pbService.isAuthenticated) {
      emit(const FavoriteLoaded(favoriteIds: {}));
      return;
    }

    try {
      await _pbService.initialize();
      final ids = await _repo.getFavoriteIds();
      final current = state is FavoriteLoaded ? (state as FavoriteLoaded) : null;
      emit(FavoriteLoaded(favoriteIds: ids, stories: current?.stories));
    } catch (e) {
      emit(const FavoriteLoaded(favoriteIds: {}));
    }
  }

  /// Load favorite stories (for Library tab). Emits with stories list.
  Future<void> loadFavoriteStories() async {
    if (!_pbService.isAuthenticated) {
      emit(const FavoriteLoaded(favoriteIds: {}));
      return;
    }

    try {
      await _pbService.initialize();
      final stories = await _repo.getFavorites();
      final ids = stories.map((s) => s.id).toSet();
      emit(FavoriteLoaded(favoriteIds: ids, stories: stories));
    } catch (e) {
      emit(const FavoriteLoaded(favoriteIds: {}));
    }
  }

  /// Check if story is favorited (sync from state)
  bool isFavorite(String storyId) {
    final s = state;
    return s is FavoriteLoaded && s.favoriteIds.contains(storyId);
  }

  /// Toggle favorite. Returns true if succeeded.
  Future<bool> toggleFavorite(String storyId) async {
    if (!_pbService.isAuthenticated) return false;

    final current = state is FavoriteLoaded ? (state as FavoriteLoaded) : null;
    final ids = current?.favoriteIds ?? {};
    final isFav = ids.contains(storyId);

    final ok = isFav
        ? await _repo.removeFavorite(storyId)
        : await _repo.addFavorite(storyId);

    if (ok) {
      final newIds = Set<String>.from(ids);
      if (isFav) {
        newIds.remove(storyId);
        final newStories = current?.stories?.where((s) => s.id != storyId).toList();
        emit(FavoriteLoaded(favoriteIds: newIds, stories: newStories));
      } else {
        newIds.add(storyId);
        emit(FavoriteLoaded(favoriteIds: newIds, stories: current?.stories));
      }
    }
    return ok;
  }

  /// Add to favorites (convenience)
  Future<bool> addFavorite(String storyId) async {
    if (isFavorite(storyId)) return true;
    return toggleFavorite(storyId);
  }

  /// Remove from favorites (convenience)
  Future<bool> removeFavorite(String storyId) async {
    if (!isFavorite(storyId)) return true;
    return toggleFavorite(storyId);
  }

  /// Clear state (e.g. on logout)
  void clearFavorites() {
    emit(const FavoriteLoaded(favoriteIds: {}));
  }
}
