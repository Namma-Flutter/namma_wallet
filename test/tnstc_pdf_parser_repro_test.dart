import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  group('TNSTCPDFParser Reproduction Tests', () {
    late TNSTCPDFParser parser;

    setUp(() {
      parser = TNSTCPDFParser();
    });

    test('should parse mixed-case fields correctly', () {
      // Simulate PDF text with mixed-case values (which currently fail)
      const pdfText = '''
Tamil Nadu State Transport Corporation Ltd.
E-Ticket/Reservation Voucher-H

Corporation: Setc
PNR Number: T73309927
Date of Journey: 19-11-2025
Route No: 307AB
Service Start Place: Kumbakonam
Service End Place: Chennai-Pt Dr. M.g.r. Bs
Service Start Time: 13:15
Passenger Start Place: Kumbakonam
Passenger End Place: Chennai-Pt Dr.m.g.r. Bs
Passenger Pickup Point: Kumbakonam
Passenger Pickup Time: 19-11-2025 11:36:07.495806
Platform Number: 
Class of Service: AC SLEEPER SEATER
Trip Code: 
OB Reference No: OB31475439
Number of Seats: 1
Bank Transaction No: 
Bus ID No: E-5494
Passenger Category: General Public
Passengers: 
ID Card Type: Government Issued Photo ID Card
ID Card Number: 736960775578
Total Fare: 0.0 Rs.
Boarding Point: null
''';

      final ticket = parser.parseTicket(pdfText);

      // These expectations are expected to FAIL with the current implementation
      expect(
        ticket.corporation,
        equals('Setc'),
        reason: 'Corporation should match mixed case',
      );
      expect(
        ticket.serviceStartPlace,
        equals('Kumbakonam'),
        reason: 'Service Start Place should match mixed case',
      );
      expect(
        ticket.serviceEndPlace,
        equals('Chennai-Pt Dr. M.g.r. Bs'),
        reason: 'Service End Place should match mixed case',
      );
      expect(
        ticket.passengerStartPlace,
        equals('Kumbakonam'),
        reason: 'Passenger Start Place should match mixed case',
      );
      expect(
        ticket.passengerCategory,
        equals('General Public'),
        reason: 'Passenger Category should match mixed case',
      );

      // These should pass regardless
      expect(ticket.pnrNumber, equals('T73309927'));
      expect(ticket.journeyDate?.year, equals(2025));
    });
  });
}
