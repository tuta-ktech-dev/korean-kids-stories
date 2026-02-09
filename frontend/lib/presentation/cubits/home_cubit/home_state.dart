import 'package:equatable/equatable.dart';

// Category model
class Category extends Equatable {
  final String id;
  final String label;
  final String icon;
  final String? filterValue;
  final bool isSpecial;

  const Category({
    required this.id,
    required this.label,
    required this.icon,
    this.filterValue,
    this.isSpecial = false,
  });

  @override
  List<Object?> get props => [id, label, icon, filterValue, isSpecial];
}

// Story model (simplified for home)
class HomeStory extends Equatable {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String category;
  final int ageMin;
  final int ageMax;
  final int totalChapters;
  final bool isFeatured;
  final bool hasAudio;
  final bool hasQuiz;
  final bool hasIllustrations;
  final double? averageRating;
  final int reviewCount;

  const HomeStory({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.category,
    required this.ageMin,
    required this.ageMax,
    required this.totalChapters,
    this.isFeatured = false,
    this.hasAudio = false,
    this.hasQuiz = false,
    this.hasIllustrations = false,
    this.averageRating,
    this.reviewCount = 0,
  });

  @override
  List<Object?> get props => [id, title, thumbnailUrl, category, ageMin, ageMax, totalChapters, isFeatured, hasAudio, hasQuiz, hasIllustrations, averageRating, reviewCount];
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<HomeStory> stories;
  final String? selectedCategoryId;
  final bool isLoadingStories;

  const HomeLoaded({
    required this.categories,
    required this.stories,
    this.selectedCategoryId,
    this.isLoadingStories = false,
  });

  Category? get selectedCategory {
    if (selectedCategoryId == null) return null;
    return categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => categories.first,
    );
  }

  @override
  List<Object?> get props => [categories, stories, selectedCategoryId, isLoadingStories];

  HomeLoaded copyWith({
    List<Category>? categories,
    List<HomeStory>? stories,
    String? selectedCategoryId,
    bool? isLoadingStories,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      stories: stories ?? this.stories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      isLoadingStories: isLoadingStories ?? this.isLoadingStories,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
