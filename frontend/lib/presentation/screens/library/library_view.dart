import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/bookmark_cubit/bookmark_cubit.dart';
import '../../cubits/favorite_cubit/favorite_cubit.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../widgets/story_card.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

/// Library: Favorites, Bookmarks, Notes. Kids app: always uses local storage.
class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
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
        if (state is! FavoriteLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final stories = state.stories ?? [];
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty_favorites.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.favoritesEmpty,
                  style: AppTheme.bodyLarge(context).copyWith(
                    color: AppTheme.textMutedColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          itemBuilder: (context, i) {
            final s = stories[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StoryCard(
                id: s.id,
                title: s.title,
                thumbnailUrl: s.thumbnailUrl,
                category: s.category,
                ageMin: s.ageMin,
                ageMax: s.ageMax,
                totalChapters: s.totalChapters,
                isFeatured: s.isFeatured,
                hasAudio: s.hasAudio,
                hasQuiz: s.hasQuiz,
                hasIllustrations: s.hasIllustrations,
                averageRating: s.averageRating,
                reviewCount: s.reviewCount,
                viewCount: s.viewCount,
                onTap: () => context.router.push(StoryDetailRoute(storyId: s.id)),
              ),
            );
          },
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
        if (state is! BookmarkLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final stories = state.stories ?? [];
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty_bookmarks.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noBookmarksYet,
                  style: AppTheme.bodyLarge(context).copyWith(
                    color: AppTheme.textMutedColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          itemBuilder: (context, i) {
            final s = stories[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StoryCard(
                id: s.id,
                title: s.title,
                thumbnailUrl: s.thumbnailUrl,
                category: s.category,
                ageMin: s.ageMin,
                ageMax: s.ageMax,
                totalChapters: s.totalChapters,
                isFeatured: s.isFeatured,
                hasAudio: s.hasAudio,
                hasQuiz: s.hasQuiz,
                hasIllustrations: s.hasIllustrations,
                averageRating: s.averageRating,
                reviewCount: s.reviewCount,
                viewCount: s.viewCount,
                onTap: () => context.router.push(StoryDetailRoute(storyId: s.id)),
              ),
            );
          },
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
                Image.asset(
                  'assets/images/empty_notes.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.noNotesYet,
                  style: AppTheme.bodyLarge(context).copyWith(
                    color: AppTheme.textMutedColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, i) {
            final note = notes[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  note.storyTitle ?? note.storyId,
                  style: AppTheme.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  note.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium(context).copyWith(
                    color: AppTheme.textMutedColor(context),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
