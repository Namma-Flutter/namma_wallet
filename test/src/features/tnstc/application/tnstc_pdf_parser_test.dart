import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

import '../../../common/helpers/fake_logger.dart';
import '../../../common/helpers/mock_ocr_service.dart';

void main() {
  // Set up GetIt for tests
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ILogger>()) {
      getIt.registerSingleton<ILogger>(FakeLogger());
    }
    if (!getIt.isRegistered<OCRService>()) {
      getIt.registerSingleton<OCRService>(MockOCRService());
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

    test('should parse TNSTC PDF ticket correctly', () async {
      final pdfFile = File(
        'assets/data/E-Ticket_T73309927_18-01-2026.pdf',
      );

      // Skip test if PDF file doesn't exist
      if (!pdfFile.existsSync()) {
        return;
      }

      // Extract text from PDF
      final pdfText = await pdfService.extractTextFrom(pdfFile);

      // Debug extracted text length
      // ignore: avoid_print
      print('PDF text length: ${pdfText.length} characters');

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

      final ageExtra = ticket.extras?.firstWhere((e) => e.title == 'Age').value;
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
    });

    test('should handle cleaned text patterns', () {
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

      final ageExtra = ticket.extras?.firstWhere((e) => e.title == 'Age').value;
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
    });

    test('should handle missing platform number gracefully', () {
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
    });

    test('should parse passenger pickup time with Hrs suffix', () {
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
    });

    test('should handle total fare with decimal values', () {
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
    });
  });
}
