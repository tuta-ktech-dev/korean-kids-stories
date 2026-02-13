import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubits/audio_player_cubit/audio_player_cubit.dart';
import 'audio_progress_bar.dart';

/// A mini audio player that shows at the bottom of the screen.
/// Displays current track info, play/pause button, and a thin progress bar.
/// Tapping expands to show full controls.
class MiniAudioPlayer extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onExpand;
  final bool showExpandHint;

  const MiniAudioPlayer({
    super.key,
    this.onTap,
    this.onExpand,
    this.showExpandHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerReady || !state.hasAudio) {
          return const SizedBox.shrink();
        }

        final progress = state.progress;
        
        return GestureDetector(
          onTap: onTap ?? onExpand,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mini progress bar
                  MiniAudioProgressBar(
                    progress: progress,
                    bufferedProgress: state.bufferedProgress,
                    isBuffering: state.isBuffering,
                    progressColor: AppTheme.primaryColor(context),
                    height: 3,
                  ),
                  
                  // Player content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Story artwork placeholder
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor(context).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.primaryColor(context),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.chapterTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.storyTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMutedColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Play/Pause button
                        IconButton.filled(
                          onPressed: () {
                            context.read<AudioPlayerCubit>().togglePlayPause();
                          },
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor(context),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(40, 40),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        
                        // Expand button (optional)
                        if (showExpandHint) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: AppTheme.textMutedColor(context),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// An expanded version of the mini player with full controls
class ExpandedAudioPlayer extends StatelessWidget {
  final VoidCallback? onCollapse;
  final VoidCallback? onSkipNext;
  final VoidCallback? onSkipPrevious;

  const ExpandedAudioPlayer({
    super.key,
    this.onCollapse,
    this.onSkipNext,
    this.onSkipPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerReady) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                GestureDetector(
                  onTap: onCollapse,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.textMutedColor(context).withAlpha(50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Artwork
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor(context).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.primaryColor(context),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Track info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        state.chapterTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(context),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.storyTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textMutedColor(context),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AudioProgressBar(
                    position: state.position,
                    duration: state.duration,
                    bufferedPosition: state.bufferedPosition,
                    isBuffering: state.isBuffering,
                    onSeek: (position) {
                      context.read<AudioPlayerCubit>().seek(position);
                    },
                    height: 6,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skip backward 10s
                    _ControlButton(
                      icon: Icons.replay_10_rounded,
                      onPressed: () {
                        context.read<AudioPlayerCubit>().skipBackward(10);
                      },
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    
                    // Skip previous
                    _ControlButton(
                      icon: Icons.skip_previous_rounded,
                      onPressed: onSkipPrevious,
                      size: 48,
                      enabled: onSkipPrevious != null,
                    ),
                    const SizedBox(width: 16),
                    
                    // Play/Pause
                    IconButton.filled(
                      onPressed: () {
                        context.read<AudioPlayerCubit>().togglePlayPause();
                      },
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor(context),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(72, 72),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Skip next
                    _ControlButton(
                      icon: Icons.skip_next_rounded,
                      onPressed: onSkipNext,
                      size: 48,
                      enabled: onSkipNext != null,
                    ),
                    const SizedBox(width: 16),
                    
                    // Skip forward 10s
                    _ControlButton(
                      icon: Icons.forward_10_rounded,
                      onPressed: () {
                        context.read<AudioPlayerCubit>().skipForward(10);
                      },
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Playback speed
                _buildSpeedSelector(context, state),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedSelector(BuildContext context, AudioPlayerReady state) {
    final speeds = [0.75, 0.85, 1.0];
    final labels = ['0.75x', '0.85x', '1.0x'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(speeds.length, (index) {
        final speed = speeds[index];
        final isSelected = (state.speed - speed).abs() < 0.01;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(labels[index]),
            selected: isSelected,
            onSelected: (_) {
              context.read<AudioPlayerCubit>().setSpeed(speed);
            },
            selectedColor: AppTheme.primaryColor(context).withAlpha(40),
            backgroundColor: AppTheme.textMutedColor(context).withAlpha(20),
            labelStyle: TextStyle(
              color: isSelected
                  ? AppTheme.primaryColor(context)
                  : AppTheme.textMutedColor(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool enabled;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    required this.size,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      iconSize: size * 0.6,
      color: enabled
          ? AppTheme.textColor(context)
          : AppTheme.textMutedColor(context).withAlpha(100),
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
      ),
    );
  }
}

/// A widget that shows either mini or expanded player based on state
class AudioPlayerSheet extends StatefulWidget {
  final VoidCallback? onSkipNext;
  final VoidCallback? onSkipPrevious;

  const AudioPlayerSheet({
    super.key,
    this.onSkipNext,
    this.onSkipPrevious,
  });

  @override
  State<AudioPlayerSheet> createState() => _AudioPlayerSheetState();
}

class _AudioPlayerSheetState extends State<AudioPlayerSheet> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: MiniAudioPlayer(
        onTap: _toggleExpanded,
        showExpandHint: true,
      ),
      secondChild: ExpandedAudioPlayer(
        onCollapse: _toggleExpanded,
        onSkipNext: widget.onSkipNext,
        onSkipPrevious: widget.onSkipPrevious,
      ),
    );
  }
}
