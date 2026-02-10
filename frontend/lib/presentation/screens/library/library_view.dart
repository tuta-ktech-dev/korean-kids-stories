import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../components/buttons/bookmark_buttons.dart';
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

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Load favorites from API
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StoryCard(
          title: '흥부와 놀부',
          subtitle: '전통동화 • 5-8세',
          isFavorite: true,
          onFavorite: () {},
          onBookmark: () {},
          onNote: () {},
        ),
        _StoryCard(
          title: '선녀와 나무꾼',
          subtitle: '전설 • 6-10세',
          isFavorite: true,
          onFavorite: () {},
          onBookmark: () {},
          onNote: () {},
        ),
      ],
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Load bookmarks from API
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _BookmarkItem(
          storyTitle: '세종대왕 이야기',
          chapterTitle: '제2화 - 한글 창제',
          position: '05:32',
          note: '아이가 이 부분을 좋아했음',
        ),
        _BookmarkItem(
          storyTitle: '흥부와 놀부',
          chapterTitle: '제1화',
          position: '12:15',
          note: '',
        ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Load notes from API
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _NoteCard(
          storyTitle: '흥부와 놀부',
          note: '아이가 선녀 캐릭터를 좋아함. 다음에 비슷한 전설 찾아주기.',
          date: '2026-02-09',
        ),
        _NoteCard(
          storyTitle: '세종대왕 이야기',
          note: '한글 창제 부분에서 질문 많이 함.',
          date: '2026-02-08',
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onBookmark;
  final VoidCallback? onNote;

  const _StoryCard({
    required this.title,
    required this.subtitle,
    this.isFavorite = false,
    this.onFavorite,
    this.onBookmark,
    this.onNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book, color: AppTheme.primaryPink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTheme.bodyMedium(context)),
              ],
            ),
          ),
          Row(
            children: [
              FavoriteButton(isFavorite: isFavorite, onTap: onFavorite),
              const SizedBox(width: 8),
              BookmarkButton(isBookmarked: false, onTap: onBookmark),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final String storyTitle;
  final String chapterTitle;
  final String position;
  final String note;

  const _BookmarkItem({
    required this.storyTitle,
    required this.chapterTitle,
    required this.position,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(
                Icons.bookmark,
                color: AppTheme.primaryColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  storyTitle,
                  style: AppTheme.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  position,
                  style: AppTheme.caption(context).copyWith(
                    color: AppTheme.primaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(chapterTitle, style: AppTheme.bodyMedium(context)),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: AppTheme.textMutedColor(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(note, style: AppTheme.bodyMedium(context)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String storyTitle;
  final String note;
  final String date;

  const _NoteCard({
    required this.storyTitle,
    required this.note,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.note, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  storyTitle,
                  style: AppTheme.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(date, style: AppTheme.caption(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note, style: AppTheme.bodyMedium(context)),
        ],
      ),
    );
  }
}
