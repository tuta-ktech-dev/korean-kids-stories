import 'package:equatable/equatable.dart';
import '../../../data/models/story.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Story> results;
  final String query;
  final String? category;
  final int? minAge;
  final int? maxAge;

  const SearchLoaded({
    required this.results,
    required this.query,
    this.category,
    this.minAge,
    this.maxAge,
  });

  @override
  List<Object?> get props => [results, query, category, minAge, maxAge];

  SearchLoaded copyWith({
    List<Story>? results,
    String? query,
    String? category,
    int? minAge,
    int? maxAge,
  }) {
    return SearchLoaded(
      results: results ?? this.results,
      query: query ?? this.query,
      category: category ?? this.category,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;

  const SearchHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}
