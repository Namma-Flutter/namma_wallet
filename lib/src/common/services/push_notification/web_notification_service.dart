import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service_interface.dart';

/// Web implementation of INotificationService.
/// 
/// Provides a no-op implementation for all notification methods,
/// as web platform does not support native push notifications.
class WebNotificationService implements INotificationService {
  @override
  Future<void> initialize() async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> handleInitialNotification() async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> scheduleTicketReminder({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
    required String payload,
  }) async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> cancelTicketReminder(int id) async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> scheduleTicketReminderFor(Ticket ticket) async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    // No-op: Web platform doesn't support native notifications
  }

  @override
  Future<void> cancelAllRemindersForTicket(Ticket ticket) async {
    // No-op: Web platform doesn't support native notifications
  }
}
