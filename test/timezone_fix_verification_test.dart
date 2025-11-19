import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  test(
    '''Verify timezone fix - DateTime should display correctly after serialization''',
    () {
      // Parse the ticket
      const rawText = '''
Corporation: SETC
Date of Journey: 18/01/2026
Service Start Time: 13:15 Hrs.
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
PNR Number: T73309927
Service Start Place: KUMBAKONAM
Service End Place: CHENNAI
Passenger Pickup Point: KUMBAKONAM
Passenger Information
HarishAnbalagan
Age
26
Adult/Child
Adult
Gender
M
Total Fare: 735.00 Rs.
''';

      final parser = TNSTCPDFParser();
      final tnstcTicket = parser.parseTicket(rawText);
      final ticket = Ticket.fromTNSTC(tnstcTicket);

      // This should be 01:15 pm

      // Simulate database round-trip (serialize to map, then deserialize)
      final map = ticket.toMap();

      final deserializedTicket = TicketMapper.fromMap(map);
      // This will be 7 (UTC)

      // Now test the display functions
      final displayedTime = getDate(deserializedTicket.startTime);
      final displayedDate = getTime(deserializedTicket.startTime);

      // Should be 01:15 pm
      // Should be 18/01/2026

      // Verify the fix works
      expect(
        displayedTime,
        '01:15 pm',
        reason:
            'Time should display as 01:15 pm '
            '(13:15 in 24h) even though stored as UTC',
      );

      expect(
        displayedDate,
        '18/01/2026',
        reason: 'Date should display correctly',
      );

      // Also verify the extras pickup time formatting
      final pickupTimeExtra = deserializedTicket.extras?.firstWhere(
        (e) => e.title == 'Pickup Time',
      );

      if (pickupTimeExtra != null) {
        expect(
          pickupTimeExtra.value,
          contains('01:15 PM'),
          reason: 'Pickup time in extras should show 01:15 PM',
        );
      }
    },
  );
}
