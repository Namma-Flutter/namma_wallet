import 'package:namma_wallet/src/common/domain/models/booking_reminder_preferences.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/booking_reminder/booking_reminder_preferences_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/push_notification/notification_service_interface.dart';

class BookingReminderService {
  BookingReminderService({
    required ILogger logger,
    required INotificationService notificationService,
    required IBookingReminderPreferencesService preferencesService,
  }) : _logger = logger,
       _notificationService = notificationService,
       _preferencesService = preferencesService;

  final ILogger _logger;
  final INotificationService _notificationService;
  final IBookingReminderPreferencesService _preferencesService;

  static const int _normalBookingOffsetDays = 60;
  static const int _tatkalBookingOffsetDays = 1;

  (DateTime normal, DateTime? tatkal)? computeBookingOpenDates(Ticket ticket) {
    final startTime = ticket.startTime;
    if (startTime == null) return null;

    switch (ticket.type) {
      case TicketType.bus:
        final normal = startTime.subtract(
          Duration(days: _normalBookingOffsetDays),
        );
        return (normal, null);
      case TicketType.train:
        final normal = startTime.subtract(
          Duration(days: _normalBookingOffsetDays),
        );
        final tatkal = startTime.subtract(
          Duration(days: _tatkalBookingOffsetDays),
        );
        return (normal, tatkal);
      case TicketType.event:
      case TicketType.flight:
      case TicketType.metro:
      case null:
        return null;
    }
  }

  int _notificationId(String ticketId, {bool isTatkal = false}) {
    final base = ticketId.hashCode.abs() % (1 << 30);
    return isTatkal ? base + 1 : base;
  }

  Future<void> scheduleBookingReminder(Ticket ticket) async {
    final dates = computeBookingOpenDates(ticket);
    if (dates == null) {
      _logger.warning(
        '[BookingReminderService] Cannot schedule: no booking-open dates for '
        '${ticket.ticketId}',
      );
      return;
    }

    final (normal, tatkal) = dates;
    final now = DateTime.now();

    final route = ticket.primaryText ?? 'your trip';
    final typeLabel = ticket.type == TicketType.bus ? 'bus' : 'train';

    if (!normal.isBefore(now)) {
      final normalNotify = DateTime(
        normal.year,
        normal.month,
        normal.day,
        8,
        0,
      );
      if (!normalNotify.isBefore(now)) {
        await _notificationService.scheduleTicketReminder(
          id: _notificationId(ticket.ticketId!),
          dateTime: normalNotify,
          title: 'Book $typeLabel ticket today',
          body: 'Booking opens for $route',
          payload: ticket.ticketId!,
        );
      }
    }

    if (tatkal != null && !tatkal.isBefore(now)) {
      final tatkalNotify = DateTime(
        tatkal.year,
        tatkal.month,
        tatkal.day,
        8,
        0,
      );
      if (!tatkalNotify.isBefore(now)) {
        await _notificationService.scheduleTicketReminder(
          id: _notificationId(ticket.ticketId!, isTatkal: true),
          dateTime: tatkalNotify,
          title: 'Tatkal booking opens today',
          body: 'Tatkal booking opens for $route',
          payload: ticket.ticketId!,
        );
      }
    }

    final prefs = BookingReminderPreferences(
      ticketId: ticket.ticketId!,
      bookingOpenDateMillis: normal.millisecondsSinceEpoch,
      isTatkal: false,
      enabled: true,
    );
    await _preferencesService.saveReminder(prefs);

    if (tatkal != null) {
      final tatkalPrefs = BookingReminderPreferences(
        ticketId: '${ticket.ticketId}_tatkal',
        bookingOpenDateMillis: tatkal.millisecondsSinceEpoch,
        isTatkal: true,
        enabled: true,
      );
      await _preferencesService.saveReminder(tatkalPrefs);
    }

    _logger.info(
      '[BookingReminderService] Scheduled booking reminder for '
      '${ticket.ticketId}',
    );
  }

  Future<void> cancelBookingReminder(String ticketId) async {
    await _notificationService.cancelTicketReminder(
      _notificationId(ticketId),
    );
    await _notificationService.cancelTicketReminder(
      _notificationId(ticketId, isTatkal: true),
    );
    await _preferencesService.deleteReminder(ticketId);
    await _preferencesService.deleteReminder('${ticketId}_tatkal');
  }

  Future<void> loadActiveReminders() async {
    final reminders = await _preferencesService.getAllReminders();
    _logger.info(
      '[BookingReminderService] Loaded ${reminders.length} active reminders',
    );
  }

  Future<void> rescheduleMissed() async {
    final reminders = await _preferencesService.getAllReminders();
    final now = DateTime.now();

    for (final reminder in reminders) {
      if (!reminder.enabled) continue;
      final date = reminder.bookingOpenDate;
      if (date == null || date.isBefore(now)) continue;

      final notifyTime = DateTime(date.year, date.month, date.day, 8, 0);
      if (notifyTime.isBefore(now)) continue;

      await _notificationService.scheduleTicketReminder(
        id: _notificationId(reminder.ticketId, isTatkal: reminder.isTatkal),
        dateTime: notifyTime,
        title: reminder.isTatkal
            ? 'Tatkal booking opens today'
            : 'Book ticket today',
        body: 'Booking window opens today',
        payload: reminder.ticketId,
      );
    }

    _logger.info(
      '[BookingReminderService] Rescheduled ${reminders.length} reminders',
    );
  }

  Future<bool> hasActiveReminder(String ticketId) async {
    final reminder = await _preferencesService.getReminder(ticketId);
    return reminder != null && reminder.enabled;
  }

  Future<bool> hasActiveTatkalReminder(String ticketId) async {
    final reminder = await _preferencesService.getReminder(
      '${ticketId}_tatkal',
    );
    return reminder != null && reminder.enabled;
  }
}
