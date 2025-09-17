import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  const NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Ensures hit target even when label hidden
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Icon animates size a bit when selected
            AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(right: selected ? 6 : 0),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.08 : 1.0,
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 24,
                  color: selected ? Colors.black : Colors.white,
                ),
              ),
            ),

            // Label smoothly expands/collapses with a fade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: selected
                  ? Text(
                      label,
                      key: const ValueKey('label'),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('spacer')),
            ),
          ],
        ),
      ),
    );
  }
}
