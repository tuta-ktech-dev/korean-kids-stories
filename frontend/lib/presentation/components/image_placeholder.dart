import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A reusable placeholder widget for when an image is not available
class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final String? label;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image_outlined,
    this.iconSize = 48,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 16,
    this.label,
  });

  /// Create a story-themed placeholder
  factory ImagePlaceholder.story({
    Key? key,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? iconColor,
    double borderRadius = 16,
  }) {
    return ImagePlaceholder(
      key: key,
      width: width,
      height: height,
      icon: Icons.auto_stories_rounded,
      iconSize: 48,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderRadius: borderRadius,
    );
  }

  /// Create a chapter/illustration placeholder
  factory ImagePlaceholder.illustration({
    Key? key,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? iconColor,
    double borderRadius = 12,
  }) {
    return ImagePlaceholder(
      key: key,
      width: width,
      height: height,
      icon: Icons.palette_outlined,
      iconSize: 36,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderRadius: borderRadius,
      label: '일러스트',
    );
  }

  /// Create an avatar/profile placeholder
  factory ImagePlaceholder.avatar({
    Key? key,
    double size = 64,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return ImagePlaceholder(
      key: key,
      width: size,
      height: size,
      icon: Icons.person_outline,
      iconSize: size * 0.4,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderRadius: size / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getDefaultBackgroundColor(context);
    final fgColor = iconColor ?? _getDefaultIconColor(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: fgColor,
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              style: AppTheme.caption(context).copyWith(
                color: fgColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDefaultBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? AppTheme.darkPrimaryPink.withOpacity(0.1)
        : AppTheme.primaryPink.withOpacity(0.1);
  }

  Color _getDefaultIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark 
        ? AppTheme.darkPrimaryPink
        : AppTheme.primaryPink;
  }
}
