import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_content_type.dart';
import 'package:namma_wallet/src/features/clipboard/domain/clipboard_result.dart';

/// Presentation layer handler for displaying clipboard operation results.
///
/// Separates UI concerns from the application service layer.
class ClipboardResultHandler {
  /// Shows a snackbar message based on the clipboard result.
  ///
  /// Displays success message or error.
  /// Only shows if context is still mounted.
  static void showResultMessage(
    BuildContext context,
    ClipboardResult result,
  ) {
    if (!context.mounted) return;

    final message = result.isSuccess
        ? switch (result.type) {
            ClipboardContentType.travelTicket =>
              result.ticket != null
                  ? 'Travel ticket saved successfully!'
                  : 'Ticket updated with conductor details!',
            ClipboardContentType.invalid => 'Unknown content type',
          }
        : result.errorMessage ?? 'Unknown error occurred';
    if (result.ticket != null &&
        result.isSuccess &&
        result.type == ClipboardContentType.travelTicket &&
        Platform.isAndroid) {
      unawaited(
        NotificationService().scheduleTicketReminderFor(result.ticket!),
      );
    }

    showSnackbar(
      context,
      message,
      isError: !result.isSuccess,
    );
  }
}
