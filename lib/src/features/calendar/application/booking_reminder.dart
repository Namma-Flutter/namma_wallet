import 'package:flutter/foundation.dart';

/// The booking window a calendar reminder is for.
enum BookingWindow { normal, tatkal }

/// IRCTC Tatkal booking class, which determines when booking opens.
enum TatkalClass { ac, nonAc }

/// A user-created reminder to make a travel booking.
@immutable
class BookingReminder {
  const BookingReminder({
    required this.id,
    required this.provider,
    required this.window,
    required this.journeyDeparture,
    required this.remindAt,
    this.notificationId,
  });

  final String id;
  final String provider;
  final BookingWindow window;
  final DateTime journeyDeparture;
  final DateTime remindAt;
  final int? notificationId;

  String get title => window == BookingWindow.tatkal
      ? 'Book IRCTC Tatkal ticket'
      : 'Book $provider ticket';

  String get description => window == BookingWindow.tatkal
      ? 'Tatkal opens one day before departure from the originating station.'
      : '$provider normal booking opens 60 days before travel.';

  Map<String, Object> toMap() => {
    'id': id,
    'provider': provider,
    'window': window.name,
    'journeyDeparture': journeyDeparture.millisecondsSinceEpoch,
    'remindAt': remindAt.millisecondsSinceEpoch,
    'notificationId': ?notificationId,
  };

  factory BookingReminder.fromMap(Map<String, Object?> map) {
    final id = map['id'] as String?;
    final provider = map['provider'] as String?;
    final windowName = map['window'] as String?;
    final journeyMillis = map['journeyDeparture'] as int?;
    final reminderMillis = map['remindAt'] as int?;
    if (id == null ||
        id.isEmpty ||
        provider == null ||
        windowName == null ||
        journeyMillis == null ||
        reminderMillis == null) {
      throw const FormatException('Incomplete booking reminder');
    }
    final window = BookingWindow.values
        .where((value) => value.name == windowName)
        .firstOrNull;
    if (window == null) {
      throw FormatException('Unknown booking window: $windowName');
    }
    return BookingReminder(
      id: id,
      provider: provider,
      window: window,
      journeyDeparture: DateTime.fromMillisecondsSinceEpoch(journeyMillis),
      remindAt: DateTime.fromMillisecondsSinceEpoch(reminderMillis),
      notificationId: map['notificationId'] as int?,
    );
  }

  BookingReminder withNotificationId(int value) => BookingReminder(
    id: id,
    provider: provider,
    window: window,
    journeyDeparture: journeyDeparture,
    remindAt: remindAt,
    notificationId: value,
  );
}

/// Calculates booking-window opening times from the journey departure.
abstract final class BookingReminderSchedule {
  static DateTime normalBookingOpens(DateTime journeyDeparture) =>
      journeyDeparture.subtract(const Duration(days: 60));

  static DateTime tatkalBookingOpens(
    DateTime originDeparture,
    TatkalClass tatkalClass,
  ) {
    final dayBefore = originDeparture.subtract(const Duration(days: 1));
    final openingHour = tatkalClass == TatkalClass.ac ? 10 : 11;
    return DateTime(
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      openingHour,
    );
  }
}
