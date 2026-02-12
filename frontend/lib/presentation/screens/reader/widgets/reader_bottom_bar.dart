import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ReaderBottomBar extends StatelessWidget {
  final bool isDarkMode;
  final double progress;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevChapter;
  final VoidCallback? onNextChapter;

  const ReaderBottomBar({
    super.key,
    this.isDarkMode = false,
    this.progress = 0.0,
    this.isPlaying = false,
    this.onPlayPause,
    this.onPrevChapter,
    this.onNextChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : AppTheme.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: onPrevChapter,
                ),
                IconButton.filled(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  iconSize: 40,
                  onPressed: onPlayPause,
                ),
                IconButton(
                  icon: Icon(
                    Icons.skip_next_rounded,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: onNextChapter,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
