import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger service using Talker for comprehensive logging throughout the app
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() => _instance;

  LoggerService._internal();

  late final Talker _talker;

  /// Get the Talker instance
  Talker get talker => _talker;

  /// Initialize the logger with custom configuration
  void initialize() {
    _talker = Talker(
      settings: TalkerSettings(
        enabled: true,
        useConsoleLogs: kDebugMode,
        maxHistoryItems: 1000,
      ),
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(
          enableColors: true,
          level: kDebugMode ? LogLevel.verbose : LogLevel.info,
        ),
      ),
    );

    _talker.info('🚀 Logger initialized successfully');
  }

  /// Log an informational message
  void info(String message) {
    _talker.info(message);
  }

  /// Log a debug message
  void debug(String message) {
    _talker.debug(message);
  }

  /// Log a warning message
  void warning(String message) {
    _talker.warning(message);
  }

  /// Log an error with optional exception and stack trace
  void error(String message, [Exception? exception, StackTrace? stackTrace]) {
    _talker.error(message, exception, stackTrace);
  }

  /// Log a critical error
  void critical(String message, [Exception? exception, StackTrace? stackTrace]) {
    _talker.critical(message, exception, stackTrace);
  }

  /// Log a success message
  void success(String message) {
    _talker.good(message);
  }

  /// Log an HTTP request
  void logHttpRequest(String method, String url) {
    _talker.log('[HTTP] $method $url');
  }

  /// Log an HTTP response
  void logHttpResponse(String method, String url, int statusCode) {
    _talker.log('[HTTP] $method $url - Status: $statusCode');
  }

  /// Log database operations
  void logDatabase(String operation, String details) {
    _talker.log('[DB] $operation: $details');
  }

  /// Log navigation events
  void logNavigation(String route) {
    _talker.log('[NAV] Navigating to: $route');
  }

  /// Log service operations
  void logService(String service, String operation) {
    _talker.log('[$service] $operation');
  }

  /// Log ticket parsing operations
  void logTicketParsing(String type, String details) {
    _talker.log('[TICKET] $type: $details');
  }
}
