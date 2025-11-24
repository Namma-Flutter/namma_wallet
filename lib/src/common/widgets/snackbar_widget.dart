import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

/// Custom SnackBar widget with enhanced styling, icons,
/// and responsive positioning above the bottom navigation bar.
/// This widget creates a floating snackbar that appears above
/// the bottom navigation bar with theme-aware colors for success
/// and error states.
class CustomSnackBar extends SnackBar {
  /// Creates a custom snackbar with the given message and error state
  ///
  /// [message] The text to display in the snackbar
  /// [isError] Whether this is an error message (true) or success message
  /// (false)
  /// [context] BuildContext for accessing theme and screen dimensions
  /// [duration] Optional custom duration, defaults to 3s for errors,
  ///  2s for success
  CustomSnackBar({
    required String message,
    required bool isError,
    required BuildContext context,
    super.key,
    Duration? duration,
  }) : super(
         content: Row(
           children: [
             Icon(
               isError ? Icons.error_outline : Icons.check_circle_outline,
               color: Colors.white,
               size: 24,
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 message,
                 style: const TextStyle(
                   color: Colors.white,
                   fontSize: 14,
                   fontWeight: FontWeight.w500,
                 ),
               ),
             ),
           ],
         ),
         backgroundColor: isError
             ? Theme.of(context).colorScheme.error
             : Theme.of(context).colorScheme.secondary,
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
         // Position the snackbar just above the bottom navigation bar
         // Adds 80px for typical bottom nav bar height plus 16px spacing
         margin: EdgeInsets.only(
           bottom: MediaQuery.of(context).padding.bottom + 80 + 16,
           left: 16,
           right: 16,
         ),
         duration: duration ?? Duration(seconds: isError ? 3 : 2),
         dismissDirection: DismissDirection.up,
       );
}

/// Helper function to show custom snackbar messages
///
/// Displays a themed snackbar above the bottom navigation bar with appropriate
/// styling and logging based on whether it's an error or success message.
///
/// [context] BuildContext for accessing theme and screen dimensions
/// [message] The text to display in the snackbar
/// [isError] Whether this is an error message (defaults to false)
/// [duration] Optional custom duration, defaults to 3s for errors,
/// 2s for success
void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration? duration,
}) {
  final logger = getIt<ILogger>();

  // Log to console for debugging
  if (isError) {
    logger.error(message);
  } else {
    logger.info(message);
  }

  // Show custom snackbar above bottom navigation bar
  ScaffoldMessenger.of(context).showSnackBar(
    CustomSnackBar(
      message: message,
      isError: isError,
      context: context,
      duration: duration,
    ),
  );
}
