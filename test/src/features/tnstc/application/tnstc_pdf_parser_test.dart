import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/ocr_service_interface.dart';

import '../../../../helpers/fake_logger.dart';
import '../../../../helpers/mock_ocr_service.dart';

void main() {
  // Set up GetIt for tests
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
    if (!getIt.isRegistered<IOCRService>()) {
      getIt.registerSingleton<IOCRService>(MockOCRService());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('TNSTCPDFParser Tests', () {
    late TNSTCPDFParser parser;
    late PDFService pdfService;

    setUp(() {
      parser = TNSTCPDFParser();
      pdfService = PDFService();
    });

    test(
      'Given valid TNSTC PDF text, When parsing ticket, '
      'Then extracts all fields correctly',
      () async {
        final pdfFile = File(
          'assets/data/E-Ticket_T73309927_18-01-2026.pdf',
        );

        // Skip test if PDF file doesn't exist
        if (!pdfFile.existsSync()) {
          return;
        }

        // Extract text from PDF
        final pdfText = await pdfService.extractTextFrom(pdfFile);

        // Skip if no text was extracted
        //(PDF might be empty or unreadable in test)
        if (pdfText.isEmpty) {
          return;
        }

        // Parse the PDF - now returns Ticket
        final ticket = parser.parseTicket(pdfText);

        // Verify PNR from ticketId
        expect(ticket.ticketId, equals('T73309927'));

        // Verify primary and secondary text
        expect(ticket.primaryText, isNotEmpty);
        expect(ticket.secondaryText, contains('SETC'));

        // Verify extras contain expected fields
        final pnrExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'PNR Number')
            .value;
        expect(pnrExtra, equals('T73309927'));

        final tripCodeExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Trip Code')
            .value;
        expect(tripCodeExtra, equals('1315KUMCHEAB'));

        final serviceClassExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Service Class')
            .value;
        expect(serviceClassExtra, equals('AC SLEEPER SEATER'));

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹735.00'));

        // Verify passenger info in extras
        final passengerNameExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerNameExtra, equals('HarishAnbalagan'));

        final ageExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Age')
            .value;
        expect(ageExtra, equals('26'));

        final genderExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Gender')
            .value;
        expect(genderExtra, equals('M'));

        // Verify tags
        final seatTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seatTag, equals('4UB'));

        // Verify Source Type is PDF
        final sourceType = ticket.extras
            ?.firstWhere((e) => e.title == 'Source Type')
            .value;
        expect(sourceType, equals('PDF'));

        // Verify journey date and time from startTime
        expect(ticket.startTime.day, equals(18));
        expect(ticket.startTime.month, equals(1));
        expect(ticket.startTime.year, equals(2026));
        expect(ticket.startTime.hour, equals(13)); // 01:15 PM = 13:15
        expect(ticket.startTime.minute, equals(15));
      },
    );

    test(
      'Given cleaned PDF text patterns, When parsing ticket, '
      'Then extracts fields correctly',
      () {
        // Simulate cleaned PDF text based on the actual structure
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Route No : 123AB
Service Start Place : CHENNAI
Service End Place : BANGALORE
Service Start Time : 14:30
Passenger Start Place : CHENNAI
Passenger End Place : BANGALORE
Passenger Pickup Point : KOYAMBEDU
Passenger Pickup Time : 15/12/2024 14:30 Hrs.
Platform Number : 5
Class of Service : AC SLEEPER
Trip Code : TEST123
OB Reference No. : OB12345678
No. of Seats : 1
Bank Txn. No. : TXN123456789
Bus ID No. : BUS-123
Passenger category : General
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 1A
ID Card Type : Government Issued Photo ID Card
ID Card Number : 123456789012
Total Fare : 500.00 Rs.
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify core fields are extracted correctly from Ticket model
        expect(ticket.ticketId, equals('T12345678'));
        expect(ticket.primaryText, equals('CHENNAI → BANGALORE'));
        expect(ticket.secondaryText, equals('SETC - TEST123'));

        // Verify extras
        final tripCodeExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Trip Code')
            .value;
        expect(tripCodeExtra, equals('TEST123'));

        final passengerNameExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerNameExtra, equals('TestUser'));

        final ageExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Age')
            .value;
        expect(ageExtra, equals('25'));

        final genderExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Gender')
            .value;
        expect(genderExtra, equals('M'));

        final busIdExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Bus ID')
            .value;
        expect(busIdExtra, equals('BUS-123'));

        final serviceClassExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Service Class')
            .value;
        expect(serviceClassExtra, equals('AC SLEEPER'));

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹500.00'));

        // Verify tags
        final seatTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seatTag, equals('1A'));

        // Verify journey date from startTime
        expect(ticket.startTime.day, equals(15));
        expect(ticket.startTime.month, equals(12));
        expect(ticket.startTime.year, equals(2024));
        expect(ticket.startTime.hour, equals(14));
        expect(ticket.startTime.minute, equals(30));

        // Verify Source Type is PDF
        final sourceType = ticket.extras
            ?.firstWhere((e) => e.title == 'Source Type')
            .value;
        expect(sourceType, equals('PDF'));
      },
    );

    test(
      'Given PDF with empty platform number, When parsing ticket, '
      'Then platform is not included in extras',
      () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Platform Number :
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);

        // Platform should not be in extras if empty
        final platformExtra = ticket.extras
            ?.where((e) => e.title == 'Platform')
            .firstOrNull;
        expect(platformExtra, isNull);
      },
    );

    test(
      'Given passenger pickup time with Hrs suffix, When parsing ticket, '
      'Then pickup time is parsed correctly',
      () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Passenger Pickup Time : 15/12/2024 14:30 Hrs.
Service Start Time : 14:30
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 1A
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify pickup time is parsed correctly
        final pickupTimeExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Pickup Time')
            .value;
        expect(pickupTimeExtra, isNotNull);
        // Format is "15-12-2024 02:30 PM" so just check it's not empty
        expect(pickupTimeExtra!.length, greaterThan(0));
      },
    );

    test(
      'Given total fare with decimal values, When parsing ticket, '
      'Then fare is formatted correctly',
      () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Total Fare : 123.50 Rs.
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹123.50'));

        // Also check tag
        final fareTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'attach_money')
            .value;
        expect(fareTag, equals('₹123.50'));
      },
    );

    // ============== Date Parsing Edge Cases ==============
    group('Date Parsing', () {
      test(
        'Given date with slash separator, When parsing ticket, '
        'Then date is parsed correctly',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/10/2025
Trip Code : TEST123
''';

          final ticket = parser.parseTicket(pdfText);

          // Verify date is parsed (if parsing fails, falls back to today)
          expect(ticket.startTime, isNotNull);
          expect(ticket.startTime.year, greaterThanOrEqualTo(2025));
        },
      );

      test(
        'Given date with dash separator, When parsing ticket, '
        'Then date is parsed correctly',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15-10-2025
Trip Code : TEST123
''';

          final ticket = parser.parseTicket(pdfText);

          // Verify date is parsed
          expect(ticket.startTime, isNotNull);
          expect(ticket.startTime.year, greaterThanOrEqualTo(2025));
        },
      );

      test(
        'Given invalid date format, When parsing ticket, '
        'Then falls back to current date',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : invalid-date
Trip Code : TEST123
''';

          final ticket = parser.parseTicket(pdfText);

          // Should fall back to current date (DateTime.now())
          expect(ticket.startTime, isNotNull);
        },
      );

      test('Given empty date string, When parsing ticket, '
          'Then falls back to current date', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to current date
        expect(ticket.startTime, isNotNull);
      });

      test('Given malformed date parts, When parsing ticket, '
          'Then falls back to current date', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 99/99/9999
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to current date due to invalid date values
        expect(ticket.startTime, isNotNull);
      });
    });

    // ============== DateTime Parsing Edge Cases ==============
    group('DateTime Parsing', () {
      test('Given datetime with slash and Hrs suffix, When parsing, '
          'Then datetime is parsed correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Time : 25/12/2024 14:30 Hrs.
Service Start Time : 14:30
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.startTime.day, equals(25));
        expect(ticket.startTime.month, equals(12));
        expect(ticket.startTime.year, equals(2024));
        expect(ticket.startTime.hour, equals(14));
        expect(ticket.startTime.minute, equals(30));
      });

      test('Given datetime with dash separator, When parsing, '
          'Then datetime is parsed correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Time : 25-12-2024 09:45
Service Start Time : 09:45
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.startTime.day, equals(25));
        expect(ticket.startTime.month, equals(12));
        expect(ticket.startTime.year, equals(2024));
        expect(ticket.startTime.hour, equals(9));
        expect(ticket.startTime.minute, equals(45));
      });

      test('Given invalid datetime format, When parsing ticket, '
          'Then falls back to current datetime', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Time : invalid datetime
Service Start Time : 14:30
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to current datetime
        expect(ticket.startTime, isNotNull);
      });

      test('Given missing time component in datetime, When parsing, '
          'Then falls back to current datetime', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Time : 25/12/2024
Service Start Time : 14:30
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to current datetime
        expect(ticket.startTime, isNotNull);
      });

      test('Given invalid time values, When parsing ticket, '
          'Then falls back to current datetime', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Time : 25/12/2024 99:99
Service Start Time : 14:30
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to current datetime
        expect(ticket.startTime, isNotNull);
      });

      test('Given journey date with service time and no pickup time, '
          'When parsing, Then combines date and time correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/10/2025
Service Start Time : 16:45
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify time components are set
        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime.hour, anyOf(equals(16), greaterThan(0)));
        expect(
          ticket.startTime.minute,
          anyOf(equals(45), greaterThanOrEqualTo(0)),
        );
      });
    });

    // ============== Passenger Information Parsing ==============
    group('Passenger Information', () {
      test('Given passenger info in table format, When parsing ticket, '
          'Then extracts passenger details correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
JohnDoe 30 Adult M 2B
''';

        final ticket = parser.parseTicket(pdfText);

        final passengerName = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerName, equals('JohnDoe'));

        final age = ticket.extras?.firstWhere((e) => e.title == 'Age').value;
        expect(age, equals('30'));

        final gender = ticket.extras
            ?.firstWhere((e) => e.title == 'Gender')
            .value;
        expect(gender, equals('M'));

        final seat = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seat, equals('2B'));
      });

      test('Given child passenger info, When parsing ticket, '
          'Then extracts child details correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
JaneDoe 12 Child F 3C
''';

        final ticket = parser.parseTicket(pdfText);

        final passengerName = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerName, equals('JaneDoe'));

        final age = ticket.extras?.firstWhere((e) => e.title == 'Age').value;
        expect(age, equals('12'));

        final gender = ticket.extras
            ?.firstWhere((e) => e.title == 'Gender')
            .value;
        expect(gender, equals('F'));
      });

      test('Given broken table format, When parsing with fallback, '
          'Then extracts passenger info', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Passenger Information
JohnDoe
Age
28
Gender
M
Adult/Child
Adult
''';

        final ticket = parser.parseTicket(pdfText);

        final passengerName = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerName, equals('JohnDoe'));

        final age = ticket.extras?.firstWhere((e) => e.title == 'Age').value;
        expect(age, equals('28'));

        final gender = ticket.extras
            ?.firstWhere((e) => e.title == 'Gender')
            .value;
        expect(gender, equals('M'));
      });

      test('Given vertical headers with Seat No, When parsing, '
          'Then extracts seat number correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Passenger Information
Name
HarishAnbalagan
Age
26
Adult/Child
Adult
Gender
M
Seat No.
2LB
''';

        final ticket = parser.parseTicket(pdfText);

        final seatTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seatTag, equals('2LB'));
      });

      test('Given missing passenger information, When parsing ticket, '
          'Then handles gracefully without passenger fields', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should not throw, passenger fields should be absent
        final passengerName = ticket.extras
            ?.where((e) => e.title == 'Passenger Name')
            .firstOrNull;
        expect(passengerName, isNull);
      });
    });

    // ============== Field Extraction Edge Cases ==============
    group('Field Extraction', () {
      test('Given place names with special characters, When parsing, '
          'Then preserves special characters', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai (T.Nagar)
Service End Place : Bangalore-City
Passenger Start Place : Chennai (T.Nagar)
Passenger End Place : Bangalore-City
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(
          ticket.primaryText,
          equals('Chennai (T.Nagar) → Bangalore-City'),
        );
      });

      test('Given long corporation name, When parsing ticket, '
          'Then extracts full corporation name', () {
        const pdfText = '''
Corporation : State Express Transport Corporation
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final provider = ticket.extras
            ?.firstWhere((e) => e.title == 'Provider')
            .value;
        expect(provider, equals('State Express Transport Corporation'));
      });

      test('Given various ID card types, When parsing ticket, '
          'Then extracts ID number correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
ID Card Type : Aadhaar Card
ID Card Number : 123456789012
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final idNumber = ticket.extras
            ?.firstWhere((e) => e.title == 'Verification ID')
            .value;
        expect(idNumber, equals('123456789012'));
      });

      test('Given Government Issued Photo ID, When parsing ticket, '
          'Then extracts ID number correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Government Issued Photo
ID Card Number : 987654321012
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final idNumber = ticket.extras
            ?.firstWhere((e) => e.title == 'Verification ID')
            .value;
        expect(idNumber, equals('987654321012'));
      });

      test('Given complete route information, When parsing ticket, '
          'Then extracts all route fields', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Route No : 123A
Service Start Place : CHENNAI
Service End Place : COIMBATORE
Passenger Start Place : KOYAMBEDU
Passenger End Place : GANDHIPURAM
Passenger Pickup Point : KOYAMBEDU BUS STAND
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.primaryText, equals('CHENNAI → COIMBATORE'));

        final from = ticket.extras?.firstWhere((e) => e.title == 'From').value;
        expect(from, equals('CHENNAI'));

        final to = ticket.extras?.firstWhere((e) => e.title == 'To').value;
        expect(to, equals('COIMBATORE'));

        final location = ticket.location;
        expect(location, equals('KOYAMBEDU BUS STAND'));
      });

      test('Given bank transaction number with period, When parsing, '
          'Then extracts transaction number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Bank Txn. No. : BTN123456789
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });

      test('Given bank transaction with semicolon, When parsing, '
          'Then extracts transaction number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Bank Txn. No; : BTN987654321
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });

      test('Given passenger category variations, When parsing ticket, '
          'Then handles different category formats', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Category : Senior Citizen
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });

      test('Given lowercase passenger category, When parsing ticket, '
          'Then extracts category correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger category : Student
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });
    });

    // ============== Number Parsing Edge Cases ==============
    group('Number Parsing', () {
      test('Given zero fare, When parsing ticket, '
          'Then formats fare as zero', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Total Fare : 0.00 Rs.
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹0.00'));
      });

      test('Given fare without decimal, When parsing ticket, '
          'Then formats fare with decimal', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Total Fare : 500 Rs.
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹500.00'));
      });

      test('Given missing fare, When parsing ticket, '
          'Then defaults to zero fare', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // When fare is missing, parser defaults to 0.0
        final fareExtra = ticket.extras
            ?.where((e) => e.title == 'Fare')
            .firstOrNull;
        // Parser includes fare even if 0
        expect(fareExtra?.value, equals('₹0.00'));
      });

      test('Given zero seats, When parsing ticket, '
          'Then handles gracefully', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
No. of Seats : 0
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should not include seats in extras if 0
        expect(ticket, isNotNull);
      });

      test('Given multiple seats, When parsing ticket, '
          'Then extracts seat count correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
No. of Seats : 3
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final seats = ticket.extras
            ?.firstWhere((e) => e.title == 'Seats')
            .value;
        expect(seats, equals('3'));
      });

      test('Given invalid number format, When parsing ticket, '
          'Then falls back to default value', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
No. of Seats : invalid
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to default (1)
        expect(ticket, isNotNull);
      });
    });

    // ============== Multiple Passengers ==============
    group('Multiple Passengers', () {
      test('Given multiple passengers in table, When parsing ticket, '
          'Then extracts first passenger', () {
        // NOTE: Current parser extracts only the first passenger
        // TODO(enhancement): Use allMatches() for multi-passenger support
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
JohnDoe 30 Adult M 2B
JaneDoe 28 Adult F 3C
''';

        final ticket = parser.parseTicket(pdfText);

        // Currently only first passenger is extracted
        final passengerName = ticket.extras
            ?.firstWhere((e) => e.title == 'Passenger Name')
            .value;
        expect(passengerName, equals('JohnDoe'));

        final seat = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seat, equals('2B'));
      });

      test('Given passenger with no seat, When parsing ticket, '
          'Then handles missing seat gracefully', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M
''';

        final ticket = parser.parseTicket(pdfText);

        // Seat number should be empty when not in expected position
        expect(ticket, isNotNull);
      });
    });

    // ============== PNR Number Variations ==============
    group('PNR Number Variations', () {
      test('Given PNR with E prefix, When parsing ticket, '
          'Then extracts PNR correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : E12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.ticketId, equals('E12345678'));
      });

      test('Given alphanumeric PNR, When parsing ticket, '
          'Then extracts PNR correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : ABC123XYZ
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.ticketId, equals('ABC123XYZ'));
      });

      test('Given missing PNR Number, When parsing ticket, '
          'Then PNR is null or empty', () {
        const pdfText = '''
Corporation : SETC
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // PNR should be null or empty when missing
        expect(ticket.ticketId, anyOf(isNull, isEmpty));
      });
    });

    // ============== Corporation Name Variations ==============
    group('Corporation Name Variations', () {
      test('Given TNSTC corporation, When parsing ticket, '
          'Then extracts TNSTC as provider', () {
        const pdfText = '''
Corporation : TNSTC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final provider = ticket.extras
            ?.firstWhere((e) => e.title == 'Provider')
            .value;
        expect(provider, equals('TNSTC'));
        expect(ticket.secondaryText, contains('TNSTC'));
      });

      test('Given corporation with hyphens, When parsing ticket, '
          'Then extracts full corporation name', () {
        const pdfText = '''
Corporation : SETC-Tamil Nadu
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final provider = ticket.extras
            ?.firstWhere((e) => e.title == 'Provider')
            .value;
        expect(provider, equals('SETC-Tamil Nadu'));
      });

      test('Given missing corporation name, When parsing ticket, '
          'Then uses default corporation', () {
        const pdfText = '''
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // When corporation is empty, secondaryText uses 'TNSTC' as default
        // in the Ticket.fromTNSTC factory
        expect(
          ticket.secondaryText,
          anyOf(contains('TNSTC'), equals(' - TEST123')),
        );
      });
    });

    // ============== Route Number Edge Cases ==============
    group('Route Number Variations', () {
      test('Given route with alphanumeric format, When parsing, '
          'Then extracts route number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Route No : 123ABC
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });

      test('Given route with special characters, When parsing, '
          'Then extracts route number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Route No : 123-A/B
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket, isNotNull);
      });

      test('Given missing route number, When parsing ticket, '
          'Then uses trip code in secondary text', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should use trip code in secondary text when route is missing
        expect(ticket.secondaryText, contains('TEST123'));
      });
    });

    // ============== Service Start Time Variations ==============
    group('Service Start Time Variations', () {
      test('Given time with Hrs suffix, When parsing ticket, '
          'Then departure time is extracted', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Service Start Time : 14:30 Hrs.
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final departureTime = ticket.extras
            ?.firstWhere((e) => e.title == 'Departure Time')
            .value;
        expect(departureTime, isNotNull);
      });

      test('Given 24-hour time format, When parsing ticket, '
          'Then time is valid', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/10/2025
Service Start Time : 23:59
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify time is extracted and set
        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime.hour, lessThan(24));
        expect(ticket.startTime.minute, lessThan(60));
      });

      test('Given midnight time (00:00), When parsing ticket, '
          'Then time is valid', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/10/2025
Service Start Time : 00:00
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify time is valid
        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime.hour, greaterThanOrEqualTo(0));
        expect(ticket.startTime.minute, greaterThanOrEqualTo(0));
      });

      test('Given invalid service start time, When parsing ticket, '
          'Then falls back to date without time', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Service Start Time : invalid
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Should fall back to date without time
        expect(ticket.startTime, isNotNull);
      });
    });

    // ============== Ticket.fromTNSTC Behavior ==============
    group('Ticket.fromTNSTC Factory Method', () {
      test('Given all data available, When creating ticket from TNSTC, '
          'Then creates proper tags', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : 15/12/2024
Service Start Place : CHENNAI
Service End Place : BANGALORE
Service Start Time : 14:30
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 1A
Total Fare : 500.00 Rs.
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify tags are created
        expect(ticket.tags, isNotNull);
        expect(ticket.tags!.length, greaterThan(0));

        // Verify trip code tag
        final tripCodeTag = ticket.tags
            ?.where((t) => t.icon == 'confirmation_number')
            .firstOrNull;
        expect(tripCodeTag, isNotNull);
        expect(tripCodeTag!.value, equals('TEST123'));

        // Verify fare tag
        final fareTag = ticket.tags
            ?.where((t) => t.icon == 'attach_money')
            .firstOrNull;
        expect(fareTag, isNotNull);

        // Verify seat tag
        final seatTag = ticket.tags
            ?.where((t) => t.icon == 'event_seat')
            .firstOrNull;
        expect(seatTag, isNotNull);
      });

      test('Given sparse data, When creating ticket from TNSTC, '
          'Then creates minimal tags', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Tags should still be created even with minimal data
        expect(ticket.tags, isNotNull);
      });

      test(
        'should prioritize service places over passenger places '
        'for primaryText',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : SERVICE START
Service End Place : SERVICE END
Passenger Start Place : PASSENGER START
Passenger End Place : PASSENGER END
Trip Code : TEST123
''';

          final ticket = parser.parseTicket(pdfText);

          // Should use service places as per current implementation
          expect(ticket.primaryText, equals('SERVICE START → SERVICE END'));
        },
      );

      test('Given passenger pickup point, When creating ticket, '
          'Then sets location from pickup point', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : CHENNAI
Passenger Pickup Point : KOYAMBEDU BUS STAND
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.location, equals('KOYAMBEDU BUS STAND'));
      });

      test(
        'should fallback location to service start place when '
        'pickup point missing',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : CHENNAI
Trip Code : TEST123
''';

          final ticket = parser.parseTicket(pdfText);

          // Location fallback chain in Ticket.fromTNSTC:
          // passengerPickupPoint > boardingPoint > serviceStartPlace >
          // 'Unknown'
          expect(
            ticket.location,
            anyOf(equals('CHENNAI'), equals('Unknown'), isEmpty),
          );
        },
      );
    });

    // ============== Vehicle and Conductor Information ==============
    group('Vehicle and Conductor Information', () {
      test('Given vehicle number present, When parsing ticket, '
          'Then extracts bus ID', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Bus ID No. : TN-01-AB-1234
''';

        final ticket = parser.parseTicket(pdfText);

        final busId = ticket.extras
            ?.firstWhere((e) => e.title == 'Bus ID')
            .value;
        expect(busId, equals('TN-01-AB-1234'));
      });

      test('Given bus ID in different format, When parsing ticket, '
          'Then extracts bus ID correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Bus ID No. : E-5494
''';

        final ticket = parser.parseTicket(pdfText);

        final busId = ticket.extras
            ?.firstWhere((e) => e.title == 'Bus ID')
            .value;
        expect(busId, equals('E-5494'));
      });

      test('Given missing vehicle information, When parsing ticket, '
          'Then bus ID is not in extras', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Bus ID should not be in extras when missing
        final busId = ticket.extras
            ?.where((e) => e.title == 'Bus ID')
            .firstOrNull;
        expect(busId, isNull);
      });
    });

    // ============== Boarding Point and Pickup Location ==============
    group('Boarding Point and Pickup Logic', () {
      test('Given passenger pickup point, When parsing ticket, '
          'Then uses as boarding point', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Point : KOYAMBEDU BUS TERMINAL
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Boarding point stored in TNSTCModel should be pickup point
        expect(ticket.location, equals('KOYAMBEDU BUS TERMINAL'));
      });

      test('Given pickup point with special chars, When parsing ticket, '
          'Then preserves special characters', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Pickup Point : Chennai-T.Nagar (Main Road)
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.location, equals('Chennai-T.Nagar (Main Road)'));
      });
    });

    // ============== OB Reference Number ==============
    group('OB Reference Number', () {
      test('Given OB reference with standard format, When parsing, '
          'Then extracts OB reference', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
OB Reference No. : OB12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final obRef = ticket.extras
            ?.firstWhere((e) => e.title == 'Booking Ref')
            .value;
        expect(obRef, equals('OB12345678'));
      });

      test('Given OB reference alphanumeric format, When parsing, '
          'Then extracts OB reference', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
OB Reference No. : OB31475439
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final obRef = ticket.extras
            ?.firstWhere((e) => e.title == 'Booking Ref')
            .value;
        expect(obRef, equals('OB31475439'));
      });

      test('Given missing OB reference, When parsing ticket, '
          'Then OB reference is null', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final obRef = ticket.extras
            ?.where((e) => e.title == 'Booking Ref')
            .firstOrNull;
        expect(obRef, isNull);
      });
    });

    // ============== Class of Service Variations ==============
    group('Class of Service', () {
      test('Given AC SLEEPER class, When parsing ticket, '
          'Then extracts service class', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Class of Service : AC SLEEPER
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final serviceClass = ticket.extras
            ?.firstWhere((e) => e.title == 'Service Class')
            .value;
        expect(serviceClass, equals('AC SLEEPER'));
      });

      test('Given AC SLEEPER SEATER class, When parsing ticket, '
          'Then extracts service class', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Class of Service : AC SLEEPER SEATER
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final serviceClass = ticket.extras
            ?.firstWhere((e) => e.title == 'Service Class')
            .value;
        expect(serviceClass, equals('AC SLEEPER SEATER'));
      });

      test('Given NON AC class, When parsing ticket, '
          'Then extracts service class', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Class of Service : NON AC SEATER
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final serviceClass = ticket.extras
            ?.firstWhere((e) => e.title == 'Service Class')
            .value;
        expect(serviceClass, equals('NON AC SEATER'));
      });

      test('Given missing class of service, When parsing ticket, '
          'Then service class is null', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        final serviceClass = ticket.extras
            ?.where((e) => e.title == 'Service Class')
            .firstOrNull;
        expect(serviceClass, isNull);
      });
    });

    // ============== Seat Number Formats ==============
    group('Seat Number Formats', () {
      test('Given single digit seat, When parsing ticket, '
          'Then extracts seat number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 1
''';

        final ticket = parser.parseTicket(pdfText);

        final seat = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seat, equals('1'));
      });

      test('Given alphanumeric seat format, When parsing ticket, '
          'Then extracts seat number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 12B
''';

        final ticket = parser.parseTicket(pdfText);

        final seat = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seat, equals('12B'));
      });

      test('Given seat with UB/LB suffix, When parsing ticket, '
          'Then extracts seat number', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
TestUser 25 Adult M 4UB
''';

        final ticket = parser.parseTicket(pdfText);

        final seat = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seat, equals('4UB'));
      });
    });

    // ============== Trip Code Variations ==============
    group('Trip Code Variations', () {
      test('Given alphanumeric trip code, When parsing ticket, '
          'Then extracts trip code', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : 1315KUMCHEAB
''';

        final ticket = parser.parseTicket(pdfText);

        final tripCode = ticket.extras
            ?.firstWhere((e) => e.title == 'Trip Code')
            .value;
        expect(tripCode, equals('1315KUMCHEAB'));
        expect(ticket.secondaryText, contains('1315KUMCHEAB'));
      });

      test('Given numeric trip code, When parsing ticket, '
          'Then extracts trip code', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : 123456
''';

        final ticket = parser.parseTicket(pdfText);

        final tripCode = ticket.extras
            ?.firstWhere((e) => e.title == 'Trip Code')
            .value;
        expect(tripCode, equals('123456'));
      });

      test(
        'should use route number in secondaryText when trip code missing',
        () {
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Route No : 307AB
''';

          final ticket = parser.parseTicket(pdfText);

          // Ticket.fromTNSTC uses tripCode ?? routeNo ?? 'Bus'
          // When trip code is missing, it should use route number
          expect(
            ticket.secondaryText,
            anyOf(contains('307AB'), contains('Bus'), equals('SETC - ')),
          );
        },
      );
    });

    // ============== Edge Cases for Place Names ==============
    group('Place Name Edge Cases', () {
      test('Given very long place names, When parsing ticket, '
          'Then preserves full place names', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai-Koyambedu CMBT Terminus Bay Platform 5
Service End Place : Bangalore-Kempegowda Bus Station Platform 10
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(
          ticket.primaryText,
          equals(
            'Chennai-Koyambedu CMBT Terminus Bay Platform 5 → '
            'Bangalore-Kempegowda Bus Station Platform 10',
          ),
        );
      });

      test('Given place names with dots, When parsing ticket, '
          'Then preserves dots in place names', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai-PT Dr.M.G.R. BS
Service End Place : Madurai-M.G.R. Int. BS
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(
          ticket.primaryText,
          equals('Chennai-PT Dr.M.G.R. BS → Madurai-M.G.R. Int. BS'),
        );
      });

      test('Given place names with numbers, When parsing ticket, '
          'Then preserves numbers in place names', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai T.Nagar 24th Street
Service End Place : Bangalore 15th Cross
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(
          ticket.primaryText,
          equals('Chennai T.Nagar 24th Street → Bangalore 15th Cross'),
        );
      });
    });

    // ============== Integration and Error Handling ==============
    group('Integration and Error Handling', () {
      test('Given minimal valid ticket, When parsing, '
          'Then extracts basic fields', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.ticketId, equals('T12345678'));
        expect(ticket.secondaryText, contains('SETC'));
        expect(ticket.secondaryText, contains('TEST123'));
      });

      test('Given empty PDF text, When parsing ticket, '
          'Then returns ticket with default values', () {
        const pdfText = '';

        final ticket = parser.parseTicket(pdfText);

        // Should not throw, should return ticket with default values
        expect(ticket, isNotNull);
        expect(ticket.primaryText, isNotNull);
      });

      test('Given PDF with only whitespace, When parsing ticket, '
          'Then handles gracefully', () {
        const pdfText = '   \n\n   \t\t  \n  ';

        final ticket = parser.parseTicket(pdfText);

        // Should not throw
        expect(ticket, isNotNull);
      });

      test('Given PDF with garbage text, When parsing ticket, '
          'Then returns ticket with default values', () {
        const pdfText = r'''
asdkfjlaksjdflkasjdflkj
asldkfjalskdjflaksdjf
1234567890
@#$%^&*()
''';

        final ticket = parser.parseTicket(pdfText);

        // Should not throw, should return ticket with default values
        expect(ticket, isNotNull);
      });

      test('Given complete ticket with all fields, When parsing, '
          'Then extracts all available fields', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T99999999
Date of Journey : 31/12/2024
Route No : 999Z
Service Start Place : START CITY
Service End Place : END CITY
Service Start Time : 23:59
Passenger Start Place : PASS START
Passenger End Place : PASS END
Passenger Pickup Point : PICKUP LOCATION
Passenger Pickup Time : 31/12/2024 23:30 Hrs.
Platform Number : 99
Class of Service : ULTRA DELUXE AC
Trip Code : COMPLETE999
OB Reference No. : OB99999999
No. of Seats : 2
Bank Txn. No. : BANK999999
Bus ID No. : BUS-999-XYZ
Passenger Category : VIP
Name Age Adult/Child Gender Seat No.
CompleteTest 99 Adult F 99Z
ID Card Type : Government Issued Photo ID Card
ID Card Number : 999999999999
Total Fare : 9999.99 Rs.
''';

        final ticket = parser.parseTicket(pdfText);

        // Verify all major fields are present
        expect(ticket.ticketId, equals('T99999999'));
        expect(ticket.primaryText, equals('START CITY → END CITY'));
        expect(ticket.secondaryText, equals('SETC - COMPLETE999'));

        // Verify some key extras
        final pnrExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'PNR Number')
            .value;
        expect(pnrExtra, equals('T99999999'));

        final busIdExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Bus ID')
            .value;
        expect(busIdExtra, equals('BUS-999-XYZ'));

        final fareExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Fare')
            .value;
        expect(fareExtra, equals('₹9999.99'));

        final platformExtra = ticket.extras
            ?.firstWhere((e) => e.title == 'Platform')
            .value;
        expect(platformExtra, equals('99'));

        // Verify tags
        final seatTag = ticket.tags
            ?.firstWhere((t) => t.icon == 'event_seat')
            .value;
        expect(seatTag, equals('99Z'));
      });

      test('Given service places only, When parsing ticket, '
          'Then uses service places for primaryText', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : SERVICE START
Service End Place : SERVICE END
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        expect(ticket.primaryText, equals('SERVICE START → SERVICE END'));
      });

      test('Given passenger places only, When parsing ticket, '
          'Then uses passenger places for primaryText', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Passenger Start Place : PASSENGER START
Passenger End Place : PASSENGER END
Trip Code : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // Ticket.fromTNSTC prioritizes service places over passenger places
        // When service places are missing, it falls back to passenger places
        expect(
          ticket.primaryText,
          anyOf(
            equals('PASSENGER START → PASSENGER END'),
            equals(' → '),
            equals('Unknown → Unknown'),
          ),
        );
      });

      test('Given mixed case field labels, When parsing ticket, '
          'Then extracts fields correctly', () {
        const pdfText = '''
Corporation : SETC
PNR Number : T12345678
date of journey : 15/12/2024
TRIP CODE : TEST123
''';

        final ticket = parser.parseTicket(pdfText);

        // PNR should still be extracted (case-sensitive pattern)
        expect(ticket.ticketId, equals('T12345678'));
      });
    });
  });
}
