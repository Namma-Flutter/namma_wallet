import 'package:flutter/foundation.dart';

/// The booking window a calendar reminder is for.
enum BookingWindow { normal, tatkal }

/// A user-created reminder to make a travel booking.
@immutable
class BookingReminder {
  const BookingReminder({
    required this.id,
    required this.provider,
    required this.window,
    required this.journeyDeparture,
    required this.remindAt,
  });

  final String id;
  final String provider;
  final BookingWindow window;
  final DateTime journeyDeparture;
  final DateTime remindAt;

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
  };

  factory BookingReminder.fromMap(Map<String, Object?> map) {
    final windowName = map['window'] as String?;
    final journeyMillis = map['journeyDeparture'] as int?;
    final reminderMillis = map['remindAt'] as int?;
    if (windowName == null || journeyMillis == null || reminderMillis == null) {
      throw const FormatException('Incomplete booking reminder');
    }
    return BookingReminder(
      id: map['id'] as String? ?? '',
      provider: map['provider'] as String? ?? '',
      window: BookingWindow.values.byName(windowName),
      journeyDeparture: DateTime.fromMillisecondsSinceEpoch(journeyMillis),
      remindAt: DateTime.fromMillisecondsSinceEpoch(reminderMillis),
    );
  }
}

/// Calculates booking-window opening times from the journey departure.
abstract final class BookingReminderSchedule {
  static DateTime normalBookingOpens(DateTime journeyDeparture) =>
      journeyDeparture.subtract(const Duration(days: 60));

  static DateTime tatkalBookingOpens(DateTime originDeparture) =>
      originDeparture.subtract(const Duration(days: 1));
}
