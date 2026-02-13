import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/reader_auto_play.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chapter.dart';
import '../../../data/models/sticker.dart';
import '../../widgets/story_sticker_congrats_dialog.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/sticker_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../injection.dart';
import '../../cubits/reader_cubit/reader_cubit.dart';
import '../../cubits/stats_cubit/stats_cubit.dart';
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
    String completedChapterId,
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

    Chapter? firstChapter;
    if (nextStory != null) {
      final chapters = await storyRepo.getChapters(nextStory.id);
      if (!context.mounted) return;
      final freeChapters = chapters.where((c) => c.isFree).toList();
      firstChapter = freeChapters.isNotEmpty
          ? freeChapters.first
          : (chapters.isNotEmpty ? chapters.first : null);
    }
    if (!context.mounted) return;

    final hasSticker = currentStory?.hasSticker ?? false;
    final stickerRepo = getIt<StickerRepository>();
    final sticker = hasSticker
        ? await stickerRepo.getStickerByStoryId(completedStoryId)
        : null;
    if (!context.mounted) return;

    void showStoryCompleteDialog() {
      if (nextStory == null) {
        _showStoryCompleteDialog(context, hasQuiz, false, onContinue: () {
          Navigator.of(context).pop();
          context.router.maybePop();
        });
      } else if (firstChapter != null) {
        final next = nextStory;
        final first = firstChapter;
        _showStoryCompleteDialog(
          context,
          hasQuiz,
          false,
          onQuiz: hasQuiz
              ? () {
                  Navigator.of(context).pop();
                  context.router.push(
                    QuizRoute(
                      storyId: completedStoryId,
                      chapterId: completedChapterId,
                      nextStoryId: next.id,
                      nextChapterId: first.id,
                    ),
                  );
                }
              : null,
          onContinue: () {
            Navigator.of(context).pop();
            ReaderAutoPlay.request();
            context.router.replace(
              ReaderRoute(storyId: next.id, chapterId: first.id),
            );
          },
        );
      }
    }

    if (hasSticker && sticker != null) {
      await stickerRepo.unlockStickerLocal(stickerId: sticker.id);
      if (!context.mounted) return;
      _showStoryStickerCongratsDialog(
        context,
        sticker: sticker,
        storyTitle: currentStory?.title ?? '',
        onContinue: () {
          Navigator.of(context).pop();
          if (nextStory == null) {
            context.router.maybePop();
          } else {
            showStoryCompleteDialog();
          }
        },
        onSeeAlbum: () {
          Navigator.of(context).pop();
          context.router.maybePop();
          context.router.push(const StickersRoute());
          context.read<StatsCubit>().loadStats(forceRefresh: true);
        },
      );
    } else {
      showStoryCompleteDialog();
    }
  }

  void _showStoryStickerCongratsDialog(
    BuildContext context, {
    required Sticker sticker,
    required String storyTitle,
    required VoidCallback onContinue,
    required VoidCallback onSeeAlbum,
  }) {
    showStoryStickerCongratsDialog(
      context,
      sticker: sticker,
      storyTitle: storyTitle,
      onContinue: onContinue,
      onSeeAlbum: onSeeAlbum,
    );
  }

  void _showStoryCompleteDialog(
    BuildContext context,
    bool hasQuiz,
    bool hasSticker, {
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
          context.l10n.storyCompleteTitle,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.storyCompleteMessage,
              textAlign: TextAlign.center,
            ),
            if (hasSticker) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: AppTheme.primaryPink, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.stickerEarnedCongrats,
                        style: AppTheme.bodyMedium(ctx)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (onQuiz != null)
            TextButton(
              onPressed: onQuiz,
              child: Text(context.l10n.doQuiz),
            ),
          if (hasSticker)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.router.maybePop(); // Back from reader
                context.router.push(const StickersRoute());
                context.read<StatsCubit>().loadStats(forceRefresh: true);
              },
              child: Text(context.l10n.stickerAlbum),
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
            _handleStoryComplete(context, sid, hasQuiz, chapterId);
        cubit.loadChapter(chapterId);
        return cubit;
      },
      child: ReaderView(storyId: storyId),
    );
  }
}
