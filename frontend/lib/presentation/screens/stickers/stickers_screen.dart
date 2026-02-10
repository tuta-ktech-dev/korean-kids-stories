import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/sticker_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sticker.dart';
import '../../../injection.dart';
import '../../../utils/extensions/context_extension.dart';
import '../../cubits/stats_cubit/stats_cubit.dart';

@RoutePage()
class StickersScreen extends StatelessWidget {
  const StickersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatsCubit>()..loadStats(),
      child: const _StickersView(),
    );
  }
}

class _StickersView extends StatelessWidget {
  const _StickersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.stickerAlbum,
          style: AppTheme.headingMedium(context),
        ),
        backgroundColor: AppTheme.backgroundColor(context),
        elevation: 0,
      ),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state.isLoading && state.unlockedStickers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.unlockedStickers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error!,
                    style: AppTheme.bodyMedium(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StatsCubit>().loadStats(),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            );
          }

          final stats = state.stats;
          final level = stats?.level ?? 1;
          final totalXp = stats?.totalXp ?? 0.0;
          final levelMatches = state.levelStickers
              .where((s) => (s.level ?? 0).toInt() == level);
          final levelSticker =
              levelMatches.isEmpty ? null : levelMatches.first;
          final storyStickers = state.unlockedStickers
              .where((us) => us.sticker != null && us.sticker!.type == 'story')
              .toList();

          return RefreshIndicator(
            onRefresh: () => context.read<StatsCubit>().loadStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header stats + progress bar
                  _StatsHeader(
                    level: level,
                    totalXp: totalXp,
                  ),
                  const SizedBox(height: 24),

                  // Big level sticker
                  if (levelSticker != null)
                    _LevelStickerCard(
                      sticker: levelSticker,
                      onTap: () => _showStickerDialog(context, levelSticker),
                    )
                  else
                    _LevelStickerPlaceholder(level: level),
                  const SizedBox(height: 32),

                  // Story stickers section
                  if (storyStickers.isNotEmpty) ...[
                    Text(
                      context.l10n.storyStickers,
                      style: AppTheme.headingMedium(context),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: storyStickers.length,
                      itemBuilder: (context, index) {
                        final us = storyStickers[index];
                        final sticker = us.sticker!;
                        return _StickerCard(
                          sticker: sticker,
                          onTap: () =>
                              _showStickerDialog(context, sticker),
                        );
                      },
                    ),
                  ] else
                    _EmptyStoryStickers(
                      readStoriesHint: context.l10n.readStoriesToUnlockStickers,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStickerDialog(BuildContext context, Sticker sticker) {
    showDialog(
      context: context,
      builder: (context) => _StickerDetailDialog(sticker: sticker),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int level;
  final double totalXp;

  const _StatsHeader({
    required this.level,
    required this.totalXp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = progressToNextLevel(totalXp);
    final currentThreshold =
        level <= xpLevelThresholds.length ? xpLevelThresholds[level - 1] : 0.0;
    final nextThreshold = level < 18 && level < xpLevelThresholds.length
        ? xpLevelThresholds[level]
        : currentThreshold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withValues(alpha: 0.3),
            AppTheme.primaryMint.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: context.l10n.level,
                value: '$level',
              ),
              _StatItem(
                label: context.l10n.xp,
                value: '${totalXp.toInt()}',
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white38,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor(context),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${totalXp.toInt()} / ${nextThreshold.toInt()} XP',
              style: AppTheme.caption(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption(context).copyWith(
            color: AppTheme.textMutedColor(context),
          ),
        ),
        Text(
          value,
          style: AppTheme.headingMedium(context),
        ),
      ],
    );
  }
}

class _LevelStickerCard extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback onTap;

  const _LevelStickerCard({
    required this.sticker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: sticker.imageUrl != null && sticker.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          sticker.imageUrl!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: AppTheme.primaryColor(context),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: AppTheme.primaryColor(context),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                sticker.nameKo,
                style: AppTheme.headingMedium(context),
                textAlign: TextAlign.center,
              ),
              if (sticker.rankKo != null && sticker.rankKo!.isNotEmpty)
                Text(
                  sticker.rankKo!,
                  style: AppTheme.caption(context),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelStickerPlaceholder extends StatelessWidget {
  final int level;

  const _LevelStickerPlaceholder({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: AppTheme.textMutedColor(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Level $level',
            style: AppTheme.bodyMedium(context),
          ),
        ],
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback onTap;

  const _StickerCard({
    required this.sticker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: sticker.imageUrl != null && sticker.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          sticker.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.emoji_events,
                            size: 48,
                            color: AppTheme.primaryColor(context),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: AppTheme.primaryColor(context),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                sticker.nameKo,
                style: AppTheme.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStoryStickers extends StatelessWidget {
  final String readStoriesHint;

  const _EmptyStoryStickers({required this.readStoriesHint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              readStoriesHint,
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerDetailDialog extends StatelessWidget {
  final Sticker sticker;

  const _StickerDetailDialog({required this.sticker});

  @override
  Widget build(BuildContext context) {
    final desc = sticker.descriptionKo ?? sticker.nameKo;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sticker.imageUrl != null && sticker.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  sticker.imageUrl!,
                  height: 160,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: AppTheme.primaryColor(context),
                  ),
                ),
              )
            else
              Icon(
                Icons.emoji_events,
                size: 80,
                color: AppTheme.primaryColor(context),
              ),
            const SizedBox(height: 16),
            Text(
              sticker.nameKo,
              style: AppTheme.headingMedium(context),
              textAlign: TextAlign.center,
            ),
            if (sticker.rankKo != null && sticker.rankKo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                sticker.rankKo!,
                style: AppTheme.caption(context),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              desc,
              style: AppTheme.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.continueAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
