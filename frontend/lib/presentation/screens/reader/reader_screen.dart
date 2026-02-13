import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/reader_auto_play.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../injection.dart';
import '../../cubits/reader_cubit/reader_cubit.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';
import 'reader_view.dart';

@RoutePage()
class ReaderScreen extends StatelessWidget {
  final String storyId;
  final String chapterId;

  const ReaderScreen({
    super.key,
    @PathParam('storyId') required this.storyId,
    @PathParam('chapterId') required this.chapterId,
  });

  Future<void> _handleStoryComplete(
    BuildContext context,
    String completedStoryId,
    bool hasQuiz,
  ) async {
    final storyRepo = getIt<StoryRepository>();
    final progressRepo = getIt<ProgressRepository>();
    final readIds = await progressRepo.getReadStoryIds();
    final excludeIds = {completedStoryId, ...readIds};

    // Get current story's category for "same category" next
    final currentStory = await storyRepo.getStory(completedStoryId);
    final category = currentStory?.category;

    final nextStory = await storyRepo.getNextStory(
      excludeStoryIds: excludeIds,
      category: category,
    );

    if (!context.mounted) return;

    if (nextStory == null) {
      // No next story - show completion, go back
      _showStoryCompleteDialog(context, hasQuiz, onContinue: () {
        Navigator.of(context).pop();
        context.router.maybePop();
      });
      return;
    }

    final chapters = await storyRepo.getChapters(nextStory.id);
    if (!context.mounted) return;
    final freeChapters = chapters.where((c) => c.isFree).toList();
    final firstChapter =
        freeChapters.isNotEmpty ? freeChapters.first : (chapters.isNotEmpty ? chapters.first : null);
    if (firstChapter == null) return;
    if (!context.mounted) return;

    _showStoryCompleteDialog(
      context,
      hasQuiz,
      onQuiz: hasQuiz
          ? () {
              Navigator.of(context).pop();
              context.router.replace(
                StoryDetailRoute(storyId: completedStoryId),
              );
            }
          : null,
      onContinue: () {
        Navigator.of(context).pop();
        ReaderAutoPlay.request(); // Auto-play when next reader opens
        context.router.replace(
          ReaderRoute(storyId: nextStory.id, chapterId: firstChapter.id),
        );
      },
    );
  }

  void _showStoryCompleteDialog(
    BuildContext context,
    bool hasQuiz, {
    VoidCallback? onQuiz,
    required VoidCallback onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          context.l10n.chapterCompletedTitle,
          textAlign: TextAlign.center,
        ),
        content: Text(
          context.l10n.storyCompleteMessage,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (onQuiz != null)
            TextButton(
              onPressed: onQuiz,
              child: Text(context.l10n.doQuiz),
            ),
          TextButton(
            onPressed: onContinue,
            child: Text(
              hasQuiz && onQuiz != null
                  ? context.l10n.skipNextStory
                  : context.l10n.continueAction,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ReaderCubit>();
        cubit.onStoryComplete = (sid, hasQuiz) =>
            _handleStoryComplete(context, sid, hasQuiz);
        cubit.loadChapter(chapterId);
        return cubit;
      },
      child: ReaderView(storyId: storyId),
    );
  }
}
