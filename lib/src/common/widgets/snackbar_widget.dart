import 'dart:developer' as developer;
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  // Print to console for debugging
  if (isError) {
    developer.log('ERROR: $message', name: 'SnackbarError');
    print('🔴 ERROR: $message');
  } else {
    developer.log('INFO: $message', name: 'SnackbarInfo');
    print('ℹ️ INFO: $message');
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
    ),
  );
}
