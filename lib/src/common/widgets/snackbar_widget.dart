import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/services/namma_logger.dart';

void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final logger = NammaLogger();
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
