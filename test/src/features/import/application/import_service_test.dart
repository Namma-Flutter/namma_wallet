import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';

import '../../../../helpers/fake_logger.dart';

class FakePDFService implements IPDFService {
  String? extractedText;

  @override
  Future<String> extractTextFrom(File file) async {
    return extractedText ?? '';
  }
}

class FakeTravelParser implements ITravelParser {
  Ticket? parsedTicket;

  @override
  Ticket? parseTicketFromText(String text, {SourceType? sourceType}) {
    return parsedTicket;
  }

  @override
  TicketUpdateInfo? parseUpdateSMS(String content) {
    return null;
  }
}

class FakeIRCTCQRParser implements IIRCTCQRParser {
  bool isIRCTC = false;
  IRCTCTicket? parsedTicket;

  @override
  bool isIRCTCQRCode(String qrData) {
    return isIRCTC;
  }

  @override
  IRCTCTicket? parseQRCode(String qrData) {
    return parsedTicket;
  }
}

class FakeIRCTCScannerService implements IIRCTCScannerService {
  IRCTCScannerResult? scanResult;
  bool shouldThrow = false;

  @override
  Future<IRCTCScannerResult> parseAndSaveIRCTCTicket(String qrData) async {
    if (shouldThrow) {
      throw Exception('Scanner error');
    }
    return scanResult ?? IRCTCScannerResult.error('Default error');
  }
}

class FakeTicketDAO implements ITicketDAO {
  Ticket? insertedTicket;
  bool shouldThrowError = false;

  @override
  Future<int> insertTicket(Ticket ticket) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    insertedTicket = ticket;
    return 1;
  }

  @override
  Future<List<Ticket>> getAllTickets() async {
    return [];
  }

  @override
  Future<Ticket?> getTicketById(String id) async {
    return null;
  }

  @override
  Future<int> deleteTicket(String id) async {
    return 1;
  }

  @override
  Future<List<Ticket>> getTicketsByType(String type) async {
    return [];
  }

  @override
  Future<int> updateTicketById(String id, Map<String, Object?> data) async {
    return 1;
  }
}

void main() {
  group('ImportService', () {
    late ImportService importService;
    late FakeLogger fakeLogger;
    late FakePDFService fakePDFService;
    late FakeTravelParser fakeTravelParser;
    late FakeIRCTCQRParser fakeIRCTCQRParser;
    late FakeIRCTCScannerService fakeIRCTCScannerService;
    late FakeTicketDAO fakeTicketDAO;

    setUp(() {
      fakeLogger = FakeLogger();
      fakePDFService = FakePDFService();
      fakeTravelParser = FakeTravelParser();
      fakeIRCTCQRParser = FakeIRCTCQRParser();
      fakeIRCTCScannerService = FakeIRCTCScannerService();
      fakeTicketDAO = FakeTicketDAO();
      importService = ImportService(
        logger: fakeLogger,
        pdfService: fakePDFService,
        travelParser: fakeTravelParser,
        qrParser: fakeIRCTCQRParser,
        irctcScannerService: fakeIRCTCScannerService,
        ticketDao: fakeTicketDAO,
      );
    });

    tearDown(() {
      // Reset exception throwing flags
      fakeIRCTCScannerService.shouldThrow = false;
      fakeTicketDAO.shouldThrowError = false;
    });

    final testIrctcTicket = IRCTCTicket(
      pnrNumber: '1234567890',
      trainNumber: '12345',
      trainName: 'Test Express',
      fromStation: 'START',
      toStation: 'END',
      boardingStation: 'START',
      dateOfJourney: DateTime(2025, 1, 15, 10),
      scheduledDeparture: DateTime(2025, 1, 15, 11),
      passengerName: 'Test Passenger',
      age: 30,
      gender: 'M',
      travelClass: 'AC',
      quota: 'GN',
      status: 'CNF',
      ticketFare: 1000,
      irctcFee: 50,
      transactionId: 'txn123',
    );

    final testTicket = Ticket.fromIRCTC(testIrctcTicket);

    group('supportedExtensions', () {
      test('should return a list containing only "pdf"', () {
        expect(importService.supportedExtensions, ['pdf']);
      });
    });

    group('isSupportedQRCode', () {
      test('should return true if QR parser supports it', () {
        // Arrange
        fakeIRCTCQRParser.isIRCTC = true;
        // Act
        final result = importService.isSupportedQRCode('some-data');
        // Assert
        expect(result, isTrue);
      });

      test('should return false if QR parser does not support it', () {
        // Arrange
        fakeIRCTCQRParser.isIRCTC = false;
        // Act
        final result = importService.isSupportedQRCode('some-data');
        // Assert
        expect(result, isFalse);
      });
    });

    group('importAndSavePDFFile', () {
      final testPdfFile = File('test.pdf');

      test('should return null when no text is extracted', () async {
        // Arrange
        fakePDFService.extractedText = '';
        // Act
        final result = await importService.importAndSavePDFFile(testPdfFile);
        // Assert
        expect(result, isNull);
      });

      test('should return null when ticket cannot be parsed', () async {
        // Arrange
        fakePDFService.extractedText = 'some text';
        fakeTravelParser.parsedTicket = null;
        // Act
        final result = await importService.importAndSavePDFFile(testPdfFile);
        // Assert
        expect(result, isNull);
      });

      test('should save and return ticket on successful import', () async {
        // Arrange
        fakePDFService.extractedText = 'some text';
        fakeTravelParser.parsedTicket = testTicket;
        // Act
        final result = await importService.importAndSavePDFFile(testPdfFile);
        // Assert
        expect(result, testTicket);
        expect(fakeTicketDAO.insertedTicket, testTicket);
      });

      test(
        'should return null and log error when an exception occurs',
        () async {
          // Arrange
          fakePDFService.extractedText = 'some text';
          fakeTravelParser.parsedTicket = testTicket;
          fakeTicketDAO.shouldThrowError = true;
          // Act
          final result = await importService.importAndSavePDFFile(testPdfFile);
          // Assert
          expect(result, isNull);
          expect(fakeLogger.errorLogs, isNotEmpty);
        },
      );
    });

    group('importQRCode', () {
      const qrData = 'some-qr-data';
      test('should return null for unsupported QR code format', () async {
        // Arrange
        fakeIRCTCQRParser.isIRCTC = false;
        // Act
        final result = await importService.importQRCode(qrData);
        // Assert
        expect(result, isNull);
      });

      test('should return null when IRCTC scanner service fails', () async {
        // Arrange
        fakeIRCTCQRParser.isIRCTC = true;
        fakeIRCTCScannerService.scanResult = IRCTCScannerResult.error(
          'Scan failed',
        );
        // Act
        final result = await importService.importQRCode(qrData);
        // Assert
        expect(result, isNull);
      });

      test('should return ticket on successful QR code import', () async {
        // Arrange
        fakeIRCTCQRParser.isIRCTC = true;
        fakeIRCTCScannerService.scanResult = IRCTCScannerResult.success(
          IRCTCScannerContentType.irctcTicket,
          qrData,
          travelTicket: testTicket,
          irctcTicket: testIrctcTicket,
        );
        // Act
        final result = await importService.importQRCode(qrData);
        // Assert
        expect(result, testTicket);
      });

      test(
        'should return null and log error when an exception occurs',
        () async {
          // Arrange
          fakeIRCTCQRParser.isIRCTC = true;
          // Force an exception in the scanner service
          fakeIRCTCScannerService.shouldThrow = true;
          // Act
          final result = await importService.importQRCode(qrData);
          // Assert
          expect(result, isNull);
          expect(fakeLogger.errorLogs, isNotEmpty);
          expect(
            fakeLogger.errorLogs.first,
            contains('Error importing QR code'),
          );
        },
      );
    });
  });
}
