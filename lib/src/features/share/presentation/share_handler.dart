import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/share/domain/shared_content_result.dart';

/// Handles share result navigation and UI feedback
class ShareHandler {
  ShareHandler({
    required this.router,
    required this.scaffoldMessengerKey,
  });

  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  /// Handle the result of shared content processing
  void handleResult(SharedContentResult result) {
    switch (result) {
      case TicketCreatedResult(
        :final pnrNumber,
        :final from,
        :final to,
        :final fare,
        :final date,
      ):
        router.go(
          AppRoute.shareSuccess.path,
          extra: {
            'pnrNumber': pnrNumber,
            'from': from,
            'to': to,
            'fare': fare,
            'date': date,
          },
        );

      case TicketUpdatedResult(:final pnrNumber, :final updateType):
        // Reuse share success screen with update-specific values
        // 'to' field displays the update type (e.g., 'Seat', 'Platform')
        // to provide user feedback about what was updated
        router.go(
          AppRoute.shareSuccess.path,
          extra: {
            'pnrNumber': pnrNumber,
            'from': 'Updated',
            'to': updateType,
            'fare': 'Updated',
            'date': 'Just Now',
          },
        );

      case TicketNotFoundResult():
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text(
              'Update received, but the original ticket was not found.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        router.go(AppRoute.home.path);

      case ProcessingErrorResult(:final error):
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error processing shared content: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        router.go(AppRoute.home.path);
    }
  }

  /// Handle sharing errors
  void handleError(String error) {
    // Show error message
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Sharing error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );

    // Navigate back to home on error
    router.go(AppRoute.home.path);
  }
}
