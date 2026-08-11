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

    test('Tatkal opens at 10:00 the day before for AC classes', () {
      final originDeparture = DateTime(2026, 9, 15, 18, 30);

      expect(
        BookingReminderSchedule.tatkalBookingOpens(
          originDeparture,
          TatkalClass.ac,
        ),
        DateTime(2026, 9, 14, 10),
      );
    });

    test('Tatkal opens at 11:00 the day before for non-AC classes', () {
      final originDeparture = DateTime(2026, 9, 15, 18, 30);

      expect(
        BookingReminderSchedule.tatkalBookingOpens(
          originDeparture,
          TatkalClass.nonAc,
        ),
        DateTime(2026, 9, 14, 11),
      );
    });
  });

  test('persists the notification ID with the reminder', () {
    final reminder = BookingReminder(
      id: 'IRCTC_normal_1789459200000',
      provider: 'IRCTC',
      window: BookingWindow.normal,
      journeyDeparture: DateTime(2026, 9, 15, 8),
      remindAt: DateTime(2026, 7, 17, 8),
      notificationId: -1,
    );

    expect(BookingReminder.fromMap(reminder.toMap())!.notificationId, -1);
  });

  test('fromMap returns null for invalid records', () {
    expect(
      BookingReminder.fromMap({'id': '', 'provider': 'TNSTC'}),
      isNull,
    );
    expect(
      BookingReminder.fromMap({'id': 'x', 'provider': ''}),
      isNull,
    );
    expect(
      BookingReminder.fromMap({
        'id': 'x',
        'provider': 'TNSTC',
        'window': 'bogus',
        'journeyDeparture': 0,
        'remindAt': 0,
      }),
      isNull,
    );
    expect(
      BookingReminder.fromMap({
        'id': 'x',
        'provider': 'TNSTC',
        'window': 'normal',
        'journeyDeparture': 'bad',
        'remindAt': 0,
      }),
      isNull,
    );
  });
}
