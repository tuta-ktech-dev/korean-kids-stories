import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/chapter_audio.dart';
import '../../../components/audio_progress_bar.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class ReaderBottomBar extends StatelessWidget {
  final double progress;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevChapter;
  final VoidCallback? onNextChapter;
  final void Function(Duration)? onSeek;
  final List<ChapterAudio> audios;
  final ChapterAudio? selectedAudio;
  final void Function(ChapterAudio)? onSelectAudio;
  final int sleepTimerMinutes;
  final DateTime? sleepTimerEndsAt;
  final void Function(int)? onSleepTimerChanged;

  const ReaderBottomBar({
    super.key,
    this.progress = 0.0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.onPlayPause,
    this.onPrevChapter,
    this.onNextChapter,
    this.onSeek,
    this.audios = const [],
    this.selectedAudio,
    this.onSelectAudio,
    this.sleepTimerMinutes = 0,
    this.sleepTimerEndsAt,
    this.onSleepTimerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAudio = audios.isNotEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: isDark ? 0.08 : 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            hasAudio
                ? AudioProgressBar(
                    position: position,
                    duration: duration,
                    onSeek: onSeek,
                    height: 6,
                    showTime: true,
                  )
                : LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.textMutedColor(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor(context),
                    ),
                  ),
            if (audios.length > 1) ...[
              const SizedBox(height: 12),
              _buildNarratorSelector(context),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    color: AppTheme.textColor(context),
                  ),
                  onPressed: onPrevChapter,
                ),
                IconButton.filled(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  iconSize: 36,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor(context),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onPlayPause,
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next_rounded,
                    color: AppTheme.textColor(context),
                  ),
                  onPressed: onNextChapter,
                ),
                if (onSleepTimerChanged != null) _buildSleepTimerButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTimerButton(BuildContext context) {
    final hasTimer = sleepTimerMinutes > 0;
    return PopupMenuButton<int>(
      tooltip: context.l10n.sleepTimer,
      icon: Icon(
        Icons.timer_outlined,
        color: hasTimer
            ? AppTheme.primaryColor(context)
            : AppTheme.textColor(context),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: onSleepTimerChanged!,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text(context.l10n.sleepTimerOff),
        ),
        PopupMenuItem(value: 5, child: Text(context.l10n.sleepTimer5min)),
        PopupMenuItem(
          value: 10,
          child: Text(context.l10n.sleepTimer10min),
        ),
        PopupMenuItem(
          value: 15,
          child: Text(context.l10n.sleepTimer15min),
        ),
      ],
    );
  }

  Widget _buildNarratorSelector(BuildContext context) {
    final textColor = AppTheme.textColor(context);
    final primary = AppTheme.primaryColor(context);
    return Row(
      children: [
        Text(
          '${context.l10n.voice}: ',
          style: TextStyle(fontSize: 13, color: textColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: audios.map((audio) {
                final isSelected = selectedAudio?.id == audio.id;
                final label =
                    audio.narrator ??
                    '${context.l10n.voice} ${audios.indexOf(audio) + 1}';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label, style: TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: onSelectAudio != null
                        ? (_) => onSelectAudio!(audio)
                        : null,
                    selectedColor: primary.withValues(alpha: 0.3),
                    checkmarkColor: primary,
                    backgroundColor: AppTheme.textMutedColor(
                      context,
                    ).withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
