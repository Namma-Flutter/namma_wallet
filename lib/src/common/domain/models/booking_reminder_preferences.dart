import 'package:dart_mappable/dart_mappable.dart';

part 'booking_reminder_preferences.mapper.dart';

@MappableClass()
class BookingReminderPreferences with BookingReminderPreferencesMappable {
  const BookingReminderPreferences({
    required this.ticketId,
    this.bookingOpenDateMillis,
    this.isTatkal = false,
    this.enabled = true,
  });

  final String ticketId;
  final int? bookingOpenDateMillis;
  final bool isTatkal;
  final bool enabled;

  DateTime? get bookingOpenDate => bookingOpenDateMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(bookingOpenDateMillis!)
      : null;
}
