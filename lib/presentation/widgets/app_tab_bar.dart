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
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BottomAppBar(
        color: const Color(0xFFDFF26E), // Revert to Neon Green background
        shape: const CircularNotchedRectangle(), // Creates the transparent 'U' cutout
        notchMargin: 6.0,
        padding: EdgeInsets.zero, // Remove default padding
        child: SizedBox(
          height: 52, // Fixed height for exact proportions
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center, // Aligns everything exactly on the Y axis
            children: [
              Expanded(child: _TabItem(icon: Icons.home_rounded, label: 'Beranda', tabKey: 'home', active: active, onTap: onTab)),
              Expanded(child: _TabItem(icon: Icons.credit_card_rounded, label: 'Kartu', tabKey: 'promo', active: active, onTap: onTab)),
              
              // Empty space for the floating QRIS button
              const SizedBox(width: 56),
              
              Expanded(child: _TabItem(icon: Icons.history_rounded, label: 'Riwayat', tabKey: 'history', active: active, onTap: onTab)),
              Expanded(child: _TabItem(icon: Icons.person_rounded, label: 'Profil', tabKey: 'akun', active: active, onTap: onTab)),
            ],
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
    return GestureDetector(
      onTap: () => onTap(tabKey),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? Colors.black : Colors.black45, // Black icons on green background
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.black : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
