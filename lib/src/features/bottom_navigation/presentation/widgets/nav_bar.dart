import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/bottom_navigation/presentation/widgets/nav_button.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            // Transparent glassy background
            color: isDark
                ? AppColor.whiteColor.withValues(alpha: 0.1)
                : AppColor.whiteColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: isDark
                  ? AppColor.whiteColor.withValues(alpha: 0.2)
                  : AppColor.whiteColor.withValues(alpha: 0.3),
              width: 0.8,
            ),
            boxShadow: [
              // Soft glowing shadow for glass effect
              BoxShadow(
                color: isDark
                    ? AppColor.whiteColor.withValues(alpha: 0.1)
                    : AppColor.blackColor.withValues(alpha: 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
              // Inner highlight for glass effect
              BoxShadow(
                color: AppColor.whiteColor.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = currentIndex == index;

              return NavButton(
                icon: item.icon,
                label: item.label,
                selected: selected,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
