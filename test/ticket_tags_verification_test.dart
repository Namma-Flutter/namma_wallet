import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  test('Verify ticket tags show correct values (not icon names)', () {
    const rawText = '''
Corporation: SETC
Date of Journey: 18/01/2026
Service Start Time: 13:15 Hrs.
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
PNR Number: T73309927
Route No: 307AB
Service Start Place: KUMBAKONAM
Service End Place: CHENNAI
Passenger Pickup Point: KUMBAKONAM
Trip Code: 1315KUMCHEAB
Passenger Information
HarishAnbalagan
Age
26
Adult/Child
Adult
Gender
M
Seat No.
4UB
Total Fare: 735.00 Rs.
''';

    final parser = TNSTCPDFParser();
    final tnstcTicket = parser.parseTicket(rawText);
    final ticket = Ticket.fromTNSTC(tnstcTicket);

    expect(ticket.tags, isNotNull);
    expect(ticket.tags, isNotEmpty, reason: 'Ticket should have tags');

    for (var i = 0; i < ticket.tags!.length; i++) {
      final tag = ticket.tags![i];

      // Verify that value is NOT the icon name
      expect(
        tag.value,
        isNot(equals(tag.icon)),
        reason: 'Tag value should not be the icon name',
      );

      // Verify value is not empty
      expect(
        tag.value,
        isNotEmpty,
        reason: 'Tag value should not be empty',
      );
    }

    // Verify specific expected tags
    final tripCodeTag = ticket.tags!.firstWhere(
      (tag) => tag.icon == 'confirmation_number',
    );
    expect(
      tripCodeTag.value,
      '1315KUMCHEAB',
      reason: 'Trip code tag should show the trip code value',
    );

    final pnrTag = ticket.tags!.firstWhere(
      (tag) => tag.icon == 'qr_code',
    );
    expect(
      pnrTag.value,
      'T73309927',
      reason: 'PNR tag should show the PNR number',
    );

    final timeTag = ticket.tags!.firstWhere(
      (tag) => tag.icon == 'access_time',
    );
    expect(
      timeTag.value,
      '13:15',
      reason: 'Time tag should show the service start time',
    );

    final fareTag = ticket.tags!.firstWhere(
      (tag) => tag.icon == 'attach_money',
    );
    expect(
      fareTag.value,
      '₹735.00',
      reason: 'Fare tag should show the fare amount',
    );
  });
}
