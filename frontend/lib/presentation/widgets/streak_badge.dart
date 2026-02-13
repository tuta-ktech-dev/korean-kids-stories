import 'package:flutter/material.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

import '../../core/theme/app_theme.dart';

/// Streak milestone: image/emoji + gradient. Images have Korean text (3일, 7일, 14일, 30일).
/// 1-2: 📖 green, 3-6: streak_3_days, 7-13: streak_7_days, 14-29: streak_14_days, 30+: streak_30_days
class StreakMilestone {
  final String emoji;
  final String? imageAsset;
  final Color colorStart;
  final Color colorEnd;
  final Color borderColor;

  const StreakMilestone({
    required this.emoji,
    this.imageAsset,
    required this.colorStart,
    required this.colorEnd,
    required this.borderColor,
  });

  static StreakMilestone forDays(int days) {
    if (days >= 30) {
      return const StreakMilestone(
        emoji: '👑',
        imageAsset: 'assets/images/streak_30_days.webp',
        colorStart: Color(0xFFFFD700),
        colorEnd: Color(0xFFFFA500),
        borderColor: Color(0xFFFFD700),
      );
    }
    if (days >= 14) {
      return const StreakMilestone(
        emoji: '🏆',
        imageAsset: 'assets/images/streak_14_days.webp',
        colorStart: Color(0xFF9F7AEA),
        colorEnd: Color(0xFF667EEA),
        borderColor: Color(0xFF9F7AEA),
      );
    }
    if (days >= 7) {
      return const StreakMilestone(
        emoji: '🔥',
        imageAsset: 'assets/images/streak_7_days.webp',
        colorStart: Color(0xFFFF9800),
        colorEnd: Color(0xFFF44336),
        borderColor: Color(0xFFFFB74D),
      );
    }
    if (days >= 3) {
      return const StreakMilestone(
        emoji: '⭐',
        imageAsset: 'assets/images/streak_3_days.webp',
        colorStart: Color(0xFFFFE082),
        colorEnd: Color(0xFFFFCA28),
        borderColor: Color(0xFFFFD54F),
      );
    }
    return const StreakMilestone(
      emoji: '📖',
      imageAsset: null,
      colorStart: Color(0xFF81C784),
      colorEnd: Color(0xFF4DB6AC),
      borderColor: Color(0xFFA5D6A7),
    );
  }
}

/// Reusable streak badge with milestone emoji and gradient.
class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final milestone = StreakMilestone.forDays(currentStreak > 0 ? currentStreak : longestStreak);

    return Container(
      margin: compact ? const EdgeInsets.only(bottom: 24) : const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 16,
        vertical: compact ? 16 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            milestone.colorStart.withValues(alpha: compact ? 0.25 : 0.35),
            milestone.colorEnd.withValues(alpha: compact ? 0.2 : 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? AppTheme.radiusMedium : 12),
        border: Border.all(
          color: milestone.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentStreak > 0) ...[
            if (milestone.imageAsset != null)
              Image.asset(
                milestone.imageAsset!,
                width: compact ? 56 : 48,
                height: compact ? 56 : 48,
                fit: BoxFit.contain,
              )
            else
              Text(
                milestone.emoji,
                style: TextStyle(fontSize: compact ? 28 : 24),
              ),
            const SizedBox(width: 8),
            Text(
              context.l10n.streakBadgeText(currentStreak),
              style: AppTheme.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (longestStreak > 0 && longestStreak != currentStreak) ...[
            if (currentStreak > 0) ...[
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 20,
                color: AppTheme.textMutedColor(context).withValues(alpha: 0.5),
              ),
              const SizedBox(width: 16),
            ],
            Text(
              context.l10n.streakLongest(longestStreak),
              style: AppTheme.bodyMedium(context).copyWith(
                color: AppTheme.textMutedColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
