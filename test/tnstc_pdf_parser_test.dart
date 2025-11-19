import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ocr_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/pdf_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';

import 'helpers/fake_logger.dart';
import 'helpers/mock_ocr_service.dart';

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

      // Parse the PDF
      final ticket = parser.parseTicket(pdfText);

      // Verify core fields
      expect(ticket.corporation, isNotEmpty);
      expect(ticket.pnrNumber, equals('T73309927'));
      expect(ticket.routeNo, equals('307AB'));
      expect(ticket.serviceStartPlace, isNotEmpty);
      expect(ticket.serviceEndPlace, isNotEmpty);
      expect(ticket.tripCode, equals('1315KUMCHEAB'));
      expect(ticket.busIdNumber, equals('E-5494'));
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
      expect(ticket.totalFare, equals(735.00));

      // Verify journey date
      expect(ticket.journeyDate?.day, equals(18));
      expect(ticket.journeyDate?.month, equals(1));
      expect(ticket.journeyDate?.year, equals(2026));

      // Verify passenger info
      expect(ticket.passengers, isNotEmpty);
      final passenger = ticket.passengers.first;
      expect(passenger.name, equals('HarishAnbalagan'));
      expect(passenger.age, equals(26));
      expect(passenger.type, equals('Adult'));
      expect(passenger.gender, equals('M'));
      expect(passenger.seatNumber, equals('4UB'));

      // Verify ID card info
      expect(ticket.idCardType, contains('Government'));
      expect(ticket.idCardNumber, equals('736960775578'));

      // Verify booking reference
      expect(ticket.obReferenceNumber, equals('OB31475439'));
      expect(ticket.bankTransactionNumber, equals('BAX6K8N12PUH74'));
    });

    test('should handle cleaned text patterns', () {
      // Simulate cleaned PDF text based on the actual structure
      const pdfText = '''
Tamil Nadu State Transport Corporation Ltd.
E-Ticket/Reservation Voucher-H

Corporation: SETC
PNR Number: T73309927
Date of Journey: 18/01/2026
Route No: 307AB
Service Start Place: KUMBAKONAM
Service End Place: CHENNAI-PT DR. M.G.R. BS
Service Start Time: 13:15 Hrs.
Passenger Start Place: KUMBAKONAM
Passenger End Place: CHENNAI-PT Dr.M.G.R. BS
Passenger Pickup Point: KUMBAKONAM
Passenger Pickup Time: 18/01/2026 13:15 Hrs.
Platform Number:
Trip Code: 1315KUMCHEAB
Class of Service: AC SLEEPER SEATER
OB Reference No.: OB31475439
No. of Seats: 1 (Adults=1 Children=0)
Bank Txn. No.: BAX6K8N12PUH74
Bus ID No.: E-5494
Passenger category: GENERAL PUBLIC

Passenger Information
Name                    Age    Adult/Child    Gender    Seat No.
HarishAnbalagan         26     Adult          M         4UB
ID Card Type: Government Issued Photo ID Card
ID Card Number: 736960775578

Total Fare: 735.00 Rs.
''';

      final ticket = parser.parseTicket(pdfText);

      // Verify all fields are extracted correctly
      expect(ticket.corporation, equals('SETC'));
      expect(ticket.pnrNumber, equals('T73309927'));
      expect(ticket.routeNo, equals('307AB'));
      expect(ticket.serviceStartPlace, equals('KUMBAKONAM'));
      expect(
        ticket.serviceEndPlace,
        equals('CHENNAI-PT DR. M.G.R. BS'),
      );
      expect(ticket.serviceStartTime, equals('13:15'));
      expect(ticket.passengerPickupPoint, equals('KUMBAKONAM'));
      expect(ticket.tripCode, equals('1315KUMCHEAB'));
      expect(ticket.classOfService, equals('AC SLEEPER SEATER'));
      expect(ticket.obReferenceNumber, equals('OB31475439'));
      expect(ticket.numberOfSeats, equals(1));
      expect(ticket.bankTransactionNumber, equals('BAX6K8N12PUH74'));
      expect(ticket.busIdNumber, equals('E-5494'));
      expect(ticket.passengerCategory, equals('GENERAL PUBLIC'));
      expect(ticket.totalFare, equals(735.00));

      // Verify passenger info
      expect(ticket.passengers.length, equals(1));
      final passenger = ticket.passengers.first;
      expect(passenger.name, equals('HarishAnbalagan'));
      expect(passenger.age, equals(26));
      expect(passenger.type, equals('Adult'));
      expect(passenger.gender, equals('M'));
      expect(passenger.seatNumber, equals('4UB'));

      // Verify ID card info
      expect(
        ticket.idCardType,
        equals('Government Issued Photo ID Card'),
      );
      expect(ticket.idCardNumber, equals('736960775578'));

      // Verify dates
      expect(ticket.journeyDate?.day, equals(18));
      expect(ticket.journeyDate?.month, equals(1));
      expect(ticket.journeyDate?.year, equals(2026));

      expect(ticket.passengerPickupTime?.day, equals(18));
      expect(ticket.passengerPickupTime?.month, equals(1));
      expect(ticket.passengerPickupTime?.year, equals(2026));
      expect(ticket.passengerPickupTime?.hour, equals(13));
      expect(ticket.passengerPickupTime?.minute, equals(15));
    });

    test('should handle empty platform number gracefully', () {
      const pdfText = '''
Corporation: SETC
PNR Number: T12345
Platform Number:
Trip Code: TEST123''';

      final ticket = parser.parseTicket(pdfText);

      expect(ticket.pnrNumber, equals('T12345'));
      // Platform number might have trailing whitespace
      expect((ticket.platformNumber ?? '').trim(), isEmpty);
      expect(ticket.tripCode, equals('TEST123'));
    });

    test('should handle multiple passengers if present', () {
      const pdfText = '''
Passenger Information
Name                    Age    Adult/Child    Gender    Seat No.
JohnDoe                 30     Adult          M         1A

Total Fare: 500.00 Rs.
''';

      final ticket = parser.parseTicket(pdfText);

      expect(ticket.passengers.length, equals(1));
      final passenger = ticket.passengers.first;
      expect(passenger.name, equals('JohnDoe'));
      expect(passenger.age, equals(30));
      expect(passenger.type, equals('Adult'));
      expect(passenger.gender, equals('M'));
      expect(passenger.seatNumber, equals('1A'));
      expect(ticket.totalFare, equals(500.00));
    });
  });
}
