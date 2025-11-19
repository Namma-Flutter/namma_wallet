import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  test(
    'TNSTCPDFParser should parse all fields from user provided raw text',
    () {
      // Raw text reconstructed from the user's logs
      const rawText = '''
Corporation: SETC
Tamil Nadu State Transport Corporation Ltd.
(A GOVERNMENT OF TAMILNADU UNDERTAKING)
Date of Journey: 18/01/2026
Service Start Place: KUMBAKONAM
Name
Service Start Time: 13:15 Hrs.
Passenger Start Place: KUMBAKONAM
Passenger Pickup Point: KUMBAKONAM
Platform Number:
Trip Code: 1315KUMCHEAB
No. of Seats: 1 (Adults=1 Children=0)
Bus ID No. : E-5494
Passenger Information
HarishAnbalagan
E-Ticket/Reservation Voucher-H
ID Card Type rD Card
Important
Government Issued Photo
Total Fare: 735.00 Rs.
transferable.
Age
26
PNR Number: T73309927
Route No: 307AB
Service End Place: CHENNAI-PT DR. M.G.R. BS
circumstances.
Passenger End Place: CHENNAI-PT Dr.M.G.R. BS
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
Class of Service: AC SLEEPER SEATER
OB Reference No. : OB31475439
Bank Txn. No; : BAX6K8N12PUH74
Passenger category: GENERAL PUBLIc
Adult/Child
Adult
Gender
M
• The seat(s) booked under this ticket is/are not
ID Card Number: 736960775578
• This e-ticket is valid only for the seat num
''';

      final parser = TNSTCPDFParser();
      final ticket = parser.parseTicket(rawText);

      // Check fields that were reported as missing or incorrect
      expect(
        ticket.bankTransactionNumber,
        'BAX6K8N12PUH74',
        reason: 'Bank Transaction No should be parsed',
      );
      expect(
        ticket.passengers,
        isNotEmpty,
        reason: 'Passengers list should not be empty',
      );
      if (ticket.passengers.isNotEmpty) {
        expect(ticket.passengers.first.name, 'HarishAnbalagan');
        expect(ticket.passengers.first.age, 26);
        expect(ticket.passengers.first.gender, 'M');
        expect(
          ticket.passengers.first.type,
          'Adult',
          reason: 'Passenger type should be parsed from Adult/Child field',
        );
      }
      // The ID Card Type in raw text is messy: "ID Card Type rD Card"
      //  ... "Government Issued Photo"
      // We might expect "Government Issued Photo" or at least something
      //  non-empty.
      expect(
        ticket.idCardType,
        isNotNull,
        reason: 'ID Card Type should be parsed',
      );
      expect(
        ticket.boardingPoint,
        'KUMBAKONAM',
        reason: 'Boarding point should default to passenger pickup point',
      );
    },
  );
}
