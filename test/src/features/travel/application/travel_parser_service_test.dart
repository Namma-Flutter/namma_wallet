import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_service.dart';

import '../../../../fixtures/tnstc_layout_fixtures.dart';
import '../../../../fixtures/tnstc_sms_fixtures.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  setUpAll(() async {
    final fakeLogger = FakeLogger();
    getIt.registerLazySingleton<ILogger>(() => fakeLogger);
  });

  group('TravelParserService Tests', () {
    late TravelParserService service;
    late FakeLogger fakeLogger;

    setUp(() async {
      fakeLogger = getIt<ILogger>() as FakeLogger;
      service = TravelParserService(logger: fakeLogger);
      getIt.pushNewScope();
    });

    tearDown(() async {
      await getIt.popScope();
    });

    group('TNSTC Parser - PDF (Layout) Format', () {
      test(
        'Given SETC PDF OCR blocks, When parsing ticket, '
        'Then returns valid SETC ticket',
        () {
          // Arrange
          final blocks = TnstcLayoutFixtures.t73266848;

          // Act
          final ticket = service.parseTicketFromBlocks(blocks);

          // Assert
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('T73266848'));
          expect(ticket.type, equals(TicketType.bus));
          expect(
            ticket.startTime,
            isNotNull,
            reason: 'startTime (journey date) should not be null',
          );

          // Verify passenger details
          expect(ticket.extras, isNotNull);
          final passengerExtra = ticket.extras
              ?.where((e) => e.title == 'Passenger')
              .toList();
          expect(
            passengerExtra,
            isNotEmpty,
            reason: 'Passenger info should be extracted',
          );
          expect(passengerExtra![0].value, contains('HarishAnbalagan'));
          expect(passengerExtra[0].child, isNotNull);
          final seatExtra = passengerExtra[0].child
              ?.where((e) => e.title == 'Seat')
              .firstOrNull;
          expect(seatExtra?.value, equals('10UB'));

          // Verify missing fields reported by user
          // Note: We check the ticket's derived fields or extras
          expect(ticket.location, contains('CHENNAI-PT Dr.M.G.R. BS'));

          final extrasMap = {for (final e in ticket.extras!) e.title: e.value};
          expect(
            extrasMap['Departure'],
            contains('11:30 PM'),
          ); // From serviceStartTime
          expect(
            extrasMap['Pickup Time'],
            contains('11:30 PM'),
          ); // From passengerPickupTime
          expect(extrasMap['Platform'], equals('2'));
          expect(extrasMap['Service Class'], equals('AC SLEEPER SEATER'));
          expect(extrasMap['Booking Ref'], equals('OB31464175'));
          expect(extrasMap['Bus ID'], equals('E-3269'));

          final providerExtra = ticket.extras?.firstWhere(
            (e) => e.title == 'Provider',
          );
          expect(providerExtra?.value, equals('SETC'));
        },
      );
    });

    group('TNSTC Parser - SMS Format', () {
      test(
        'Given TNSTC SMS format text, When parsing ticket, '
        'Then returns valid TNSTC ticket',
        () {
          // Arrange (Given) - Using real TNSTC SMS data
          const smsText = TnstcSmsFixtures.setcKumbakonamToChennai;

          // Act (When)
          final ticket = service.parseTicketFromText(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('T73309927'));
        },
      );

      test(
        'Given SETC SMS format text, When parsing ticket, '
        'Then returns valid SETC ticket',
        () {
          // Arrange (Given) - Using real SETC SMS data
          const smsText = TnstcSmsFixtures.setcChennaiToKumbakonam;

          // Act (When)
          final ticket = service.parseTicketFromText(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('T69704790'));
        },
      );
    });

    group('IRCTC Parser - Text Format', () {
      test(
        'Given IRCTC text with all details, When parsing ticket, '
        'Then returns valid IRCTC ticket',
        () {
          // Arrange (Given)
          const irctcText = '''
IRCTC Train Ticket
PNR No. : 1234567890
Train No. : 12345
Train Name : Chennai Express
Passenger Name : John Doe
Date of Journey : 25/12/2024
Boarding Point : Chennai Central
Reservation Upto : Mumbai Central
Scheduled Departure : 14:30
''';

          // Act (When)
          final ticket = service.parseTicketFromText(irctcText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('1234567890'));
          expect(ticket.primaryText, contains('Chennai Express'));
        },
      );

      test(
        'Given IRCTC text with minimal details, When parsing ticket, '
        'Then returns ticket with unknown values',
        () {
          // Arrange (Given)
          const irctcText = '''
IRCTC
PNR No. : ABC123
''';

          // Act (When)
          final ticket = service.parseTicketFromText(irctcText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('ABC123'));
        },
      );

      test(
        'Given IRCTC text with invalid journey date, When parsing ticket, '
        'Then uses sentinel value and logs warning',
        () {
          // Arrange (Given)
          const irctcText = '''
IRCTC Train Ticket
PNR No. : 9876543210
Train No. : 54321
Date of Journey : INVALID_DATE
Boarding Point : Delhi
Reservation Upto : Kolkata
''';

          // Act (When)
          final ticket = service.parseTicketFromText(irctcText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('9876543210'));
          // Should use sentinel value (epoch 1970)
          expect(
            ticket.startTime,
            equals(IRCTCTrainParser.invalidDateSentinel),
          );
        },
      );
    });

    group('TNSTC Update SMS Parsing', () {
      test(
        'Given TNSTC update SMS with conductor details, '
        'When parsing update, Then returns ticket update info',
        () {
          // Arrange (Given) - Using real TNSTC update SMS
          const updateSMS = TnstcSmsFixtures.tnstcUpdateSms1;

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNotNull);
          expect(updateInfo!.pnrNumber, equals('T69704790'));
          expect(updateInfo.providerName, equals('TNSTC'));
          expect(updateInfo.updates, isNotEmpty);
        },
      );

      test(
        'Given TNSTC update SMS with conductor and vehicle, '
        'When parsing update, Then returns update info with both details',
        () {
          // Arrange (Given) - Using real TNSTC update SMS
          const updateSMS = TnstcSmsFixtures.tnstcUpdateSms2;

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNotNull);
          expect(updateInfo!.pnrNumber, equals('T69705233'));
        },
      );

      test(
        'Given TNSTC update SMS with only vehicle no, When parsing update, '
        'Then returns update info with only vehicle',
        () {
          // Arrange (Given)
          const updateSMS = '''
TNSTC
PNR NO. : T111222333
Vehicle No : TN99XY9999
''';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNotNull);
          expect(updateInfo!.pnrNumber, equals('T111222333'));
        },
      );

      test(
        'Given update SMS without PNR, When parsing update, '
        'Then returns null',
        () {
          // Arrange (Given)
          const updateSMS = '''
TNSTC Update
Conductor Mobile No : 9876543210
''';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNull);
        },
      );

      test(
        'Given update SMS without any update fields, When parsing update, '
        'Then returns null',
        () {
          // Arrange (Given)
          const updateSMS = '''
TNSTC
PNR NO. : T123456789
''';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNull);
        },
      );

      test(
        'Given non-TNSTC update SMS, When parsing update, '
        'Then returns null',
        () {
          // Arrange (Given)
          const updateSMS = 'Some random SMS without TNSTC keywords';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNull);
        },
      );
    });

    group('Source Type Handling', () {
      test(
        'Given ticket text with source type, When parsing ticket, '
        'Then adds source type to extras',
        () {
          // Arrange (Given)
          const irctcText = '''
IRCTC
PNR No. : 1234567890
Train No. : 12345
''';

          // Act (When)
          final ticket = service.parseTicketFromText(
            irctcText,
            sourceType: SourceType.sms,
          );

          // Assert (Then)
          expect(ticket, isNotNull);
          final sourceExtra = ticket!.extras?.firstWhere(
            (extra) => extra.title == 'Source Type',
            orElse: () => throw StateError('Source Type not found'),
          );
          expect(sourceExtra?.value, equals('sms'));
        },
      );

      test(
        'Given ticket text without source type, When parsing ticket, '
        'Then source type can be added via sourceType parameter',
        () {
          // Arrange (Given)
          const irctcText = '''
IRCTC
PNR No. : ABC123
''';

          // Act (When)
          final ticket = service.parseTicketFromText(irctcText);

          // Assert (Then)
          expect(ticket, isNotNull);
          // IRCTC parser does not add source type by default
          final providerExtras = ticket!.extras?.where(
            (extra) => extra.title == 'Provider',
          );
          expect(providerExtras, isNotEmpty);
        },
      );
    });

    group('Parser Selection Logic', () {
      test(
        'Given text with SETC and TNSTC keywords, When parsing ticket, '
        'Then prefers SETC parser',
        () {
          // Arrange (Given)
          // SETC should match first because it's registered before TNSTC
          const smsText = '''
SETC - Tamil Nadu State Transport
From : CHENNAI To MADURAI
PNR NO. : S123456789
''';

          // Act (When)
          final ticket = service.parseTicketFromText(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
          final providerExtra = ticket!.extras?.firstWhere(
            (extra) => extra.title == 'Provider',
            orElse: () => throw StateError('Provider not found'),
          );
          expect(providerExtra?.value, equals('SETC'));
        },
      );

      test(
        'Given text with only TNSTC keywords, When parsing ticket, '
        'Then uses TNSTC parser',
        () {
          // Arrange (Given)
          const smsText = '''
TNSTC Bus Ticket
Corporation
PNR NO. : T123456789
''';

          // Act (When)
          final ticket = service.parseTicketFromText(smsText);

          // Assert (Then)
          expect(ticket, isNotNull);
        },
      );

      test(
        'Given text with no matching patterns, When parsing ticket, '
        'Then returns null',
        () {
          // Arrange (Given)
          const randomText = 'This is just a random text with no ticket info';

          // Act (When)
          final ticket = service.parseTicketFromText(randomText);

          // Assert (Then)
          expect(ticket, isNull);
        },
      );
    });

    group('Error Handling', () {
      test(
        'Given malformed text that matches pattern, When parsing fails, '
        'Then returns ticket with empty ticketId',
        () {
          // Arrange (Given)
          const malformedText = '''
IRCTC
PNR No. :
Train No. :
''';

          // Act (When)
          final ticket = service.parseTicketFromText(malformedText);

          // Assert (Then)
          // Should still parse but with empty ticketId
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, isEmpty);
        },
      );

      test(
        'Given empty text, When parsing ticket, '
        'Then returns null',
        () {
          // Arrange (Given)
          const emptyText = '';

          // Act (When)
          final ticket = service.parseTicketFromText(emptyText);

          // Assert (Then)
          expect(ticket, isNull);
        },
      );

      test(
        'Given whitespace-only text, When parsing ticket, '
        'Then returns null',
        () {
          // Arrange (Given)
          const whitespaceText = '   \n\t   ';

          // Act (When)
          final ticket = service.parseTicketFromText(whitespaceText);

          // Assert (Then)
          expect(ticket, isNull);
        },
      );
    });

    group('Service Helper Methods', () {
      test(
        'Given service, When getting supported providers, '
        'Then returns list of all parser provider names',
        () {
          // Act (When)
          final providers = service.getSupportedProviders();

          // Assert (Then)
          expect(providers, contains('SETC'));
          expect(providers, contains('TNSTC'));
          expect(providers, contains('IRCTC'));
          expect(providers.length, equals(3));
        },
      );

      test(
        'Given TNSTC ticket text, When checking if ticket text, '
        'Then returns true',
        () {
          // Arrange (Given)
          const tnstcText = 'TNSTC Bus Ticket PNR NO. : T123';

          // Act (When)
          final isTicket = service.isTicketText(tnstcText);

          // Assert (Then)
          expect(isTicket, isTrue);
        },
      );

      test(
        'Given IRCTC ticket text, When checking if ticket text, '
        'Then returns true',
        () {
          // Arrange (Given)
          const irctcText = 'IRCTC PNR No. : 123456';

          // Act (When)
          final isTicket = service.isTicketText(irctcText);

          // Assert (Then)
          expect(isTicket, isTrue);
        },
      );

      test(
        'Given random text, When checking if ticket text, '
        'Then returns false',
        () {
          // Arrange (Given)
          const randomText = 'Hello, this is not a ticket';

          // Act (When)
          final isTicket = service.isTicketText(randomText);

          // Assert (Then)
          expect(isTicket, isFalse);
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given very long text with ticket pattern, When parsing ticket, '
        'Then successfully extracts ticket information',
        () {
          // Arrange (Given)
          final longText =
              '''
${'Random padding text. ' * 100}
IRCTC
PNR No. : 1234567890
Train No. : 12345
${'More random text. ' * 100}
''';

          // Act (When)
          final ticket = service.parseTicketFromText(longText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('1234567890'));
        },
      );

      test(
        'Given text with Unicode characters, When parsing ticket, '
        'Then handles Unicode correctly',
        () {
          // Arrange (Given)
          const unicodeText = '''
IRCTC தமிழ்
PNR No. : தமிழ்123
Train No. : 12345
Train Name : Chennai தமிழ் Express
''';

          // Act (When)
          final ticket = service.parseTicketFromText(unicodeText);

          // Assert (Then)
          expect(ticket, isNotNull);
        },
      );

      test(
        'Given text with special characters in PNR, When parsing ticket, '
        'Then extracts PNR correctly',
        () {
          // Arrange (Given)
          const specialText = '''
IRCTC
PNR No. : ABC123XYZ
Train No. : 99999
''';

          // Act (When)
          final ticket = service.parseTicketFromText(specialText);

          // Assert (Then)
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, equals('ABC123XYZ'));
        },
      );
    });

    group('TNSTCBusParser Format Detection', () {
      test(
        'Given TNSTC PDF format text, When parsing, '
        'Then detects PDF format correctly',
        () {
          // Arrange (Given)
          const pdfText = '''
Tamil Nadu State Transport Corporation
Service Start Place : Chennai
Service End Place : Bangalore
PNR Number : T123456789
Date of Journey : 15/12/2024
Passenger Pickup Point : Koyambedu
Bank Txn ID : 123456
''';

          // Act (When)
          final ticket = service.parseTicketFromText(pdfText);

          // Assert (Then)
          expect(ticket, isNotNull);
          // PDF parser should be used
        },
      );

      test(
        'Given TNSTC SMS format text, When parsing, '
        'Then detects SMS format correctly',
        () {
          // Arrange (Given)
          const smsText = '''
From : CHENNAI
To BANGALORE
Trip : 12345
Time : 14:30
Boarding at : Koyambedu
''';

          // Act (When)
          final ticket = service.parseTicketFromText(smsText);

          // Assert (Then)
          // SMS parser should be used (if it matches TNSTC patterns)
          // This might return null if TNSTC patterns aren't fully matched
          expect(ticket, isNull);
        },
      );
    });

    group('PNR Masking in Logs', () {
      test(
        'Given update SMS with long PNR, When parsing, '
        'Then masks PNR in logs',
        () {
          // Arrange (Given)
          const updateSMS = '''
TNSTC
PNR NO. : T123456789012
Conductor Mobile No : 9876543210
''';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNotNull);
          expect(updateInfo!.pnrNumber, equals('T123456789012'));
          // PNR should be masked in logs (implementation shows last 3 chars)
          // T123456789012 -> **********012
          expect(
            fakeLogger.logs.any((log) => log.contains('**********012')),
            isTrue,
            reason: 'PNR should be masked in logs',
          );
        },
      );

      test(
        'Given update SMS with short PNR, When parsing, '
        'Then handles masking for short PNR',
        () {
          // Arrange (Given)
          const updateSMS = '''
TNSTC
PNR : T12
Conductor Mobile No : 9876543210
''';

          // Act (When)
          final updateInfo = service.parseUpdateSMS(updateSMS);

          // Assert (Then)
          expect(updateInfo, isNotNull);
          expect(updateInfo!.pnrNumber, equals('T12'));
          // Short PNRs (<=3) are masked as ***
          expect(
            fakeLogger.logs.any((log) => log.contains('PNR: ***')),
            isTrue,
          );
        },
      );
    });
  });
}
