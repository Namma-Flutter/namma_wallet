import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/platform_utils/platform_utils.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_services.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';
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
  await HapticServices.loadPreference();
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
  if (!pdfFeaturesEnabled && pdfInitError != null) {
    if (logger != null) {
      // Log with full context if logger is available
      logger.error(
        'PDF initialization failed during startup ${getPlatformInfo()}. '
        'PDF features disabled.',
        pdfInitError,
        pdfInitStackTrace,
      );
    } else {
      // Fallback: ensure error is visible even if logger is unavailable
      logCriticalError(pdfInitError, pdfInitStackTrace ?? StackTrace.current);
      // fallback print to debug console
      // ignore: avoid_print
      print(
        'PDF INITIALIZATION FAILED on ${getPlatformInfo()}: $pdfInitError',
      );
    }
  } else if (pdfFeaturesEnabled && logger != null) {
    logger.info('PDF features enabled successfully');
  }

  // Set up global error handling
  // ignore: no-empty-block
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
    logger?.info('Initializing AI service...');
    await getIt<IAIService>().init();
    logger?.success('AI service initialized');

    logger?.info('Initializing database...');
    await getIt<IWalletDatabase>().database;
    logger?.success('Database initialized');

    logger?.info('Initializing widget service...');
    await getIt<IWidgetService>().initialize();
    logger?.success('Widget service initialized');

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
      logCriticalError(e, stackTrace);

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
