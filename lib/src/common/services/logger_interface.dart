import 'package:talker_flutter/talker_flutter.dart';

/// Abstract logger interface for dependency injection
abstract class ILogger {
  /// Get the underlying Talker instance
  Talker get talker;

  /// Log an informational message
  void info(String message);

  /// Log a debug message
  void debug(String message);

  /// Log a warning message
  void warning(String message);

  /// Log an error with optional exception and stack trace
  void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Log a critical error
  void critical(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]);

  /// Log a success message
  void success(String message);

  /// Log an HTTP request
  ///
  /// By default, all query parameters are stripped for security.
  /// Use [allowedQueryParams] to explicitly preserve specific safe parameters.
  void logHttpRequest(
    String method,
    String url, {
    Set<String>? allowedQueryParams,
  });

  /// Log an HTTP response
  ///
  /// By default, all query parameters are stripped for security.
  /// Use [allowedQueryParams] to explicitly preserve specific safe parameters.
  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    Set<String>? allowedQueryParams,
  });

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
  void logDatabase(String operation, String details);

  /// Log navigation events
  void logNavigation(String route);

  /// Log service operations
  void logService(String service, String operation);

  /// Log ticket parsing operations
  void logTicketParsing(String type, String details);
}
