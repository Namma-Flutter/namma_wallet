import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';

/// Presentation layer handler for displaying IRCTC scanner results.
///
/// Separates UI concerns from the application service layer.
class IRCTCResultHandler {
  /// Shows a snackbar message based on the IRCTC scanner result.
  ///
  /// Displays success message when ticket is saved or error message on failure.
  /// Only shows if context is still mounted.
  static void showResultMessage(
    BuildContext context,
    IRCTCScannerResult result,
  ) {
    if (!context.mounted) return;

    final message = result.isSuccess
        ? switch (result.type) {
            IRCTCScannerContentType.irctcTicket =>
              'IRCTC ticket saved successfully!',
            IRCTCScannerContentType.invalid => 'Invalid content',
          }
        : result.errorMessage ?? 'Unknown error occurred';

    showSnackbar(
      context,
      message,
      isError: !result.isSuccess,
    );
  }
}
