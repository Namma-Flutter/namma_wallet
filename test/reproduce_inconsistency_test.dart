import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

void main() {
  test(
    'Verify consistent time formatting between Departure Time and Pickup Time',
    () {
      final model = TNSTCTicketModel(
        journeyDate: DateTime(2026, 1, 18),
        serviceStartTime: '13:15',
        passengerPickupTime: DateTime(2026, 1, 18, 13, 15),
        pnrNumber: 'T123456',
        corporation: 'SETC',
        routeNo: '123',
      );

      final ticket = Ticket.fromTNSTC(model);

      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure Time',
      );
      final pickupExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Pickup Time',
      );

      expect(departureExtra, isNotNull);
      expect(pickupExtra, isNotNull);

      // Both should now use 12-hour format with AM/PM
      // Departure Time: "01:15 PM" (time only)
      // Pickup Time: "18-01-2026 01:15 PM" (full datetime)

      print('Departure Time: ${departureExtra!.value}');
      print('Pickup Time: ${pickupExtra!.value}');

      // Verify Departure Time is in 12h format with AM/PM
      expect(departureExtra.value, '01:15 PM');

      // Verify Pickup Time still has full datetime in 12h format
      expect(pickupExtra.value, contains('01:15 PM'));
      expect(pickupExtra.value, contains('18-01-2026'));
    },
  );
}
