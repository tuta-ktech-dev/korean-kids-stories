import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
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
                    onPressed: () =>
                        context.read<StatsCubit>().loadStats(),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            );
          }

          final stickers = state.unlockedStickers
              .where((us) => us.sticker != null)
              .toList();

          if (stickers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: AppTheme.textMutedColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.myStickers,
                    style: AppTheme.headingMedium(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Read stories to unlock stickers!',
                    style: AppTheme.bodyMedium(context).copyWith(
                      color: AppTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: stickers.length,
            itemBuilder: (context, index) {
              final us = stickers[index];
              final sticker = us.sticker!;
              return _StickerCard(
                nameKo: sticker.nameKo,
                rankKo: sticker.rankKo,
                imageUrl: sticker.imageUrl,
                unlockSource: us.unlockSource,
              );
            },
          );
        },
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  final String nameKo;
  final String? rankKo;
  final String? imageUrl;
  final String unlockSource;

  const _StickerCard({
    required this.nameKo,
    this.rankKo,
    this.imageUrl,
    required this.unlockSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
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
            nameKo,
            style: AppTheme.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (rankKo != null && rankKo!.isNotEmpty)
            Text(
              rankKo!,
              style: AppTheme.caption(context),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
