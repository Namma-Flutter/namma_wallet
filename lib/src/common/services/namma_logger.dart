import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger service using Talker for comprehensive logging throughout the app
class NammaLogger implements ILogger {
  NammaLogger() {
    _talker = Talker(
      settings: TalkerSettings(),
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(),
      ),
    );

    _talker.info('Logger initialized successfully');
  }

  late final Talker _talker;

  /// Get the Talker instance
  @override
  Talker get talker => _talker;

  /// Log an informational message
  @override
  void info(String message) {
    _talker.info(message);
  }

  /// Log a debug message
  @override
  void debug(String message) {
    _talker.debug(message);
  }

  /// Log a warning message
  @override
  void warning(String message) {
    _talker.warning(message);
  }

  /// Log an error with optional exception and stack trace
  @override
  void error(String message, [Exception? exception, StackTrace? stackTrace]) {
    _talker.error(message, exception, stackTrace);
  }

  /// Log a critical error
  @override
  void critical(
    String message, [
    Exception? exception,
    StackTrace? stackTrace,
  ]) {
    _talker.critical(message, exception, stackTrace);
  }

  /// Log a success message
  @override
  void success(String message) {
    _talker.info(message);
  }

  /// Log an HTTP request
  @override
  void logHttpRequest(String method, String url) {
    _talker.log('[HTTP] $method $url');
  }

  /// Log an HTTP response
  @override
  void logHttpResponse(String method, String url, int statusCode) {
    _talker.log('[HTTP] $method $url - Status: $statusCode');
  }

  /// Log database operations
  @override
  void logDatabase(String operation, String details) {
    _talker.log('[DB] $operation: $details');
  }

  /// Log navigation events
  @override
  void logNavigation(String route) {
    _talker.log('[NAV] Navigating to: $route');
  }

  /// Log service operations
  @override
  void logService(String service, String operation) {
    _talker.log('[$service] $operation');
  }

  /// Log ticket parsing operations
  @override
  void logTicketParsing(String type, String details) {
    _talker.log('[TICKET] $type: $details');
  }
}
