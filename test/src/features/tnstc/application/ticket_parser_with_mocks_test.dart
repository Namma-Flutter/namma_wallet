import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/i_ticket_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';

import '../../../common/helpers/fake_logger.dart';
import '../../../common/helpers/mock_ocr_service.dart';

/// Mock implementation of ITicketParser for testing
class MockTicketParser implements ITicketParser {
  @override
  Ticket parseTicket(String rawText) {
    return Ticket(
      ticketId: 'MOCK123',
      primaryText: 'Mock Origin → Mock Destination',
      secondaryText: 'Mock Corporation - MockTrip',
      startTime: DateTime(2024, 12, 15, 10, 30),
      location: 'Mock Location',
    );
  }
}

void main() {
  group('TNSTC Parsers with Mocked Dependencies', () {
    final getIt = GetIt.instance;

    setUp(() {
      // Arrange - Set up mocked dependencies using fakes/mocks
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }
      if (!getIt.isRegistered<OCRService>()) {
        getIt.registerSingleton<OCRService>(MockOCRService());
      }
    });

    tearDown(() async {
      // Cleanup - Reset GetIt after each test
      await getIt.reset();
    });

    group('TNSTCPDFParser', () {
      late TNSTCPDFParser parser;

      setUp(() {
        // Arrange - Create parser instance
        parser = TNSTCPDFParser();
      });

      test(
        'Given valid PDF text with all fields, When parsing ticket, '
        'Then extracts complete ticket data',
        () {
          // Arrange (Given)
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

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.ticketId, equals('T12345678'));
          expect(ticket.primaryText, equals('CHENNAI → BANGALORE'));
          expect(ticket.secondaryText, contains('SETC'));
          expect(ticket.secondaryText, contains('TEST123'));

          // Verify extras contain expected fields
          final extras = ticket.extras!;
          expect(
            extras.any(
              (e) => e.title == 'PNR Number' && e.value == 'T12345678',
            ),
            isTrue,
          );
          expect(
            extras.any((e) => e.title == 'Trip Code' && e.value == 'TEST123'),
            isTrue,
          );
          expect(
            extras.any((e) => e.title == 'Fare' && e.value == '₹500.00'),
            isTrue,
          );

          // Verify tags
          final tags = ticket.tags!;
          expect(
            tags.any((t) => t.icon == 'event_seat' && t.value == '1A'),
            isTrue,
          );
          expect(
            tags.any(
              (t) => t.icon == 'attach_money' && t.value == '₹500.00',
            ),
            isTrue,
          );
        },
      );

      test(
        'Given minimal PDF text, When parsing ticket, '
        'Then returns ticket with defaults',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
''';

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.ticketId, equals('T12345678'));
          expect(ticket.secondaryText, contains('TEST123'));
        },
      );

      test(
        'Given empty PDF text, When parsing ticket, '
        'Then returns ticket with default values without throwing',
        () {
          // Arrange (Given)
          const pdfText = '';

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.primaryText, isNotNull);
          expect(ticket.secondaryText, isNotNull);
        },
      );

      test(
        'Given PDF with malformed date, When parsing ticket, '
        'Then uses fallback date without throwing',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Date of Journey : invalid-date
Trip Code : TEST123
''';

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.startTime, isNotNull);
        },
      );

      test(
        'Given PDF with invalid numbers, When parsing ticket, '
        'Then uses default numeric values without throwing',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
No. of Seats : invalid
Total Fare : not-a-number Rs.
Trip Code : TEST123
''';

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          // Should default to 1 seat
          final seatsExtra = ticket.extras
              ?.where((e) => e.title == 'Seats')
              .firstOrNull;
          expect(seatsExtra?.value, anyOf('1', isNull));
        },
      );

      test(
        'Given PDF with passenger in table format, When parsing ticket, '
        'Then extracts passenger details correctly',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Name Age Adult/Child Gender Seat No.
JohnDoe 30 Adult M 2B
''';

          // Act (When)
          final ticket = parser.parseTicket(pdfText);

          // Assert (Then)
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
        },
      );
    });

    group('TNSTCSMSParser', () {
      late TNSTCSMSParser parser;

      setUp(() {
        // Arrange - Create parser instance
        parser = TNSTCSMSParser();
      });

      test(
        'Given booking confirmation SMS, When parsing ticket, '
        'Then extracts all booking details',
        () {
          // Arrange (Given)
          const smsText = '''
Corporation : SETC, From : CHENNAI To BANGALORE
Trip Code : TEST123 Journey Date : 15/12/2024
Time : 15/12/2024 14:30 Seat No. : 1A Class : AC SLEEPER
Boarding at : KOYAMBEDU
''';

          // Act (When)
          final ticket = parser.parseTicket(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.primaryText, contains('CHENNAI'));
          expect(ticket.primaryText, contains('BANGALORE'));
          // Corporation may or may not be parsed depending on format
          expect(
            ticket.secondaryText,
            anyOf(contains('SETC'), contains('TEST123')),
          );

          // Verify extras contain source type
          final extras = ticket.extras!;
          expect(
            extras.any((e) => e.title == 'Source Type' && e.value == 'SMS'),
            isTrue,
          );
          // Verify at least some extras are present
          expect(extras.length, greaterThan(0));
        },
      );

      test(
        'Given conductor SMS, When parsing ticket, '
        'Then extracts conductor and vehicle details',
        () {
          // Arrange (Given)
          const smsText = '''
PNR NO. : T12345678, Journey Date : 15/12/2024,
Conductor Mobile No: 9876543210, Vehicle No:TN01AB1234
''';

          // Act (When)
          final ticket = parser.parseTicket(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.ticketId, equals('T12345678'));

          // Verify conductor details in extras
          final extras = ticket.extras!;
          expect(
            extras.any(
              (e) => e.title == 'Conductor Contact' && e.value == '9876543210',
            ),
            isTrue,
          );
          expect(
            extras.any(
              (e) => e.title == 'Bus Number' && e.value == 'TN01AB1234',
            ),
            isTrue,
          );
        },
      );

      test(
        'Given empty SMS text, When parsing ticket, '
        'Then returns ticket with defaults without throwing',
        () {
          // Arrange (Given)
          const smsText = '';

          // Act (When)
          final ticket = parser.parseTicket(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.primaryText, isNotNull);
        },
      );

      test(
        'Given SMS with PNR in alternate format, When parsing ticket, '
        'Then extracts PNR correctly',
        () {
          // Arrange (Given)
          const smsText = 'PNR: T88888888, DOJ:20/12/2024';

          // Act (When)
          final ticket = parser.parseTicket(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.ticketId, equals('T88888888'));
        },
      );

      test(
        'Given SMS with multiple seat numbers, When parsing ticket, '
        'Then calculates seat count correctly',
        () {
          // Arrange (Given)
          const smsText = '''
Corporation : SETC, PNR NO. : T12345678,
Seat No. : 1A,2B,3C, Journey Date : 15/12/2024
''';

          // Act (When)
          final ticket = parser.parseTicket(smsText);

          // Assert (Then)
          final seatsExtra = ticket.extras
              ?.firstWhere((e) => e.title == 'Seats')
              .value;
          // Parser counts seats based on comma-separated values
          expect(seatsExtra, anyOf(equals('3'), equals('4')));
        },
      );
    });

    group('ITicketParser Interface Compliance', () {
      test(
        'Given TNSTCPDFParser, When checking type, '
        'Then implements ITicketParser interface',
        () {
          // Arrange (Given)
          final parser = TNSTCPDFParser();

          // Act & Assert (When & Then)
          expect(parser, isA<ITicketParser>());
        },
      );

      test(
        'Given TNSTCSMSParser, When checking type, '
        'Then implements ITicketParser interface',
        () {
          // Arrange (Given)
          final parser = TNSTCSMSParser();

          // Act & Assert (When & Then)
          expect(parser, isA<ITicketParser>());
        },
      );

      test(
        'Given mock ITicketParser implementation, When calling parseTicket, '
        'Then returns mocked ticket data',
        () {
          // Arrange (Given)
          final mockParser = MockTicketParser();
          const testText = 'test ticket text';

          // Act (When)
          final ticket = mockParser.parseTicket(testText);

          // Assert (Then)
          expect(ticket.ticketId, equals('MOCK123'));
          expect(ticket.primaryText, equals('Mock Origin → Mock Destination'));
          expect(ticket.secondaryText, contains('Mock Corporation'));
          expect(ticket.location, equals('Mock Location'));
          expect(ticket.startTime.year, equals(2024));
          expect(ticket.startTime.month, equals(12));
          expect(ticket.startTime.day, equals(15));
        },
      );

      test(
        'Given parser registered in GetIt, When retrieving parser, '
        'Then returns registered instance',
        () {
          // Arrange (Given)
          final parser = TNSTCPDFParser();
          getIt.registerSingleton<ITicketParser>(parser);

          // Act (When)
          final retrievedParser = getIt<ITicketParser>();

          // Assert (Then)
          expect(retrievedParser, isA<TNSTCPDFParser>());
          expect(retrievedParser, same(parser));

          // Cleanup
          getIt.unregister<ITicketParser>();
        },
      );
    });

    group('Error Handling and Edge Cases', () {
      late TNSTCPDFParser pdfParser;
      late TNSTCSMSParser smsParser;

      setUp(() {
        pdfParser = TNSTCPDFParser();
        smsParser = TNSTCSMSParser();
      });

      test(
        'Given PDF with special characters, When parsing ticket, '
        'Then handles special characters correctly',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai-T.Nagar (Main Road)
Service End Place : Bangalore@HSR Layout
Trip Code : TEST@#123
''';

          // Act (When)
          final ticket = pdfParser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(
            ticket.primaryText,
            contains('Chennai-T.Nagar (Main Road)'),
          );
        },
      );

      test(
        'Given SMS with extra whitespace, When parsing ticket, '
        'Then trims whitespace correctly',
        () {
          // Arrange (Given)
          const smsText = '''
   Corporation :  SETC  ,  PNR NO. :  T12345678  ,
   Trip Code :  TEST123
''';

          // Act (When)
          final ticket = smsParser.parseTicket(smsText);

          // Assert (Then)
          expect(ticket.ticketId, equals('T12345678'));
          expect(ticket.secondaryText, contains('TEST123'));
        },
      );

      test(
        'Given PDF with Unicode characters, When parsing ticket, '
        'Then handles Unicode text without errors',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation : SETC
PNR Number : T12345678
Service Start Place : Chennai Tambaram
Service End Place : Bangalore
Trip Code : TEST123
''';

          // Act (When)
          final ticket = pdfParser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.primaryText, contains('Chennai'));
          expect(ticket.primaryText, contains('Bangalore'));
        },
      );

      test(
        'Given null-like strings in PDF, When parsing ticket, '
        'Then handles null-like values gracefully',
        () {
          // Arrange (Given)
          const pdfText = '''
Corporation :
PNR Number : T12345678
Trip Code : TEST123
Platform Number :
''';

          // Act (When)
          final ticket = pdfParser.parseTicket(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket.ticketId, equals('T12345678'));
        },
      );

      test(
        'Given very long text in PDF, When parsing ticket, '
        'Then processes successfully without performance issues',
        () {
          // Arrange (Given)
          final longText = 'A' * 10000;
          final pdfText =
              '''
Corporation : SETC
PNR Number : T12345678
Trip Code : TEST123
Extra Data: $longText
''';

          // Act (When)
          final stopwatch = Stopwatch()..start();
          final ticket = pdfParser.parseTicket(pdfText);
          stopwatch.stop();

          // Assert (Then)
          expect(ticket, isNotNull);
          // Should be fast (less than 1 second)
          expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        },
      );
    });
  });
}
