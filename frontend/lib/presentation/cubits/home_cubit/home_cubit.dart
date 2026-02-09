import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/story.dart';
import '../../../data/services/pocketbase_service.dart';
import 'home_state.dart';
export 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial()) {
    initialize();
  }

  final _pbService = PocketbaseService();

  Future<void> initialize() async {
    emit(const HomeLoading());

    try {
      await _pbService.initialize();

      // Fetch categories and stories in parallel
      final results = await Future.wait([_fetchCategories(), _fetchStories()]);

      final categories = results[0] as List<Category>;
      final stories = results[1] as List<HomeStory>;

      emit(
        HomeLoaded(
          categories: categories,
          stories: stories,
          selectedCategoryId: categories.isNotEmpty
              ? categories.first.id
              : null,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
      debugPrint('HomeCubit initialization error: $e');
    }
  }

  Future<List<Category>> _fetchCategories() async {
    // Fetch distinct categories from stories
    final stories = await _pbService.pb
        .collection('stories')
        .getFullList(filter: 'is_published=true', fields: 'category');

    // Extract unique categories
    final uniqueCategories = stories
        .map((r) => r.getStringValue('category'))
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
    final stories = await _pbService.getStories(category: category);
    return stories.map((s) => _mapToHomeStory(s)).toList();
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
      hasAudio: story.hasAudio,
      hasQuiz: story.hasQuiz,
      hasIllustrations: story.hasIllustrations,
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

    // Emit loading state for stories
    emit(
      current.copyWith(selectedCategoryId: categoryId, isLoadingStories: true),
    );

    try {
      List<HomeStory> stories;

      if (category.isSpecial) {
        // TODO: Load favorites from local storage
        stories = await _fetchStories();
      } else {
        stories = await _fetchStories(category: category.filterValue);
      }

      emit(
        current.copyWith(
          selectedCategoryId: categoryId,
          stories: stories,
          isLoadingStories: false,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load stories: $e'));
    }
  }

  Future<void> refresh() async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      final category = current.selectedCategory;
      await selectCategory(category?.id ?? 'all');
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
