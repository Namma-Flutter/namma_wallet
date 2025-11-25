import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';

/// Presentation layer handler for displaying PDF import results.
///
/// Separates UI concerns from the application service layer.
class PdfResultHandler {
  /// Shows a snackbar message based on the PDF import result.
  ///
  /// Displays success message when ticket is saved or error message on failure.
  /// Only shows if context is still mounted.
  static void showSuccessMessage(BuildContext context) {
    if (!context.mounted) return;

    showSnackbar(
      context,
      'PDF ticket saved successfully!',
    );
  }

  /// Shows an error message for PDF import failures.
  static void showErrorMessage(BuildContext context, String errorMessage) {
    if (!context.mounted) return;

    showSnackbar(
      context,
      errorMessage,
      isError: true,
    );
  }
}
