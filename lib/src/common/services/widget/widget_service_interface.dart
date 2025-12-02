import 'package:namma_wallet/src/common/domain/models/ticket.dart';

/// Interface for managing home screen widgets
abstract interface class IWidgetService {
  /// Initialize the widget service (register callbacks, set app group)
  Future<void> initialize();

  /// Update the widget with the given ticket data
  Future<void> updateWidgetWithTicket(Ticket ticket);

  /// Check if the app was launched from a widget
  Future<Uri?> getInitialWidgetLaunchUri();

  /// Start periodic background widget updates
  Future<void> startBackgroundUpdates();

  /// Stop periodic background widget updates
  Future<void> stopBackgroundUpdates();

  /// Check if request pin widget is supported (Android)
  Future<bool> isRequestPinWidgetSupported();

  /// Request to pin widget to home screen (Android)
  Future<void> requestPinWidget();
}
