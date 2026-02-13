import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/repositories/favorite_repository.dart';
import '../../../injection.dart';
import 'favorite_state.dart';
export 'favorite_state.dart';

/// Global cubit for user favorites. Kids app: always uses local storage.
@lazySingleton
class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit({FavoriteRepository? favoriteRepository})
      : _repo = favoriteRepository ?? getIt<FavoriteRepository>(),
        super(const FavoriteInitial());

  final FavoriteRepository _repo;

  Future<void> loadFavorites() async {
    try {
      final ids = await _repo.getFavoriteIds();
      final current = state is FavoriteLoaded ? (state as FavoriteLoaded) : null;
      emit(FavoriteLoaded(favoriteIds: ids, stories: current?.stories));
    } catch (e) {
      emit(const FavoriteLoaded(favoriteIds: {}));
    }
  }

  /// Stale-while-revalidate: shows cached stories if any, fetches in background.
  Future<void> loadFavoriteStories() async {
    final current = state is FavoriteLoaded ? (state as FavoriteLoaded) : null;
    final hasCache = current?.stories != null;
    if (hasCache && current != null) {
      emit(FavoriteLoaded(
        favoriteIds: current.favoriteIds,
        stories: current.stories,
        isRefreshing: true,
      ));
    }

    try {
      final stories = await _repo.getFavorites();
      final ids = stories.map((s) => s.id).toSet();
      emit(FavoriteLoaded(favoriteIds: ids, stories: stories));
    } catch (e) {
      if (hasCache && current != null) {
        emit(FavoriteLoaded(
          favoriteIds: current.favoriteIds,
          stories: current.stories,
          isRefreshing: false,
        ));
      } else {
        emit(const FavoriteLoaded(favoriteIds: {}));
      }
    }
  }

  bool isFavorite(String storyId) {
    final s = state;
    return s is FavoriteLoaded && s.favoriteIds.contains(storyId);
  }

  Future<bool> toggleFavorite(String storyId) async {
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

  Future<bool> addFavorite(String storyId) async {
    if (isFavorite(storyId)) return true;
    return toggleFavorite(storyId);
  }

  Future<bool> removeFavorite(String storyId) async {
    if (!isFavorite(storyId)) return true;
    return toggleFavorite(storyId);
  }

  void clearFavorites() {
    emit(const FavoriteLoaded(favoriteIds: {}));
  }
}
