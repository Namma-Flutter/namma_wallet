import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger service using Talker for comprehensive logging throughout the app
class NammaLogger implements ILogger {
  NammaLogger() {
    _talker = Talker(
      settings: _getTalkerSettings(),
      logger: TalkerLogger(
        settings: _getTalkerLoggerSettings(),
      ),
    );

    final mode = kDebugMode ? 'DEBUG' : 'PRODUCTION';
    _talker.info('Logger initialized successfully in $mode mode');
  }

  late Talker _talker;

  /// Get environment-specific Talker settings
  TalkerSettings _getTalkerSettings() {
    if (kDebugMode) {
      // Debug mode: Enable all features for comprehensive logging
      return TalkerSettings(
        maxHistoryItems: 1000,
      );
    } else {
      // Production mode: Reduce history size
      return TalkerSettings(
        maxHistoryItems: 100, // Reduced history for production
      );
    }
  }

  /// Get environment-specific Talker logger settings
  TalkerLoggerSettings _getTalkerLoggerSettings() {
    if (kDebugMode) {
      // Debug mode: Verbose logging with all details
      return TalkerLoggerSettings(
        maxLineWidth: 120,
      );
    } else {
      // Production mode: Only log info and above
      // (filters out verbose and debug logs)
      return TalkerLoggerSettings(
        level: LogLevel.info, // Filter out verbose and debug logs
        enableColors: false, // Disable colors in production
      );
    }
  }

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
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  /// Log a critical error
  @override
  void critical(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _talker.critical(message, error, stackTrace);
  }

  /// Log a success message
  @override
  void success(String message) {
    _talker.info(message);
  }

  /// Log an HTTP request
  @override
  void logHttpRequest(String method, String url) {
    final sanitizedUrl = _sanitizeUrl(url);
    _talker.log('[HTTP] $method $sanitizedUrl');
  }

  /// Log an HTTP response
  @override
  void logHttpResponse(String method, String url, int statusCode) {
    final sanitizedUrl = _sanitizeUrl(url);
    _talker.log('[HTTP] $method $sanitizedUrl - Status: $statusCode');
  }

  /// Sanitize URL to remove sensitive information from query parameters
  ///
  /// Removes sensitive query parameters to prevent leaking data like
  /// tokens, API keys, session IDs, etc.
  /// Returns a safe placeholder if URL parsing fails.
  String _sanitizeUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // List of sensitive query parameter keys to redact
      const sensitiveKeys = {
        'token',
        'api_key',
        'apikey',
        'key',
        'secret',
        'password',
        'session',
        'session_id',
        'sessionid',
        'auth',
        'authorization',
        'access_token',
        'refresh_token',
      };

      // If there are no query parameters, return the URL as-is
      if (uri.queryParameters.isEmpty) {
        return url;
      }

      // Filter out sensitive query parameters
      final safeParams = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        if (!sensitiveKeys.contains(key.toLowerCase())) {
          safeParams[key] = value;
        }
      });

      // Rebuild the URI with only safe query parameters
      final sanitizedUri = uri.replace(
        queryParameters: safeParams.isEmpty ? null : safeParams,
      );

      return sanitizedUri.toString();
    } on Object catch (_) {
      // If URL parsing fails, return a safe placeholder
      return '[REDACTED_URL]';
    }
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
