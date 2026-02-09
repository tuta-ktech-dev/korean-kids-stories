import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/pocketbase_service.dart';
import 'categories_state.dart';
export 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesInitial()) {
    loadCategories();
  }

  final _pbService = PocketbaseService();

  Future<void> loadCategories() async {
    emit(const CategoriesLoading());

    try {
      await _pbService.initialize();

      // Fetch distinct categories from stories
      final stories = await _pbService.pb.collection('stories').getFullList(
            filter: 'is_published = true',
            fields: 'category',
          );

      // Extract unique categories
      final uniqueCategories = stories
          .map((r) => r.getStringValue('category'))
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      // Build category list dynamically
      final categories = <Category>[
        const Category(
          id: 'all',
          label: '전체',
          icon: 'auto_stories',
          filterValue: null,
        ),
        ...uniqueCategories.map((cat) => Category(
              id: cat,
              label: _getCategoryLabel(cat),
              icon: _getCategoryIcon(cat),
              filterValue: cat,
            )),
        const Category(
          id: 'favorite',
          label: '즐겨찾기',
          icon: 'favorite',
          isSpecial: true,
        ),
      ];

      emit(CategoriesLoaded(categories, selectedId: 'all'));
    } catch (e) {
      emit(CategoriesError('Failed to load categories: $e'));
    }
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

  void selectCategory(String categoryId) {
    if (state is CategoriesLoaded) {
      final current = state as CategoriesLoaded;
      emit(current.copyWith(selectedId: categoryId));
    }
  }

  void resetSelection() {
    if (state is CategoriesLoaded) {
      final current = state as CategoriesLoaded;
      emit(current.copyWith(selectedId: 'all'));
    }
  }

  String? get currentFilterValue {
    if (state is CategoriesLoaded) {
      final loaded = state as CategoriesLoaded;
      return loaded.selectedCategory?.filterValue;
    }
    return null;
  }

  bool get isSpecialCategory {
    if (state is CategoriesLoaded) {
      final loaded = state as CategoriesLoaded;
      return loaded.selectedCategory?.isSpecial ?? false;
    }
    return false;
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
