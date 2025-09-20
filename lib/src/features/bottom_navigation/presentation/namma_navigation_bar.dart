import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/bottom_navigation/presentation/widgets/nav_bar.dart';

class NammaNavigationBar extends StatefulWidget {
  const NammaNavigationBar({required this.child, super.key});
  final Widget child;

  @override
  State<NammaNavigationBar> createState() => _NammaNavigationBarState();
}

class _NammaNavigationBarState extends State<NammaNavigationBar> {
  bool _revealBar = false;

  // Define your tabs here
  final _items = <NavItem>[
    NavItem(
      icon: Icons.home,
      label: 'Home',
      route: AppRoute.home.path,
    ),
    NavItem(
      icon: Icons.qr_code_scanner,
      label: 'Scanner',
      route: AppRoute.scanner.path,
    ),
    NavItem(
      icon: Icons.calendar_today,
      label: 'Calendar',
      route: AppRoute.calendar.path,
    ),
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
            child: widget.child,
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
                  child: NavBar(
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
