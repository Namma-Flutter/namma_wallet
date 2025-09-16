import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({required this.child, super.key});
  final Widget child;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  bool _revealBar = false;

  // Define your tabs here
  final _items = const <_NavItem>[
    _NavItem(icon: Icons.home, label: 'Home', route: '/'),
    _NavItem(icon: Icons.qr_code_scanner, label: 'Scanner', route: '/scanner'),
    _NavItem(icon: Icons.calendar_today, label: 'Calendar', route: '/calendar'),
  ];

  @override
  void initState() {
    super.initState();
    // Smooth entrance for the bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _revealBar = true);
    });
  }

  int _indexFromLocation(String location) {
    // Match by prefix so nested routes like /calendar/day also select "Calendar"
    final matchIndex = _items.indexWhere((e) {
      if (e.route == '/') {
        return location == '/';
      }
      return location == e.route || location.startsWith('${e.route}/');
    });
    return matchIndex == -1 ? 0 : matchIndex;
  }

  void _changeTab(BuildContext context, int index) {
    final target = _items[index].route;
    final current = GoRouterState.of(context).uri.toString();
    if (current != target) {
      HapticFeedback.selectionClick();
      context.go(target);
    }
    // No setState needed; selection derives from location
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      // Smooth page transitions between shell children
      body: Stack(
        children: [
          // The page content, with a fade transition keyed by location
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey(location),
              child: widget.child,
            ),
          ),

          // Floating nav bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                offset: _revealBar ? Offset.zero : const Offset(0, 0.15),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  opacity: _revealBar ? 1 : 0,
                  child: _NavBar(
                    items: _items,
                    currentIndex: currentIndex,
                    onTap: (i) => _changeTab(context, i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = currentIndex == index;

          return _NavButton(
            icon: item.icon,
            label: item.label,
            selected: selected,
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
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

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
