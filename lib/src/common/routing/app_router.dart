import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/bottom_navigation/presentation/namma_navigation_bar.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_view.dart';
import 'package:namma_wallet/src/features/export/presentation/export_view.dart';
import 'package:namma_wallet/src/features/home/presentation/all_tickets_view.dart';
import 'package:namma_wallet/src/features/home/presentation/home_view.dart';
import 'package:namma_wallet/src/features/import/presentation/import_view.dart';
import 'package:namma_wallet/src/features/receive/presentation/share_success_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/contributors_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/db_viewer_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/license_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/ocr_debug_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/reminder_settings_view.dart';
import 'package:namma_wallet/src/features/settings/presentation/settings_view.dart';
import 'package:namma_wallet/src/features/travel/presentation/travel_ticket_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  onException: (context, state, _) {
    getIt<ILogger>().error(
      'Navigation exception: ${state.uri}',
      state.error,
    );
  },
  redirect: (context, state) {
    // Handle deep links with custom scheme (e.g., nammawallet://ticket/123)
    // Convert to proper path (e.g., /ticket/123)
    final uri = state.uri;
    if (uri.scheme == 'nammawallet') {
      // Reconstruct path from host and path
      // nammawallet://ticket/T75229210 -> /ticket/T75229210
      final redirectPath = '/${uri.host}${uri.path}';
      getIt<ILogger>().info(
        'Deep link redirect: $uri -> $redirectPath',
      );
      return redirectPath;
    }
    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => NammaNavigationBar(child: child),
      routes: [
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: AppRoute.import.path,
          name: AppRoute.import.name,
          builder: (context, state) => const ImportView(),
        ),
        GoRoute(
          path: AppRoute.calendar.path,
          name: AppRoute.calendar.name,
          builder: (context, state) => const CalendarView(),
        ),
        GoRoute(
          path: AppRoute.export.path,
          name: AppRoute.export.name,
          builder: (context, state) => const ExportView(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoute.ticketView.path,
      name: AppRoute.ticketView.name,
      builder: (context, state) {
        final ticketId = state.pathParameters['id'];

        if (ticketId != null && ticketId.isNotEmpty) {
          return _TicketViewLoader(ticketId: ticketId);
        }

        return const Scaffold(
          body: Center(child: Text('Invalid ticket ID')),
        );
      },
    ),
    GoRoute(
      path: AppRoute.allTickets.path,
      name: AppRoute.allTickets.name,
      builder: (context, state) => const AllTicketsView(),
    ),
    GoRoute(
      path: AppRoute.settings.path,
      name: AppRoute.settings.name,
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: AppRoute.reminderSettings.path,
      name: AppRoute.reminderSettings.name,
      builder: (context, state) => const ReminderSettingsView(),
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
          onDetect:
              onDetect ??
              (BarcodeCapture capture) {
                // Default handler if none provided
              },
        );
      },
    ),
    GoRoute(
      path: AppRoute.dbViewer.path,
      name: AppRoute.dbViewer.name,
      builder: (context, state) => const DbViewerView(),
    ),
    GoRoute(
      path: AppRoute.ocrDebug.path,
      name: AppRoute.ocrDebug.name,
      builder: (context, state) => const OCRDebugView(),
    ),
    GoRoute(
      path: AppRoute.license.path,
      name: AppRoute.license.name,
      builder: (context, state) => const LicenseView(),
    ),
    GoRoute(
      path: AppRoute.contributors.path,
      name: AppRoute.contributors.name,
      builder: (context, state) => const ContributorsView(),
    ),
    GoRoute(
      path: AppRoute.shareSuccess.path,
      name: AppRoute.shareSuccess.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid share data')),
          );
        }
        return ShareSuccessView(
          pnrNumber: extra['pnrNumber'] as String?,
          from: extra['from'] as String?,
          to: extra['to'] as String?,
          fare: extra['fare'] as String?,
          date: extra['date'] as String?,
        );
      },
    ),
  ],
);

// Widget to load ticket by ID asynchronously
class _TicketViewLoader extends StatelessWidget {
  const _TicketViewLoader({required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Ticket?>(
      future: getIt<ITicketDAO>().getTicketById(ticketId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading ticket: ${snapshot.error}'),
            ),
          );
        }

        final ticket = snapshot.data;
        if (ticket == null) {
          return const Scaffold(
            body: Center(child: Text('Ticket not found')),
          );
        }

        return TravelTicketView(ticket: ticket);
      },
    );
  }
}
