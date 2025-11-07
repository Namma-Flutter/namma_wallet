import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    await getIt<WalletDatabase>().database;
    logger?.success('Database initialized');

    logger?.success('All services initialized successfully');
  } on Object catch (e, stackTrace) {
    logger?.error(
      'Error during initialization: $e',
      e,
      stackTrace,
    );
  }

  runApp(
    ChangeNotifierProvider.value(
      value: getIt<ThemeProvider>(),
      child: const NammaWalletApp(),
    ),
  );
}
