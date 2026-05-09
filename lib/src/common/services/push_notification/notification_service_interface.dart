import 'package:namma_wallet/src/common/domain/models/ticket.dart';

/// Interface for managing push notifications, including scheduling
/// and displaying notifications.
abstract class INotificationService {
  /// Initializes the notification service.
  Future<void> initialize();

  /// If the app was launched from a terminated state by tapping a
  /// notification, navigate to the appropriate page once the UI is ready.
  Future<void> handleInitialNotification();

  /// Schedules a ticket reminder notification.
  Future<void> scheduleTicketReminder({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
  });

  /// Cancels a scheduled ticket reminder by ID.
  Future<void> cancelTicketReminder(int id);

  /// Schedules multiple reminders for a ticket at predefined intervals.
  Future<void> scheduleTicketReminderFor(Ticket ticket);

  /// Shows a ticket notification immediately.
  /// Used for testing or immediate alerts.
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  });

  /// Cancels all scheduled reminders for a ticket and deletes stored
  /// reminder preferences.
  Future<void> cancelAllRemindersForTicket(Ticket ticket);
}
