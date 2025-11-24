import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

/// Custom SnackBar widget with enhanced styling, icons, and top positioning
class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    required String message,
    required bool isError,
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
             ? const Color(0xffF44336) // Red for errors
             : const Color(0xff4CAF50), // Green for success
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
         margin: const EdgeInsets.only(
           top: 50,
           left: 16,
           right: 16,
           bottom: 100,
         ),
         duration: duration ?? Duration(seconds: isError ? 3 : 2),
         dismissDirection: DismissDirection.up,
       );
}

/// Helper function to show custom snackbar messages
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

  // Show custom snackbar at top of screen
  ScaffoldMessenger.of(context).showSnackBar(
    CustomSnackBar(
      message: message,
      isError: isError,
      duration: duration,
    ),
  );
}
