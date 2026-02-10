import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/chapter.dart';
import '../../../../data/models/story.dart';
import '../../../components/buttons/bookmark_buttons.dart' show showNoteSheet;
import '../../../cubits/auth_cubit/auth_cubit.dart';
import '../../../cubits/bookmark_cubit/bookmark_cubit.dart';
import '../../../cubits/favorite_cubit/favorite_cubit.dart';
import '../../../cubits/note_cubit/note_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class StoryDetailBottomBar extends StatelessWidget {
  final Story story;
  final List<Chapter> chapters;

  const StoryDetailBottomBar({
    super.key,
    required this.story,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, FavoriteState>(
      buildWhen: (p, c) => c is FavoriteLoaded,
      builder: (context, favState) {
        final isFavorite =
            favState is FavoriteLoaded &&
            favState.favoriteIds.contains(story.id);
        return BlocBuilder<BookmarkCubit, BookmarkState>(
          buildWhen: (p, c) => c is BookmarkLoaded,
          builder: (context, bmState) {
            final isBookmarked =
                bmState is BookmarkLoaded && bmState.isBookmarked(story.id);
            return Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: chapters.isNotEmpty
                            ? () => _openReader(context, 0)
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: Text(context.l10n.startReading),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () => _onBookmarkTap(context, isBookmarked),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: isBookmarked
                            ? AppTheme.primaryColor(context)
                            : null,
                        foregroundColor: isBookmarked ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _onFavoriteTap(context, isFavorite),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openReader(BuildContext context, int chapterIndex) {
    if (story.requiredLogin) {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loginRequired),
            action: SnackBarAction(
              label: context.l10n.login,
              onPressed: () => context.router.pushNamed('/login'),
            ),
          ),
        );
        return;
      }
    }
    context.router.root.pushNamed(
      '/reader/${story.id}/${chapters[chapterIndex].id}',
    );
  }

  void _onFavoriteTap(BuildContext context, bool isFavorite) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.loginRequired),
          action: SnackBarAction(
            label: context.l10n.login,
            onPressed: () => context.router.pushNamed('/login'),
          ),
        ),
      );
      return;
    }
    context.read<FavoriteCubit>().toggleFavorite(story.id);
  }

  void _onBookmarkTap(BuildContext context, bool isBookmarked) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.loginRequired),
          action: SnackBarAction(
            label: context.l10n.login,
            onPressed: () => context.router.pushNamed('/login'),
          ),
        ),
      );
      return;
    }
    if (isBookmarked) {
      context.read<BookmarkCubit>().toggleBookmark(story.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.bookmarkRemoved)));
    } else {
      showNoteSheet(
        context,
        initialNote: null,
        onSave: (note) async {
          final bookmarkCubit = context.read<BookmarkCubit>();
          final noteCubit = context.read<NoteCubit>();
          final favoriteCubit = context.read<FavoriteCubit>();
          await bookmarkCubit.toggleBookmark(story.id);
          if (note.trim().isNotEmpty) {
            await noteCubit.addStoryNote(storyId: story.id, note: note.trim());
          }
          favoriteCubit.loadFavorites();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.bookmarkAdded)));
          }
        },
      );
    }
  }
}
