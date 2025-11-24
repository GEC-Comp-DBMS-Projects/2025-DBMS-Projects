import 'package:flutter/material.dart';


// A data class for our navigation bar item
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
  });
}

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  // List of navigation items
  static const _navItems = [
    BottomNavItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle),
    BottomNavItem(icon: Icons.login_rounded, activeIcon: Icons.login),
    BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    BottomNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore),
    BottomNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
  ];

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(95),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(95),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            return _buildNavItem(
              context: context,
              item: item,
              index: index,
              isActive: index == currentIndex,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required BottomNavItem item,
    required int index,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.7);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index), // Call the callback with the tapped index
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: isActive ? const EdgeInsets.all(8) : const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? theme.colorScheme.onPrimary : inactiveColor,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}