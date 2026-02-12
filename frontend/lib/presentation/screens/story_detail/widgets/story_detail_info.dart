import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/chapter.dart';
import '../../../../data/models/story.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'story_detail_theme.dart';

class StoryDetailInfo extends StatelessWidget {
  final Story story;
  final List<Chapter> chapters;
  final VoidCallback? onListenNow;

  const StoryDetailInfo({
    super.key,
    required this.story,
    required this.chapters,
    this.onListenNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = StoryDetailTheme.of(context, story.category);
    final categoryLabel = _getCategoryLabel(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryBadge(color: theme.color, label: categoryLabel),
          const SizedBox(height: 12),
          Text(
            story.title,
            style: AppTheme.headingLarge(context),
          ),
          const SizedBox(height: 8),
          _StatsRow(story: story),
          const SizedBox(height: 16),
          if (story.summary.isNotEmpty)
            Text(story.summary, style: AppTheme.bodyMedium(context)),
          if (story.hasAudio && onListenNow != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onListenNow,
                icon: const Icon(Icons.play_circle_filled_rounded, size: 24),
                label: Text(context.l10n.listenNow),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor(context),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getCategoryLabel(BuildContext context) {
    switch (story.category) {
      case 'folktale':
        return context.l10n.categoryFolktale;
      case 'history':
        return context.l10n.categoryHistory;
      case 'legend':
        return context.l10n.categoryLegend;
      default:
        return story.category;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _CategoryBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTheme.caption(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Story story;

  const _StatsRow({required this.story});

  /// Age group as icon count: 1 = 5-6, 2 = 7-8, 3 = 9-10
  int get _ageIconCount {
    if (story.ageMax <= 6) return 1;
    if (story.ageMax <= 8) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${story.ageMin}-${story.ageMax}세, ${story.totalChapters}화${story.hasAudio ? ', ${context.l10n.audioStories}' : ''}',
      child: Row(
        children: [
          ...List.generate(
            _ageIconCount,
            (_) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.child_care_rounded,
                size: 22,
                color: AppTheme.textMutedColor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ChapterIcons(count: story.totalChapters),
          if (story.hasAudio) ...[
            const SizedBox(width: 12),
            Icon(Icons.headphones_rounded, size: 22, color: Colors.orange.shade700),
          ],
        ],
      ),
    );
  }
}

class _ChapterIcons extends StatelessWidget {
  final int count;

  const _ChapterIcons({required this.count});

  /// 1 icon = few (≤5), 2 = medium (6-15), 3 = many (16+)
  int get _iconCount {
    if (count <= 5) return 1;
    if (count <= 15) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _iconCount,
        (_) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            Icons.menu_book_rounded,
            size: 22,
            color: AppTheme.textMutedColor(context),
          ),
        ),
      ),
    );
  }
}
