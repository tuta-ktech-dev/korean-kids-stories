import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/chapter.dart';
import '../../../../data/models/story.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'story_detail_theme.dart';

class StoryDetailChapterList extends StatelessWidget {
  final Story story;
  final List<Chapter> chapters;

  const StoryDetailChapterList({
    super.key,
    required this.story,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = StoryDetailTheme.of(context, story.category);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _ChapterTile(
          chapter: chapters[index],
          categoryColor: theme.color,
          storyId: story.id,
          onTap: chapters[index].isFree
              ? () => _openReader(context, chapters[index])
              : null,
        ),
        childCount: chapters.length,
      ),
    );
  }

  void _openReader(BuildContext context, Chapter chapter) {
    context.router.root.pushNamed('/reader/${story.id}/${chapter.id}');
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final Color categoryColor;
  final String storyId;
  final VoidCallback? onTap;

  const _ChapterTile({
    required this.chapter,
    required this.categoryColor,
    required this.storyId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = chapter.title.isNotEmpty
        ? chapter.title
        : context.l10n.chapterTitleFallback(chapter.chapterNumber);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '${chapter.chapterNumber}',
            style: AppTheme.bodyLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              color: categoryColor,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: chapter.isFree
          ? Text(
              context.l10n.free,
              style: AppTheme.caption(context).copyWith(color: Colors.green),
            )
          : Text(context.l10n.locked, style: AppTheme.caption(context)),
      trailing: chapter.isFree
          ? Icon(Icons.play_circle_outline, color: AppTheme.primaryColor(context))
          : Icon(Icons.lock_outline, color: AppTheme.textMutedColor(context)),
      onTap: onTap,
    );
  }
}
