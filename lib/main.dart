import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/i_wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize pdfrx (required when using PDF engine APIs before widgets)
  // with error handling to prevent app crashes
  var pdfFeaturesEnabled = true;
  Object? pdfInitError;
  StackTrace? pdfInitStackTrace;

  try {
    await pdfrxFlutterInitialize();
  } on Exception catch (e, stackTrace) {
    // PDF initialization failed - store error for logging later
    pdfFeaturesEnabled = false;
    pdfInitError = e;
    pdfInitStackTrace = stackTrace;
  } on Object catch (e, stackTrace) {
    // Catch any other throwables (non-Exception errors)
    pdfFeaturesEnabled = false;
    pdfInitError = e;
    pdfInitStackTrace = stackTrace;
  }

  // Setup dependency injection
  setupLocator();

  // Get logger instance
  ILogger? logger;
  try {
    logger = getIt<ILogger>()..info('Namma Wallet starting...');
  } on Object catch (e, s) {
    // Fallback to print if logger initialization fails,
    // as logger is not available.
    // ignore: avoid_print
    print('Error initializing logger or logging start message: $e\n$s');
  }

  // Log PDF initialization status with full context
  if (!pdfFeaturesEnabled && logger != null && pdfInitError != null) {
    // Collect contextual information for telemetry
    final platform = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;

    logger.error(
      'PDF initialization failed during startup. '
      'Platform: $platform, OS: $osVersion. '
      'PDF features disabled.',
      pdfInitError,
      pdfInitStackTrace,
    );
  } else if (pdfFeaturesEnabled && logger != null) {
    logger.info('PDF features enabled successfully');
  }

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    if (logger != null) {
      logger.error(
        'Flutter Error: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    } else {
      // Fallback to print if logger is not available,
      // to ensure error messages are still visible.
      // ignore: avoid_print
      print(
        '''FALLBACK LOGGER - Flutter Error: ${details.exceptionAsString()}\n${details.stack}''',
      );
    }
  };

  // Catch errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    if (logger != null) {
      logger.error(
        'Platform Error: $error',
        error,
        stack,
      );
    } else {
      // Fallback to print if logger is not available,
      // to ensure error messages are still visible.
      // ignore: avoid_print
      print('FALLBACK LOGGER - Platform Error: $error\n$stack');
    }
    return true;
  };

  try {
    logger?.info('Initializing Gemma Chat Service...');
    await getIt<GemmaChatService>().init();
    logger?.success('Gemma Chat Service initialized');

    logger?.info('Initializing database...');
    await getIt<IWalletDatabase>().database;
    logger?.success('Database initialized');

    logger?.success('All services initialized successfully');
  } on Object catch (e, stackTrace) {
    // Log error using logger if available
    logger?.error(
      'Error during initialization: $e',
      e,
      stackTrace,
    );

    // Fallback: ensure error is always visible even if logger is null
    if (logger == null) {
      // Write to stderr for visibility in production/debug
      stderr
        ..writeln('=' * 80)
        ..writeln('CRITICAL: Initialization failed and logger unavailable')
        ..writeln('=' * 80)
        ..writeln('Error: $e')
        ..writeln('Stack trace:')
        ..writeln(stackTrace)
        ..writeln('=' * 80);

      // Also print for debug console visibility
      // Print statements are necessary here as logger is unavailable
      // ignore: avoid_print
      print('CRITICAL INITIALIZATION ERROR: $e');
      // Print statements are necessary here as logger is unavailable
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
    }

    // Always rethrow to prevent app from starting in broken state
    rethrow;
  }

  runApp(
    ChangeNotifierProvider.value(
      value: getIt<ThemeProvider>(),
      child: const NammaWalletApp(),
    ),
  );
}
