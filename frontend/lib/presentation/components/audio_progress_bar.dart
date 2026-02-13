import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A professional audio progress bar with seek functionality.
/// Shows current position, total duration, and buffer progress.
class AudioProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final bool isBuffering;
  final ValueChanged<Duration>? onSeek;
  final Color? progressColor;
  final Color? bufferedColor;
  final Color? backgroundColor;
  final double height;
  final bool showTime;
  final TextStyle? timeTextStyle;

  const AudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.bufferedPosition = Duration.zero,
    this.isBuffering = false,
    this.onSeek,
    this.progressColor,
    this.bufferedColor,
    this.backgroundColor,
    this.height = 4.0,
    this.showTime = true,
    this.timeTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveProgressColor = progressColor ?? AppTheme.primaryColor(context);
    final effectiveBufferedColor = bufferedColor ?? 
        (isDark ? Colors.white.withAlpha(40) : Colors.black.withAlpha(40));
    final effectiveBackgroundColor = backgroundColor ?? 
        (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20));

    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final bufferedProgress = duration.inMilliseconds > 0
        ? (bufferedPosition.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress slider with buffer indicator
        GestureDetector(
          onTapUp: (details) {
            if (onSeek == null || duration == Duration.zero) return;
            
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            
            final localPosition = box.globalToLocal(details.globalPosition);
            final width = box.size.width;
            final tapProgress = (localPosition.dx / width).clamp(0.0, 1.0);
            final seekPosition = Duration(
              milliseconds: (tapProgress * duration.inMilliseconds).round(),
            );
            onSeek!(seekPosition);
          },
          onHorizontalDragUpdate: (details) {
            if (onSeek == null || duration == Duration.zero) return;
            
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            
            final localPosition = box.globalToLocal(details.globalPosition);
            final width = box.size.width;
            final dragProgress = (localPosition.dx / width).clamp(0.0, 1.0);
            final seekPosition = Duration(
              milliseconds: (dragProgress * duration.inMilliseconds).round(),
            );
            onSeek!(seekPosition);
          },
          child: Container(
            height: 24, // Tappable area
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: effectiveBackgroundColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                
                // Buffered progress
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: height,
                  width: bufferedProgress * (MediaQuery.of(context).size.width - 48),
                  decoration: BoxDecoration(
                    color: effectiveBufferedColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                
                // Played progress
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: height,
                  width: progress * (MediaQuery.of(context).size.width - 48),
                  decoration: BoxDecoration(
                    color: effectiveProgressColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                
                // Thumb handle
                Positioned(
                  left: (progress * (MediaQuery.of(context).size.width - 48)) - 6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: effectiveProgressColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Buffering indicator overlay
                if (isBuffering)
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveProgressColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Time display
        if (showTime)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: timeTextStyle ?? TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMutedColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isBuffering)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textMutedColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Loading...',
                        style: timeTextStyle ?? TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                Text(
                  _formatDuration(duration),
                  style: timeTextStyle ?? TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMutedColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// A mini version of the progress bar for compact spaces
class MiniAudioProgressBar extends StatelessWidget {
  final double progress;
  final double bufferedProgress;
  final bool isBuffering;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const MiniAudioProgressBar({
    super.key,
    required this.progress,
    this.bufferedProgress = 0.0,
    this.isBuffering = false,
    this.progressColor,
    this.backgroundColor,
    this.height = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? AppTheme.primaryColor(context);
    final effectiveBackgroundColor = backgroundColor ?? 
        AppTheme.textMutedColor(context).withAlpha(30);

    return Stack(
      children: [
        // Background
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        
        // Buffered progress
        Container(
          height: height,
          width: MediaQuery.of(context).size.width * bufferedProgress.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            color: effectiveProgressColor.withAlpha(80),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        
        // Played progress
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: height,
          width: MediaQuery.of(context).size.width * progress.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            color: effectiveProgressColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        
        // Buffering shimmer effect
        if (isBuffering)
          Positioned.fill(
            child: _ShimmerEffect(
              color: effectiveProgressColor.withAlpha(60),
            ),
          ),
      ],
    );
  }
}

/// Shimmer effect for buffering indicator
class _ShimmerEffect extends StatefulWidget {
  final Color color;

  const _ShimmerEffect({required this.color});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: 0.3,
          alignment: Alignment(_animation.value, 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  widget.color,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
