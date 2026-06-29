import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppTabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTab;

  const AppTabBar({
    super.key,
    required this.active,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          color: isDark ? AppColors.darkSurface : Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          padding: EdgeInsets.zero,
          elevation: 0,
          child: SizedBox(
            height: 65, // Taller for better touch target
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _TabItem(icon: Icons.home_rounded, label: 'Home', tabKey: 'home', active: active, onTap: onTab),
                  _TabItem(icon: Icons.local_offer_rounded, label: 'Promo', tabKey: 'promo', active: active, onTap: onTab),
                  
                  // Empty space for the floating QRIS button
                  const SizedBox(width: 48),
                  
                  _TabItem(icon: Icons.history_rounded, label: 'History', tabKey: 'history', active: active, onTap: onTab),
                  _TabItem(icon: Icons.settings_rounded, label: 'Settings', tabKey: 'akun', active: active, onTap: onTab),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tabKey;
  final String active;
  final ValueChanged<String> onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.tabKey,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = active == tabKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final activeColor = AppColors.bluePrimary;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => onTap(tabKey),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
