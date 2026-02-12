import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:korean_kids_stories/utils/extensions/context_extension.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _NavItemData(icon: Icons.home_rounded, semanticLabel: l10n.homeTab),
      _NavItemData(icon: Icons.emoji_events_rounded, semanticLabel: l10n.stickerAlbum),
      _NavItemData(icon: Icons.history_rounded, semanticLabel: l10n.historyTab),
      _NavItemData(icon: Icons.settings_rounded, semanticLabel: l10n.settingsTab),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => _NavItem(
            icon: items[index].icon,
            semanticLabel: items[index].semanticLabel,
            isActive: currentIndex == index,
            onTap: () => onTap(index),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String semanticLabel;

  _NavItemData({required this.icon, required this.semanticLabel});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.semanticLabel,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor(context);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Icon(
            icon,
            color: isActive ? primaryColor : AppTheme.textMutedColor(context),
            size: 28,
          ),
        ),
      ),
    );
  }
}
