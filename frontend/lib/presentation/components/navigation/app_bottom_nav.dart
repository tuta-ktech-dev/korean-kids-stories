import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showSettings;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showSettings = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(icon: Icons.home_rounded, label: '홈'),
      _NavItemData(icon: Icons.search_rounded, label: '탐색'),
      _NavItemData(icon: Icons.history_rounded, label: '기록'),
      if (showSettings) _NavItemData(icon: Icons.person_rounded, label: '내정보'),
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
            label: items[index].label,
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
  final String label;

  _NavItemData({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : AppTheme.textMutedColor(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.caption(context).copyWith(
                color: isActive ? primaryColor : AppTheme.textMutedColor(context),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
