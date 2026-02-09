import 'package:equatable/equatable.dart';

// Category model
class Category extends Equatable {
  final String id;
  final String label;
  final String icon;
  final String? filterValue;
  final bool isSpecial; // e.g., 'favorite' doesn't filter by category field

  const Category({
    required this.id,
    required this.label,
    required this.icon,
    this.filterValue,
    this.isSpecial = false,
  });

  @override
  List<Object?> get props => [id, label, icon, filterValue, isSpecial];

  Category copyWith({
    String? id,
    String? label,
    String? icon,
    String? filterValue,
    bool? isSpecial,
  }) {
    return Category(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      filterValue: filterValue ?? this.filterValue,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }
}

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final String? selectedId;

  const CategoriesLoaded(this.categories, {this.selectedId});

  Category? get selectedCategory {
    if (selectedId == null) return null;
    return categories.firstWhere(
      (c) => c.id == selectedId,
      orElse: () => categories.first,
    );
  }

  @override
  List<Object?> get props => [categories, selectedId];

  CategoriesLoaded copyWith({
    List<Category>? categories,
    String? selectedId,
  }) {
    return CategoriesLoaded(
      categories ?? this.categories,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
