import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/bookmark_cubit/bookmark_cubit.dart';
import '../../cubits/favorite_cubit/favorite_cubit.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../widgets/story_card.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Unauthenticated || state is AuthInitial) {
          return _buildGuestPrompt(context);
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppTheme.backgroundColor(context),
            appBar: AppBar(
              title: Text(
                context.l10n.libraryTitle,
                style: AppTheme.headingMedium(context),
              ),
              backgroundColor: AppTheme.backgroundColor(context),
              elevation: 0,
              bottom: TabBar(
                labelColor: AppTheme.primaryColor(context),
                unselectedLabelColor: AppTheme.textMutedColor(context),
                indicatorColor: AppTheme.primaryColor(context),
                tabs: [
                  Tab(
                    text: context.l10n.tabFavorites,
                    icon: const Icon(Icons.favorite),
                  ),
                  Tab(
                    text: context.l10n.tabBookmarks,
                    icon: const Icon(Icons.bookmark),
                  ),
                  Tab(
                    text: context.l10n.tabNotes,
                    icon: const Icon(Icons.note),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [_FavoritesTab(), _BookmarksTab(), _NotesTab()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.libraryTitle,
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.textMutedColor(
                    context,
                  ).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: AppTheme.textMutedColor(context),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.loginRequired,
                style: AppTheme.headingMedium(context),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.libraryLoginPrompt,
                style: AppTheme.bodyLarge(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.router.pushNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(context.l10n.loginAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesTab extends StatefulWidget {
  const _FavoritesTab();

  @override
  State<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<_FavoritesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteCubit>().loadFavoriteStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      buildWhen: (prev, curr) => curr is FavoriteLoaded,
      builder: (context, state) {
        if (state is! FavoriteLoaded || state.stories == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final stories = state.stories!;
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.tabFavorites,
                  style: AppTheme.bodyLarge(context),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.favoritesEmpty,
                  style: AppTheme.caption(context),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<FavoriteCubit>().loadFavoriteStories(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = 2;
              final padding = 16.0;
              final spacing = 12.0;
              final cellWidth =
                  (constraints.maxWidth - padding * 2 - spacing) / crossAxisCount;
              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 0.55,
                ),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
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
                    width: cellWidth,
                    onTap: () => context.router.root
                        .push(StoryDetailRoute(storyId: story.id)),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _BookmarksTab extends StatefulWidget {
  const _BookmarksTab();

  @override
  State<_BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<_BookmarksTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkCubit>().loadBookmarkedStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      buildWhen: (prev, curr) => curr is BookmarkLoaded,
      builder: (context, state) {
        if (state is! BookmarkLoaded || state.stories == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final stories = state.stories!;
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.tabBookmarks,
                  style: AppTheme.bodyLarge(context),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noBookmarksYet,
                  style: AppTheme.caption(context),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<BookmarkCubit>().loadBookmarkedStories(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = 2;
              final padding = 16.0;
              final spacing = 12.0;
              final cellWidth =
                  (constraints.maxWidth - padding * 2 - spacing) / crossAxisCount;
              return GridView.builder(
                padding: EdgeInsets.all(padding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.55,
                ),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
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
                    width: cellWidth,
                    onTap: () => context.router.root
                        .push(StoryDetailRoute(storyId: story.id)),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteCubit>().loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteCubit, NoteState>(
      buildWhen: (prev, curr) => curr is NoteLoaded,
      builder: (context, state) {
        if (state is! NoteLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = state.notes;
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 64,
                  color: AppTheme.textMutedColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.tabNotes,
                  style: AppTheme.bodyLarge(context),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.noNotesYet,
                  style: AppTheme.caption(context),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<NoteCubit>().loadNotes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final n = notes[index];
              final subtitle = n.chapterTitle != null
                  ? '${n.storyTitle ?? n.storyId} · ${n.chapterTitle}'
                  : (n.storyTitle ?? n.storyId);
              return _NoteCard(
                storyTitle: subtitle,
                note: n.note,
                onTap: () {
                  context.router.root.push(StoryDetailRoute(storyId: n.storyId));
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String storyTitle;
  final String note;
  final VoidCallback? onTap;

  const _NoteCard({
    required this.storyTitle,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, size: 20, color: AppTheme.primaryColor(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storyTitle,
                    style: AppTheme.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

