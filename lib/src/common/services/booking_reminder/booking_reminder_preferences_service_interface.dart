import 'package:namma_wallet/src/common/domain/models/booking_reminder_preferences.dart';

abstract interface class IBookingReminderPreferencesService {
  Future<List<BookingReminderPreferences>> getAllReminders();

  Future<BookingReminderPreferences?> getReminder(String ticketId);

  Future<void> saveReminder(BookingReminderPreferences preferences);

  Future<void> deleteReminder(String ticketId);
}
