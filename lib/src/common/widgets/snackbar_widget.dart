import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';

void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final logger = getIt<ILogger>();
  // Print to console for debugging
  if (isError) {
    logger.error(message);
  } else {
    logger.info(message);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
    ),
  );
}
