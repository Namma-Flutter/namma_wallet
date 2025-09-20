import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/bottom_navigation/presentation/namma_navigation_bar.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/home_view.dart';
import 'package:namma_wallet/src/features/profile/presentation/db_viewer_page.dart';
import 'package:namma_wallet/src/features/profile/presentation/profile_page.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:namma_wallet/src/features/scanner/presentation/scanner_view.dart';
import 'package:namma_wallet/src/features/travel/presentation/ticket_view.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => NammaNavigationBar(child: child),
      routes: [
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoute.scanner.path,
          name: AppRoute.scanner.name,
          builder: (context, state) => const TicketScannerPage(),
        ),
        GoRoute(
          path: AppRoute.calendar.path,
          name: AppRoute.calendar.name,
          builder: (context, state) => const CalendarPage(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.ticketView.path,
      name: AppRoute.ticketView.name,
      builder: (context, state) {
        final ticket = state.extra as GenericDetailsModel?;
        if (ticket == null) {
          return const Scaffold(
            body: Center(child: Text('Ticket not found')),
          );
        }
        return TicketView(ticket: ticket);
      },
    ),
    GoRoute(
      path: AppRoute.profile.path,
      name: AppRoute.profile.name,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoute.barcodeScanner.path,
      name: AppRoute.barcodeScanner.name,
      builder: (context, state) {
        final onDetect = state.extra as void Function(BarcodeCapture)?;
        return AiBarcodeScanner(
          overlayConfig: const ScannerOverlayConfig(
            borderColor: Colors.orange,
            animationColor: Colors.orange,
            cornerRadius: 30,
            lineThickness: 10,
          ),
          onDetect: onDetect ??
              (BarcodeCapture capture) {
                // Default handler if none provided
              },
        );
      },
    ),
    GoRoute(
      path: AppRoute.dbViewer.path,
      name: AppRoute.dbViewer.name,
      builder: (context, state) => const DbViewerPage(),
    ),
  ],
);
