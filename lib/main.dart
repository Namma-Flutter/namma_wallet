// import 'dart:convert';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/platform_utils/platform_utils.dart';
import 'package:namma_wallet/src/common/routing/app_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback_parser/application/ai_service_interface.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await HomeWidget.setAppGroupId('group.com.nammaflutter.nammawallet');
  } on Exception catch (e, stackTrace) {
    // Continue app startup if app group setup fails
    debugPrint('Failed to set HomeWidget app group id: $e\n$stackTrace');
  } on Object catch (e, stackTrace) {
    // Catch any other throwables
    debugPrint('Failed to set HomeWidget app group id: $e\n$stackTrace');
  }

  /// This is required by the new mediapipe requirement made by flutter gemma
  try {
    await FlutterGemma.initialize();
  } on Exception catch (e, stackTrace) {
    // Log initialization error - AI features may be unavailable
    // Continue app startup to allow non-AI features to work
    debugPrint('FlutterGemma initialization failed: $e\n$stackTrace');
  } on Object catch (e, stackTrace) {
    // Catch any other throwables
    debugPrint('FlutterGemma initialization failed: $e\n$stackTrace');
  }

  /// Initialize notification service
  /// Store notification payload for later processing after app is initialized

  await NotificationService().initialize(
    onSelectNotification: (payload) async {
      if (payload == null || payload.isEmpty) return;
      try {
        final data = jsonDecode(payload) as String;
        final ticket = TicketMapper.fromJson(data);
        if (rootNavigatorKey.currentContext != null) {
          rootNavigatorKey.currentContext?.goNamed(
            AppRoute.ticketView.name,
            extra: ticket,
          );
        }
      } on Exception catch (e, stackTrace) {
        // Log error during notification handling
        debugPrint('Error handling notification payload: $e\n$stackTrace');
      }
    },
  );

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
    logger?.info('Initializing database...');
    await getIt<IWalletDatabase>().database;
    logger?.success('Database initialized');

    logger?.info('Initializing Haptic service...');
    await getIt<IHapticService>().loadPreference();
    logger?.success('Haptic service initialized');

    logger?.info('Initializing AI service...');
    await getIt<IAIService>().init();
    logger?.success('AI service initialized');

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

  FlutterNativeSplash.remove();

  // Restore system UI (status bar & navigation bar) after splash
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Optional: set colors for status & navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider.value(
      value: getIt<ThemeProvider>(),
      child: const NammaWalletApp(),
    ),
  );
}
