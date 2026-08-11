import 'dart:convert';

import 'package:namma_wallet/src/common/services/push_notification/notification_service_interface.dart';
import 'package:namma_wallet/src/features/calendar/application/booking_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IBookingReminderService {
  Future<List<BookingReminder>> getReminders();
  Future<void> saveReminder(BookingReminder reminder);
  Future<void> deleteReminder(BookingReminder reminder);
}

class BookingReminderService implements IBookingReminderService {
  BookingReminderService({required INotificationService notificationService})
    : _notificationService = notificationService;

  static const _storageKey = 'calendar_booking_reminders';
  final INotificationService _notificationService;

  @override
  Future<List<BookingReminder>> getReminders() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? [];
    final reminders = <BookingReminder>[];
    for (final item in stored) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>)
          reminders.add(BookingReminder.fromMap(decoded));
      } on FormatException {
        // Ignore malformed stored entries while preserving valid reminders.
      }
    }
    reminders.sort((a, b) => a.remindAt.compareTo(b.remindAt));
    return reminders;
  }

  @override
  Future<void> saveReminder(BookingReminder reminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((item) => item.id == reminder.id);
    if (index >= 0) {
      await _notificationService.cancelTicketReminder(
        _notificationId(reminders[index]),
      );
      reminders[index] = reminder;
    } else {
      reminders.add(reminder);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      reminders.map((item) => jsonEncode(item.toMap())).toList(),
    );
    await _notificationService.scheduleTicketReminder(
      id: _notificationId(reminder),
      dateTime: reminder.remindAt,
      title: reminder.title,
      body: reminder.description,
      payload: 'booking-reminder:${reminder.id}',
    );
  }

  @override
  Future<void> deleteReminder(BookingReminder reminder) async {
    final reminders = await getReminders();
    reminders.removeWhere((item) => item.id == reminder.id);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      reminders.map((item) => jsonEncode(item.toMap())).toList(),
    );
    await _notificationService.cancelTicketReminder(_notificationId(reminder));
  }

  int _notificationId(BookingReminder reminder) =>
      1000000000 + (reminder.id.hashCode.abs() % 1000000000);
}
