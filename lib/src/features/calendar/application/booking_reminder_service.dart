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
        if (decoded is Map<String, dynamic>) {
          final reminder = BookingReminder.fromMap(decoded);
          if (reminder != null) {
            reminders.add(reminder);
          }
        }
      } on Object {
        // Ignore malformed stored entries while preserving valid reminders.
      }
    }
    reminders.sort((a, b) => a.remindAt.compareTo(b.remindAt));
    return reminders;
  }

  Future<void> _persist(List<BookingReminder> reminders) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setStringList(
      _storageKey,
      reminders.map((item) => jsonEncode(item.toMap())).toList(),
    );
    if (!saved) {
      throw StateError('Failed to persist booking reminders.');
    }
  }

  @override
  Future<void> saveReminder(BookingReminder reminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((item) => item.id == reminder.id);
    final notificationId = _resolveNotificationId(
      reminder: reminder,
      existingReminder: index >= 0 ? reminders[index] : null,
      reminders: reminders,
    );
    final storedReminder = reminder.withNotificationId(notificationId);
    final previousNotificationId = index >= 0
        ? reminders[index].notificationId
        : null;
    if (index >= 0) {
      reminders[index] = storedReminder;
    } else {
      reminders.add(storedReminder);
    }
    await _persist(reminders);
    if (previousNotificationId != null) {
      await _notificationService.cancelTicketReminder(previousNotificationId);
    }
    await _notificationService.scheduleTicketReminder(
      id: storedReminder.notificationId!,
      dateTime: storedReminder.remindAt,
      title: storedReminder.title,
      body: storedReminder.description,
      payload: 'booking-reminder:${storedReminder.id}',
    );
  }

  @override
  Future<void> deleteReminder(BookingReminder reminder) async {
    final reminders = await getReminders();
    final index = reminders.indexWhere((item) => item.id == reminder.id);
    final storedReminder = index >= 0 ? reminders[index] : null;
    reminders.removeWhere((item) => item.id == reminder.id);
    await _persist(reminders);
    if (storedReminder?.notificationId case final notificationId?) {
      await _notificationService.cancelTicketReminder(notificationId);
    }
  }

  int _resolveNotificationId({
    required BookingReminder reminder,
    required BookingReminder? existingReminder,
    required List<BookingReminder> reminders,
  }) {
    if (existingReminder?.notificationId case final existingId?) {
      return existingId;
    }
    final requestedId = reminder.notificationId;
    final isUnused = !reminders.any(
      (stored) => stored.notificationId == requestedId,
    );
    if (requestedId != null && isUnused) return requestedId;
    return _nextNotificationId(reminders);
  }

  /// Booking reminders use a reserved negative range, while ticket reminders
  /// use non-negative IDs. The value is persisted with the reminder.
  int _nextNotificationId(List<BookingReminder> reminders) {
    final usedIds = reminders
        .map((reminder) => reminder.notificationId)
        .whereType<int>()
        .toSet();
    for (var candidate = -1; candidate > -1000000000; candidate--) {
      if (!usedIds.contains(candidate)) return candidate;
    }
    throw StateError('No notification IDs remain for booking reminders.');
  }
}
