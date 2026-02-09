import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;

  const AppSearchBar({
    super.key,
    required this.hintText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppTheme.textMutedColor(context),
            ),
            const SizedBox(width: 12),
            Text(
              hintText,
              style: AppTheme.bodyMedium(context),
            ),
          ],
        ),
      ),
    );
  }
}
