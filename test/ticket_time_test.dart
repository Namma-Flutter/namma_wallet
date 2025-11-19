import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

void main() {
  test(
    '''Ticket.fromTNSTC should use passengerPickupTime for startTime and format it in extras''',
    () {
      final pickupTime = DateTime(2026, 1, 18, 13, 15);
      final model = TNSTCTicketModel(
        journeyDate: DateTime(2026, 1, 18),
        serviceStartTime: '12:00', // Different from pickup time
        passengerPickupTime: pickupTime,
        pnrNumber: 'T123456',
        corporation: 'SETC',
        routeNo: '123',
      );

      final ticket = Ticket.fromTNSTC(model);

      // 1. Verify startTime uses passengerPickupTime
      expect(
        ticket.startTime,
        pickupTime,
        reason: 'startTime should match passengerPickupTime',
      );

      // 2. Verify Pickup Time extra is formatted (not just toString())
      // Expected format: "dd-MM-yyyy hh:mm a" or similar human readable
      // For 13:15 -> 01:15 PM
      final pickupExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Pickup Time',
      );
      expect(pickupExtra, isNotNull);
      expect(
        pickupExtra!.value,
        isNot(contains('2026-01-18 13:15:00.000')),
        reason: 'Should not be raw toString()',
      );
      // We'll accept a few reasonable formats for now, e.g., containing "18"
      // and "01:15" or "13:15"
      expect(pickupExtra.value, contains('18'));
      expect(pickupExtra.value, anyOf(contains('13:15'), contains('01:15')));
    },
  );
}
