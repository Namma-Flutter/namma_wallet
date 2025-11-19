import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

void main() {
  group('Date Parsing Verification', () {
    late TNSTCPDFParser parser;

    setUp(() {
      parser = TNSTCPDFParser();
    });

    test(
      'should correctly parse journey date and pickup time from user PDF',
      () {
        // Actual raw text from user's logs
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

        final ticket = parser.parseTicket(rawText);

        // Verify journey date
        expect(
          ticket.journeyDate,
          isNotNull,
          reason: 'Journey date should not be null',
        );
        expect(ticket.journeyDate!.year, 2026, reason: 'Year should be 2026');
        expect(
          ticket.journeyDate!.month,
          1,
          reason: 'Month should be January (1)',
        );
        expect(ticket.journeyDate!.day, 18, reason: 'Day should be 18');

        // Verify passenger pickup time
        expect(
          ticket.passengerPickupTime,
          isNotNull,
          reason: 'Passenger pickup time should not be null',
        );
        expect(
          ticket.passengerPickupTime!.year,
          2026,
          reason: 'Pickup year should be 2026',
        );
        expect(
          ticket.passengerPickupTime!.month,
          1,
          reason: 'Pickup month should be January (1)',
        );
        expect(
          ticket.passengerPickupTime!.day,
          18,
          reason: 'Pickup day should be 18',
        );
        expect(
          ticket.passengerPickupTime!.hour,
          13,
          reason: 'Pickup hour should be 13',
        );
        expect(
          ticket.passengerPickupTime!.minute,
          15,
          reason: 'Pickup minute should be 15',
        );
      },
    );

    test('should handle different date formats (slash vs dash)', () {
      final testCases = [
        {
          'text': 'Date of Journey: 18/01/2026',
          'expectedDay': 18,
          'expectedMonth': 1,
          'expectedYear': 2026,
        },
        {
          'text': 'Date of Journey: 18-01-2026',
          'expectedDay': 18,
          'expectedMonth': 1,
          'expectedYear': 2026,
        },
        {
          'text': 'Date of Journey: 25/12/2025',
          'expectedDay': 25,
          'expectedMonth': 12,
          'expectedYear': 2025,
        },
      ];

      for (final testCase in testCases) {
        final ticket = parser.parseTicket(testCase['text']! as String);
        expect(ticket.journeyDate, isNotNull);
        expect(ticket.journeyDate!.day, testCase['expectedDay']);
        expect(ticket.journeyDate!.month, testCase['expectedMonth']);
        expect(ticket.journeyDate!.year, testCase['expectedYear']);
      }
    });

    test('should handle different datetime formats for pickup time', () {
      final testCases = [
        {
          'text': 'Passenger Pickup Time: 18/01/2026 13:15 Hrs.',
          'expectedDay': 18,
          'expectedMonth': 1,
          'expectedYear': 2026,
          'expectedHour': 13,
          'expectedMinute': 15,
        },
        {
          'text': 'Passenger Pickup Time: 18-01-2026 13:15',
          'expectedDay': 18,
          'expectedMonth': 1,
          'expectedYear': 2026,
          'expectedHour': 13,
          'expectedMinute': 15,
        },
        {
          'text': 'Passenger Pickup Time: 25/12/2025 08:30 Hrs',
          'expectedDay': 25,
          'expectedMonth': 12,
          'expectedYear': 2025,
          'expectedHour': 8,
          'expectedMinute': 30,
        },
      ];

      for (final testCase in testCases) {
        final ticket = parser.parseTicket(testCase['text']! as String);
        expect(
          ticket.passengerPickupTime,
          isNotNull,
          reason: 'Parsing: ${testCase['text']}',
        );
        expect(ticket.passengerPickupTime!.day, testCase['expectedDay']);
        expect(ticket.passengerPickupTime!.month, testCase['expectedMonth']);
        expect(ticket.passengerPickupTime!.year, testCase['expectedYear']);
        expect(ticket.passengerPickupTime!.hour, testCase['expectedHour']);
        expect(ticket.passengerPickupTime!.minute, testCase['expectedMinute']);
      }
    });

    test('should verify service start time is extracted as string', () {
      const rawText = '''
Service Start Time: 13:15 Hrs.
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
Date of Journey: 18/01/2026
''';

      final ticket = parser.parseTicket(rawText);

      expect(ticket.serviceStartTime, isNotNull);
      expect(
        ticket.serviceStartTime,
        '13:15',
        reason: 'Service start time should be extracted as HH:mm string',
      );
    });
  });
}
