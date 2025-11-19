import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

void main() {
  test(
    'SMS-parsed ticket should have correct startTime from serviceStartTime',
    () {
      // Actual SMS text from user's logs
      const smsText =
          '''TNSTC Corporation:SETC , PNR NO.:T73309927 , From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , Trip Code:1315KUMCHEAB , Journey Date:18/01/2026 , Time:,13:15 , Seat No.:4UB .Class:AC SLEEPER SEATER , Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com''';

      final parser = TNSTCSMSParser();
      final model = parser.parseTicket(smsText);

      print('Model serviceStartTime: ${model.serviceStartTime}');
      print('Model journeyDate: ${model.journeyDate}');
      print('Model passengerPickupTime: ${model.passengerPickupTime}');

      final ticket = Ticket.fromTNSTC(model);

      print('Ticket startTime: ${ticket.startTime}');

      // Should combine journeyDate (2026-01-18) with serviceStartTime (13:15)
      expect(ticket.startTime.year, 2026);
      expect(ticket.startTime.month, 1);
      expect(ticket.startTime.day, 18);
      expect(
        ticket.startTime.hour,
        13,
        reason: 'Should use hour from serviceStartTime',
      );
      expect(
        ticket.startTime.minute,
        15,
        reason: 'Should use minute from serviceStartTime',
      );

      // Verify extras show formatted time
      final departureExtra = ticket.extras?.firstWhere(
        (e) => e.title == 'Departure Time',
        orElse: () => throw Exception('Departure Time extra not found'),
      );

      expect(departureExtra, isNotNull);
      print('Departure Time extra: ${departureExtra!.value}');
      expect(departureExtra.value, '01:15 PM');
    },
  );
}
