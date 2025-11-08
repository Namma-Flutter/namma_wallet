import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger service using Talker for comprehensive logging throughout the app
class NammaLogger implements ILogger {
  NammaLogger()
    : _talker = Talker(
        settings: _getTalkerSettings(),
        logger: TalkerLogger(
          settings: _getTalkerLoggerSettings(),
        ),
      ) {
    const mode = kDebugMode ? 'DEBUG' : 'PRODUCTION';
    _talker.info('Logger initialized successfully in $mode mode');
  }

  final Talker _talker;

  /// Get environment-specific Talker settings
  static TalkerSettings _getTalkerSettings() {
    if (kDebugMode) {
      // Debug mode: Enable all features for comprehensive logging
      return TalkerSettings();
    } else {
      // Production mode: Reduce history size
      return TalkerSettings(
        maxHistoryItems: 100, // Reduced history for production
      );
    }
  }

  /// Get environment-specific Talker logger settings
  static TalkerLoggerSettings _getTalkerLoggerSettings() {
    if (kDebugMode) {
      // Debug mode: Verbose logging with all details
      return TalkerLoggerSettings(
        maxLineWidth: 120,
      );
    } else {
      // Production mode: Disable all logging by setting level to none
      return TalkerLoggerSettings(
        enable: false, // Disable all logging in production
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
  ///
  /// By default, all query parameters are stripped for security.
  /// Use [allowedQueryParams] to explicitly preserve specific safe parameters.
  @override
  void logHttpRequest(
    String method,
    String url, {
    Set<String>? allowedQueryParams,
  }) {
    final sanitizedUrl = _sanitizeUrl(url, allowedQueryParams);
    _talker.debug('[HTTP] $method $sanitizedUrl');
  }

  /// Log an HTTP response
  ///
  /// By default, all query parameters are stripped for security.
  /// Use [allowedQueryParams] to explicitly preserve specific safe parameters.
  @override
  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    Set<String>? allowedQueryParams,
  }) {
    final sanitizedUrl = _sanitizeUrl(url, allowedQueryParams);
    _talker.debug('[HTTP] $method $sanitizedUrl - Status: $statusCode');
  }

  /// Sanitize URL to remove query parameters
  ///
  /// **Default behavior (secure by default):**
  /// Strips ALL query parameters to prevent leaking PII, tokens, or any
  /// sensitive data in logs. This is the safest approach as it prevents
  /// accidentally logging new or unlisted sensitive parameters.
  ///
  /// **Opt-in preservation:**
  /// Callers must explicitly provide [allowedQueryParams] to preserve
  /// specific query parameters. Only parameters in this allowlist will be
  /// included in the sanitized URL.
  ///
  /// **Examples:**
  /// ```dart
  /// // Default: strips all query params
  /// _sanitizeUrl('https://api.com/data?token=abc&id=123')
  /// // Returns: 'https://api.com/data'
  ///
  /// // With allowlist: preserves only specified params
  /// _sanitizeUrl(
  ///   'https://api.com/data?token=abc&id=123&page=1',
  ///   {'id', 'page'},
  /// )
  /// // Returns: 'https://api.com/data?id=123&page=1'
  /// ```
  ///
  /// Returns `[REDACTED_URL]` if URL parsing fails.
  String _sanitizeUrl(String url, [Set<String>? allowedQueryParams]) {
    try {
      final uri = Uri.parse(url);

      // If there are no query parameters, return the URL as-is
      if (uri.queryParameters.isEmpty) {
        return url;
      }

      // Default behavior: strip ALL query parameters (secure by default)
      if (allowedQueryParams == null || allowedQueryParams.isEmpty) {
        // Remove query to get clean base URL
        return uri.replace(query: '').toString();
      }

      // Opt-in: only preserve explicitly allowed query parameters
      final preservedParams = <String, String>{};
      uri.queryParameters.forEach((key, value) {
        if (allowedQueryParams.contains(key)) {
          preservedParams[key] = value;
        }
      });

      // Rebuild the URI with only allowed query parameters
      // If no params were preserved, strip query entirely
      if (preservedParams.isEmpty) {
        return uri.replace(query: '').toString();
      }

      return uri.replace(queryParameters: preservedParams).toString();
    } on Object catch (_) {
      // If URL parsing fails, return a safe placeholder
      return '[REDACTED_URL]';
    }
  }

  /// Log database operations
  ///
  /// **WARNING**: Do NOT pass PII, credentials, or sensitive query details.
  /// Only log operation types (e.g., "SELECT", "INSERT") and non-sensitive
  /// metadata (e.g., table names, row counts). Never log actual data values,
  /// WHERE clause conditions, or any user-identifying information.
  ///
  /// Examples:
  /// - Good: `logDatabase('INSERT', 'tickets')`
  /// - Good: `logDatabase('SELECT', '5 rows from tickets')`
  /// - Bad: `logDatabase('SELECT', 'WHERE user_id=123')`
  /// - Bad: `logDatabase('INSERT', 'values: $userData')`
  @override
  void logDatabase(String operation, String details) {
    _talker.debug('[DB] $operation: $details');
  }

  /// Log navigation events
  @override
  void logNavigation(String route) {
    _talker.debug('[NAV] Navigating to: $route');
  }

  /// Log service operations
  @override
  void logService(String service, String operation) {
    _talker.debug('[$service] $operation');
  }

  /// Log ticket parsing operations
  @override
  void logTicketParsing(String type, String details) {
    _talker.debug('[TICKET] $type: $details');
  }
}
