import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

void main() {
  test('SMS parser should extract time when comma appears before time', () {
    // Actual SMS text from user's logs
    const smsText =
        '''TNSTC Corporation:SETC , PNR NO.:T73309927 , From:KUMBAKONAM To CHENNAI-PT DR. M.G.R. BS , Trip Code:1315KUMCHEAB , Journey Date:18/01/2026 , Time:,13:15 , Seat No.:4UB .Class:AC SLEEPER SEATER , Boarding at:KUMBAKONAM . For e-Ticket: Download from View Ticket. Please carry your photo ID during journey. T&C apply. https://www.radiantinfo.com''';

    final parser = TNSTCSMSParser();
    final ticket = parser.parseTicket(smsText);

    print('Parsed serviceStartTime: ${ticket.serviceStartTime}');
    print('Parsed journeyDate: ${ticket.journeyDate}');

    // Should extract the time correctly
    expect(
      ticket.serviceStartTime,
      '13:15',
      reason: 'Should parse time even with comma before it',
    );
    expect(ticket.corporation, 'SETC');
    expect(ticket.pnrNumber, 'T73309927');
    expect(ticket.tripCode, '1315KUMCHEAB');
  });
}
