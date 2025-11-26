import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Fake logger implementation for testing purposes
/// This logger does nothing, preventing console output during tests
class FakeLogger implements ILogger {
  // Create a minimal Talker instance that does nothing
  final Talker _talker = Talker(
    settings: TalkerSettings(
      enabled: false, // Disable all logging
    ),
  );

  final List<String> logs = [];
  final List<String> errorLogs = [];

  @override
  Talker get talker => _talker;

  @override
  void info(String message) {
    logs.add('INFO: $message');
  }

  @override
  void debug(String message) {
    logs.add('DEBUG: $message');
  }

  @override
  void warning(String message) {
    logs.add('WARNING: $message');
  }

  @override
  void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    errorLogs.add(message);
    logs.add('ERROR: $message');
  }

  @override
  void critical(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    // Do nothing in tests
  }

  @override
  void success(String message) {
    // Do nothing in tests
  }

  @override
  void logHttpRequest(
    String method,
    String url, {
    Set<String>? allowedQueryParams,
  }) {
    // Do nothing in tests
  }

  @override
  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    Set<String>? allowedQueryParams,
  }) {
    // Do nothing in tests
  }

  @override
  void logDatabase(String operation, String details) {
    // Do nothing in tests
  }

  @override
  void logNavigation(String route) {
    // Do nothing in tests
  }

  @override
  void logService(String service, String operation) {
    // Do nothing in tests
  }

  @override
  void logTicketParsing(String type, String details) {
    // Do nothing in tests
  }
}
