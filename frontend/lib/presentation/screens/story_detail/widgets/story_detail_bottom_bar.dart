import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/chapter.dart';
import '../../../../data/models/story.dart';
import '../../../cubits/auth_cubit/auth_cubit.dart';
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
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              onPressed: () => _onBookmarkTap(context),
              icon: const Icon(Icons.bookmark_border),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  void _openReader(BuildContext context, int chapterIndex) {
    context.router.root.pushNamed(
      '/reader/${story.id}/${chapters[chapterIndex].id}',
    );
  }

  void _onBookmarkTap(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loginRequired)));
      return;
    }
    // TODO: Implement bookmark - ProgressRepository.addBookmark or bookmarks API
  }
}
