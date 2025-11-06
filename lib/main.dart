import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/app.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/services/logger_service.dart';
import 'package:namma_wallet/src/common/theme/theme_provider.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/gemma_service.dart';
import 'package:provider/provider.dart';
import 'package:namma_wallet/src/common/di/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  setupLocator();

  // Initialize logger first
  final logger = getIt<LoggerService>();
  logger.initialize();
  logger.info('🚀 Namma Wallet starting...');

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.error(
      'Flutter Error: ${details.exceptionAsString()}',
      details.exception is Exception ? details.exception as Exception : null,
      details.stack,
    );
  };

  // Catch errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error(
      'Platform Error: $error',
      error is Exception ? error : null,
      stack,
    );
    return true;
  };

  try {
    logger.info('Initializing Gemma Chat Service...');
    await getIt<GemmaChatService>().init();
    logger.success('Gemma Chat Service initialized');

    logger.info('Initializing database...');
    await getIt<WalletDatabase>().database;
    logger.success('Database initialized');

    logger.success('All services initialized successfully');
  } on Object catch (e, stackTrace) {
    logger.error('Error during initialization: $e',
      e is Exception ? e : null, stackTrace);
  }

  runApp(
    ChangeNotifierProvider.value(
      value: getIt<ThemeProvider>(),
      child: const NammaWalletApp(),
    ),
  );
}
