import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../cubits/search_cubit/search_cubit.dart';
import '../widgets/story_card.dart';

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchCubit>().search(query: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor(context)),
          onPressed: () => context.router.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '동화 검색...',
            hintStyle: TextStyle(color: AppTheme.textMutedColor(context)),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: AppTheme.textMutedColor(context)),
              onPressed: () {
                _searchController.clear();
                context.read<SearchCubit>().loadSearchHistory();
              },
            ),
          ),
          style: AppTheme.bodyLarge(context),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryColor(context)),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchLoaded) {
            return _buildSearchResults(state);
          }

          if (state is SearchError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTheme.bodyLarge(context)),
                ],
              ),
            );
          }

          // Initial state or history loaded
          return _buildSearchSuggestions();
        },
      ),
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              '"${state.query}" 검색 결과가 없어요',
              style: AppTheme.bodyLarge(context),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 키워드로 검색핼 보세요',
              style: AppTheme.caption(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final story = state.results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StoryCard(
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
            onTap: () {
              // TODO: Navigate to story detail
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchHistoryLoaded && state.history.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '최근 검색',
                          style: AppTheme.headingSmall(context),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<SearchCubit>().clearHistory();
                          },
                          child: const Text('전체 삭제'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: state.history.map((query) {
                        return ActionChip(
                          label: Text(query),
                          onPressed: () {
                            _searchController.text = query;
                            _performSearch(query);
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            context.read<SearchCubit>().removeFromHistory(query);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Popular searches
          Text(
            '인기 검색어',
            style: AppTheme.headingSmall(context),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: context.read<SearchCubit>().getPopularSearches().map((query) {
              return ActionChip(
                label: Text(query),
                onPressed: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Categories
          Text(
            '카테고리',
            style: AppTheme.headingSmall(context),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('전통동화', 'folktale', Icons.auto_stories),
              _buildCategoryChip('역사', 'history', Icons.history_edu),
              _buildCategoryChip('전설', 'legend', Icons.stars),
            ],
          ),
          const SizedBox(height: 24),

          // Age filters
          Text(
            '연령대',
            style: AppTheme.headingSmall(context),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAgeChip('4-6세', 4, 6),
              _buildAgeChip('7-9세', 7, 9),
              _buildAgeChip('10-12세', 10, 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        context.read<SearchCubit>().searchByCategory(category);
      },
    );
  }

  Widget _buildAgeChip(String label, int minAge, int maxAge) {
    return ActionChip(
      avatar: const Icon(Icons.child_care, size: 18),
      label: Text(label),
      onPressed: () {
        context.read<SearchCubit>().searchByAgeRange(minAge, maxAge);
      },
    );
  }
}
