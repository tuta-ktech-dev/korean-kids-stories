import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/sticker.dart';
import '../../utils/extensions/context_extension.dart';

/// Dialog chúc mừng nhận sticker truyện - hiện ảnh sticker + animation.
/// Gọi [showStoryStickerCongratsDialog] để hiển thị.
void showStoryStickerCongratsDialog(
  BuildContext context, {
  required Sticker sticker,
  required String storyTitle,
  required VoidCallback onContinue,
  required VoidCallback onSeeAlbum,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StoryStickerCongratsDialog(
      sticker: sticker,
      storyTitle: storyTitle,
      onContinue: onContinue,
      onSeeAlbum: onSeeAlbum,
    ),
  );
}

class StoryStickerCongratsDialog extends StatefulWidget {
  final Sticker sticker;
  final String storyTitle;
  final VoidCallback onContinue;
  final VoidCallback onSeeAlbum;

  const StoryStickerCongratsDialog({
    super.key,
    required this.sticker,
    required this.storyTitle,
    required this.onContinue,
    required this.onSeeAlbum,
  });

  @override
  State<StoryStickerCongratsDialog> createState() =>
      _StoryStickerCongratsDialogState();
}

class _StoryStickerCongratsDialogState extends State<StoryStickerCongratsDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppTheme.primaryMint.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  final scale = 0.7 + (_bounceAnimation.value * 0.3);
                  return Transform.scale(
                    scale: scale,
                    child: ClipOval(
                      child: widget.sticker.imageUrl != null &&
                              widget.sticker.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.sticker.imageUrl!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 140,
                                height: 140,
                                color:
                                    AppTheme.primaryPink.withValues(alpha: 0.2),
                                child: Icon(Icons.emoji_events_rounded,
                                    size: 64, color: AppTheme.primaryPink),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 140,
                                height: 140,
                                color:
                                    AppTheme.primaryPink.withValues(alpha: 0.2),
                                child: Icon(Icons.emoji_events_rounded,
                                    size: 64, color: AppTheme.primaryPink),
                              ),
                            )
                          : Container(
                              width: 140,
                              height: 140,
                              color: AppTheme.primaryPink.withValues(alpha: 0.2),
                              child: Icon(Icons.emoji_events_rounded,
                                  size: 64, color: AppTheme.primaryPink),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.stickerEarnedTitle,
                textAlign: TextAlign.center,
                style: AppTheme.headingMedium(context),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPink.withValues(alpha: 0.2),
                      AppTheme.primaryMint.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.storyTitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onSeeAlbum,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge),
                        ),
                      ),
                      child: Text(context.l10n.stickerAlbum),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: widget.onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge),
                        ),
                      ),
                      child: Text(context.l10n.continueAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
