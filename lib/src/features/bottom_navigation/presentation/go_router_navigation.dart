import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/features/bottom_navigation/presentation/bottom_navigation.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/home/presentation/home_page.dart';
import 'package:namma_wallet/src/features/scanner/presentation/scanner_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BottomNavigation(child: child),
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/scanner',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const TicketScannerPage(),
        ),
        GoRoute(
          path: '/calendar',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const CalendarPage(),
        ),
      ],
    )
  ],
);
