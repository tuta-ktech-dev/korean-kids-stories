import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/story.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../injection.dart';
import 'home_state.dart';
export 'home_state.dart';

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    StoryRepository? storyRepository,
    ProgressRepository? progressRepository,
  })  : _storyRepo = storyRepository ?? getIt<StoryRepository>(),
        _progressRepo = progressRepository ?? getIt<ProgressRepository>(),
        super(const HomeInitial()) {
    initialize();
  }

  final StoryRepository _storyRepo;
  final ProgressRepository _progressRepo;
  static const int _perPage = 20;
  int _currentPage = 1;

  Future<void> initialize() async {
    emit(const HomeLoading());

    try {
      final results = await Future.wait([
        _fetchCategories(),
        _fetchStoriesPage(1, null),
        _fetchSections(),
      ]);

      final categories = results[0] as List<Category>;
      final storyResult = results[1] as ({List<HomeStory> stories, bool hasMore});
      final sections = results[2] as StorySections;

      emit(
        HomeLoaded(
          categories: categories,
          stories: storyResult.stories,
          sections: sections,
          selectedCategoryId: categories.isNotEmpty ? categories.first.id : null,
          hasMore: storyResult.hasMore,
        ),
      );
      _currentPage = 1;
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
      debugPrint('HomeCubit initialization error: $e');
    }
  }

  Future<List<Category>> _fetchCategories() async {
    // Fetch distinct categories from stories
    final stories = await _storyRepo.getStories();

    // Extract unique categories
    final uniqueCategories = stories
        .map((s) => s.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    // Build category list
    return [
      const Category(
        id: 'all',
        label: '전체',
        icon: 'auto_stories',
        filterValue: null,
      ),
      ...uniqueCategories.map(
        (cat) => Category(
          id: cat,
          label: _getCategoryLabel(cat),
          icon: _getCategoryIcon(cat),
          filterValue: cat,
        ),
      ),
      const Category(
        id: 'favorite',
        label: '즐겨찾기',
        icon: 'favorite',
        isSpecial: true,
      ),
    ];
  }

  Future<List<HomeStory>> _fetchStories({String? category}) async {
    final stories = await _storyRepo.getStories(category: category);
    final readIds = await _progressRepo.getReadStoryIds();
    return stories
        .where((s) => !readIds.contains(s.id))
        .map((s) => _mapToHomeStory(s))
        .toList();
  }

  Future<({List<HomeStory> stories, bool hasMore})> _fetchStoriesPage(
    int page,
    String? category,
  ) async {
    final result = await _storyRepo.getStoriesPaginated(
      page: page,
      perPage: _perPage,
      category: category == 'all' ? null : category,
    );
    final readIds = await _progressRepo.getReadStoryIds();
    final filtered = result.stories
        .where((s) => !readIds.contains(s.id))
        .map((s) => _mapToHomeStory(s))
        .toList();
    return (stories: filtered, hasMore: result.hasMore);
  }

  Future<StorySections> _fetchSections() async {
    try {
      final allStories = await _storyRepo.getStories();
      final readIds = await _progressRepo.getReadStoryIds();
      final homeStories = allStories
          .where((s) => !readIds.contains(s.id))
          .map((s) => _mapToHomeStory(s))
          .toList();

      // 🔥 Featured stories
      final featured = homeStories.where((s) => s.isFeatured).take(5).toList();

      // 🎧 Stories with audio
      final withAudio = homeStories.where((s) => s.hasAudio).take(5).toList();

      // ⭐ Most reviewed (sorted by review count)
      final mostReviewed = List<HomeStory>.from(homeStories)
        ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      if (mostReviewed.length > 5) {
        mostReviewed.removeRange(5, mostReviewed.length);
      }

      // 👁 Most viewed (sorted by view count)
      final mostViewed = List<HomeStory>.from(homeStories)
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      if (mostViewed.length > 5) {
        mostViewed.removeRange(5, mostViewed.length);
      }

      // 🆕 Recent stories
      final recent = homeStories.take(5).toList();

      return StorySections(
        featured: featured,
        withAudio: withAudio,
        mostReviewed: mostReviewed,
        mostViewed: mostViewed,
        recent: recent,
      );
    } catch (e) {
      debugPrint('Error fetching sections: $e');
      return const StorySections();
    }
  }

  HomeStory _mapToHomeStory(Story story) {
    return HomeStory(
      id: story.id,
      title: story.title,
      thumbnailUrl: story.thumbnailUrl,
      category: story.category,
      ageMin: story.ageMin,
      ageMax: story.ageMax,
      totalChapters: story.totalChapters,
      isFeatured: story.isFeatured,
      hasAudio: story.hasAudio,
      hasQuiz: story.hasQuiz,
      hasIllustrations: story.hasIllustrations,
      averageRating: story.averageRating,
      reviewCount: story.reviewCount,
      viewCount: story.viewCount,
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'folktale':
        return '전통동화';
      case 'history':
        return '역사';
      case 'legend':
        return '전설';
      case 'fairy':
        return '동화';
      case 'edu':
        return '교육';
      default:
        return category;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'folktale':
        return 'auto_stories';
      case 'history':
        return 'history_edu';
      case 'legend':
        return 'stars';
      case 'fairy':
        return 'child_care';
      case 'edu':
        return 'school';
      default:
        return 'book';
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (state is! HomeLoaded) return;

    final current = state as HomeLoaded;
    final category = current.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => current.categories.first,
    );

    emit(
      current.copyWith(selectedCategoryId: categoryId, isLoadingStories: true),
    );

    try {
      List<HomeStory> stories;
      bool hasMore;

      if (category.isSpecial) {
        stories = await _fetchStories();
        hasMore = false;
      } else {
        final result = await _fetchStoriesPage(1, category.filterValue);
        stories = result.stories;
        hasMore = result.hasMore;
      }

      _currentPage = 1;
      emit(
        current.copyWith(
          selectedCategoryId: categoryId,
          stories: stories,
          isLoadingStories: false,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load stories: $e'));
    }
  }

  Future<void> loadMore() async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (current.isLoadingMore || !current.hasMore) return;
    if (current.selectedCategory?.isSpecial == true) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final category = current.selectedCategory?.filterValue;
      final result = await _fetchStoriesPage(nextPage, category);

      _currentPage = nextPage;
      final combined = [...current.stories, ...result.stories];
      emit(
        current.copyWith(
          stories: combined,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
      debugPrint('HomeCubit loadMore error: $e');
    }
  }

  Future<void> refresh() async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      final category = current.selectedCategory;
      await selectCategory(category?.id ?? 'all');
    }
  }

  /// Full refresh for pull-to-refresh - reloads all data without showing loading.
  Future<void> fullRefresh() async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    try {
      final cat = current.selectedCategory;
      final isSpecial = cat?.isSpecial == true;
      final results = await Future.wait([
        _fetchCategories(),
        isSpecial
            ? _fetchStories(category: null)
                .then((s) => (stories: s, hasMore: false))
            : _fetchStoriesPage(1, cat?.filterValue),
        _fetchSections(),
      ]);

      final categories = results[0] as List<Category>;
      final storyResult = results[1] as ({List<HomeStory> stories, bool hasMore});
      final stories = storyResult.stories;
      final sections = results[2] as StorySections;

      _currentPage = 1;
      emit(
        HomeLoaded(
          categories: categories,
          stories: stories,
          sections: sections,
          selectedCategoryId: current.selectedCategoryId,
          hasMore: storyResult.hasMore,
        ),
      );
    } catch (_) {
      // Keep current state on error
    }
  }

  // Helper to convert icon string to IconData
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'auto_stories':
        return Icons.auto_stories;
      case 'history_edu':
        return Icons.history_edu;
      case 'stars':
        return Icons.stars;
      case 'favorite':
        return Icons.favorite;
      case 'child_care':
        return Icons.child_care;
      case 'school':
        return Icons.school;
      case 'book':
        return Icons.book;
      default:
        return Icons.book;
    }
  }
}
