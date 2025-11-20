import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/application/travel_parser_service.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  // Set up GetIt for tests
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('TravelParserService Tests', () {
    late TravelParserService service;

    setUp(() {
      service = TravelParserService();
    });

    test('should detect and parse SETC SMS', () {
      const smsText =
          'TNSTC Corporation:SETC , PNR NO.:T63736642 , '
          'From:CHENNAI-PT DR. M.G.R. BS To KUMBAKONAM , '
          'Trip Code:2145CHEKUMAB , Journey Date:11/02/2025 , Time:22:35 , '
          'Seat No.:20,21 .Class:AC SLEEPER SEATER , '
          'Boarding at:KOTTIVAKKAM(RTO OFFICE) .';

      final ticket = service.parseTicketFromText(smsText);

      expect(ticket, isNotNull);
      expect(ticket!.primaryText, contains('CHENNAI'));
      expect(ticket.secondaryText, contains('SETC'));

      // Verify Source Type is SMS
      final sourceType = ticket.extras
          ?.firstWhere((e) => e.title == 'Source Type')
          .value;
      expect(sourceType, equals('SMS'));
    });

    test('should detect and parse TNSTC PDF text', () {
      const pdfText = '''
Corporation : TNSTC-KUMBAKONAM
PNR Number : T12345678
Date of Journey : 15/12/2024
Route No : 123AB
Service Start Place : CHENNAI
Service End Place : BANGALORE
Service Start Time : 14:30
Passenger Start Place : CHENNAI
Passenger End Place : BANGALORE
Trip Code : TEST123
''';

      final ticket = service.parseTicketFromText(pdfText);

      // PDF parser returns a ticket even if some fields are empty
      expect(ticket, isNotNull);

      // Verify Source Type is PDF (even if other fields are empty)
      final sourceType = ticket!.extras
          ?.firstWhere((e) => e.title == 'Source Type')
          .value;
      expect(sourceType, equals('PDF'));
    });

    test('should return null for unrecognized text', () {
      const randomText =
          'This is just random text that does not match any pattern';

      final ticket = service.parseTicketFromText(randomText);

      expect(ticket, isNull);
    });

    test('should correctly identify SETC as SMS format', () {
      const setcText =
          'TNSTC Corporation:SETC , PNR NO.:T12345678'
          ' , From:CHENNAI To BANGALORE';

      final ticket = service.parseTicketFromText(setcText);

      expect(ticket, isNotNull);

      final sourceType = ticket!.extras
          ?.firstWhere((e) => e.title == 'Source Type')
          .value;
      expect(sourceType, equals('SMS'));
    });

    test('should correctly identify Service Start Place as PDF format', () {
      const pdfText = '''
PNR Number : T12345678
Service Start Place : CHENNAI
Service End Place : BANGALORE
''';

      final ticket = service.parseTicketFromText(pdfText);

      expect(ticket, isNotNull);

      final sourceType = ticket!.extras
          ?.firstWhere((e) => e.title == 'Source Type')
          .value;
      expect(sourceType, equals('PDF'));
    });

    test('parseUpdateSMS should parse conductor SMS and extract details', () {
      const conductorSMS =
          'TNSTC PNR:T12345678, Conductor Mobile No:9876543210,'
          ' Vehicle No:TN01AB1234';

      final updateInfo = service.parseUpdateSMS(conductorSMS);

      expect(updateInfo, isNotNull);
      expect(updateInfo!.pnrNumber, equals('T12345678'));
      expect(updateInfo.providerName, equals('TNSTC'));
      expect(updateInfo.updates, isNotEmpty);
      expect(updateInfo.updates['extras'], isNotNull);
    });

    test('parseUpdateSMS should return null for non-update SMS', () {
      const bookingSMS =
          'TNSTC Corporation:SETC , PNR NO.:T12345678 ,'
          ' From:CHENNAI To BANGALORE';

      final updateInfo = service.parseUpdateSMS(bookingSMS);

      expect(updateInfo, isNull);
    });

    test(
      'parseUpdateSMS should handle update SMS with only conductor number',
      () {
        const conductorSMS =
            'TNSTC PNR:T12345678, Conductor Mobile No:9876543210';

        final updateInfo = service.parseUpdateSMS(conductorSMS);

        expect(updateInfo, isNotNull);
        expect(updateInfo!.pnrNumber, equals('T12345678'));
      },
    );

    test(
      'parseUpdateSMS should handle update SMS with only vehicle number',
      () {
        const vehicleSMS = 'TNSTC PNR:T12345678, Vehicle No:TN01AB1234';

        final updateInfo = service.parseUpdateSMS(vehicleSMS);

        expect(updateInfo, isNotNull);
        expect(updateInfo!.pnrNumber, equals('T12345678'));
      },
    );

    test('parseUpdateSMS should return null if PNR is missing', () {
      const invalidSMS =
          'TNSTC Conductor Mobile No:9876543210, Vehicle No:TN01AB1234';

      final updateInfo = service.parseUpdateSMS(invalidSMS);

      expect(updateInfo, isNull);
    });

    test('should list supported providers', () {
      final providers = service.getSupportedProviders();

      expect(providers, contains('TNSTC'));
      expect(providers, contains('IRCTC'));
      expect(providers, contains('SETC'));
    });

    test('should detect ticket text', () {
      const tnstcText = 'TNSTC Corporation:SETC , PNR NO.:T12345678';

      expect(service.isTicketText(tnstcText), isTrue);
    });

    test('should not detect non-ticket text', () {
      const randomText = 'Hello, this is a random message';

      expect(service.isTicketText(randomText), isFalse);
    });
  });
}
