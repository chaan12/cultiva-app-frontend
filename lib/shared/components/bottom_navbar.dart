import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CultivaBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CultivaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CultivaBottomNav> createState() => _CultivaBottomNavState();
}

class _CultivaBottomNavState extends State<CultivaBottomNav> {
  void _handleNavigation(int index) {
    if (index == widget.currentIndex) return;
    widget.onTap(index);
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool active = widget.currentIndex == index;
    final activeBg = AppColors.isDark(context)
        ? const Color(0xFF203327)
        : AppColors.cream;
    final inactiveColor = AppColors.isDark(context)
        ? const Color(0xFFD9E8DD)
        : Colors.black;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 9),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey(active),
                  color: active ? AppColors.greenPrimary : inactiveColor,
                  size: 23,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.greenPrimary : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark(context) ? 0.35 : 0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navItem(icon: Icons.home_outlined, label: 'Inicio', index: 0),
          navItem(icon: Icons.list_alt_outlined, label: 'Cultivos', index: 1),
          navItem(icon: Icons.spa_outlined, label: 'Catálogo', index: 2),
          navItem(icon: Icons.storefront_outlined, label: 'Mercado', index: 3),
          navItem(icon: Icons.cloud_outlined, label: 'Clima', index: 4),
          navItem(icon: Icons.settings_outlined, label: 'Config', index: 5),
        ],
      ),
    );
  }
}
