import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/calendar/application/booking_reminder.dart';

void main() {
  group('BookingReminderSchedule', () {
    test('normal booking opens 60 days before the journey', () {
      final journey = DateTime(2026, 9, 15, 8);

      expect(
        BookingReminderSchedule.normalBookingOpens(journey),
        DateTime(2026, 7, 17, 8),
      );
    });

    test('Tatkal opens one day before origin-station departure', () {
      final originDeparture = DateTime(2026, 9, 15, 18, 30);

      expect(
        BookingReminderSchedule.tatkalBookingOpens(originDeparture),
        DateTime(2026, 9, 14, 18, 30),
      );
    });
  });
}
