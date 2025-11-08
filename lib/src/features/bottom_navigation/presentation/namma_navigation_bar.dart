import 'dart:async';

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
  int? _pendingIndex; // Track pending navigation for immediate UI feedback
  Timer? _navigationTimer; // Track cancellable navigation timer

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
      // Cancel any existing navigation timer to prevent stale navigations
      _navigationTimer?.cancel();

      // Update UI immediately for smooth highlight transition
      setState(() {
        _pendingIndex = index;
      });

      HapticFeedback.selectionClick();

      // Use cancellable Timer for navigation delay
      _navigationTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.go(target);
          // Clear pending state after navigation
          setState(() {
            _pendingIndex = null;
          });
        }
        _navigationTimer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final locationIndex = _indexFromLocation(location);
    // Use pending index for immediate UI feedback,
    // fallback to location-based index
    final currentIndex = _pendingIndex ?? locationIndex;

    return Scaffold(
      // Smooth page transitions between shell children
      body: Stack(
        children: [
          // The page content, with ultra-smooth fade transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOutCubicEmphasized,
            switchOutCurve: Curves.easeInOutCubicEmphasized,
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

          // Floating nav bar with ultra-smooth animations
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubicEmphasized,
                offset: _revealBar ? Offset.zero : const Offset(0, 0.08),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubicEmphasized,
                  opacity: _revealBar ? 1 : 0,
                  child: Center(
                    child: NavBar(
                      items: _items,
                      currentIndex: currentIndex,
                      onTap: (i) => _changeTab(context, i),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }
}
