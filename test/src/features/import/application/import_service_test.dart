import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
import 'package:namma_wallet/src/common/services/pdf/pdf_service_interface.dart';
import 'package:namma_wallet/src/features/import/application/import_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';
import 'package:namma_wallet/src/features/travel/application/pkpass_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/domain/ticket_update_info.dart';

import '../../../../helpers/fake_logger.dart';

class FakePDFService implements IPDFService {
  String? extractedText;
  List<OCRBlock>? extractedBlocks;

  @override
  Future<String> extractTextForDisplay(XFile file) async {
    return extractedText ?? '';
  }

  @override
  Future<String> extractTextFrom(XFile file) => extractTextForDisplay(file);

  @override
  Future<List<OCRBlock>> extractBlocks(XFile file) async {
    // If blocks are provided, return them
    if (extractedBlocks != null) return extractedBlocks!;

    // Otherwise, convert text to pseudo-blocks
    return OCRBlock.fromPlainText(extractedText ?? '');
  }

  @override
  Future<Map<String, dynamic>> extractStructuredData(XFile file) async {
    return {};
  }
}

class FakeTravelParser implements ITravelParser {
  Ticket? parsedTicket;

  @override
  Ticket? parseTicketFromBlocks(
    List<OCRBlock> blocks, {
    SourceType? sourceType,
  }) {
    return parsedTicket;
  }

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

class FakePKPassParser implements IPKPassParser {
  Ticket? parsedTicket;

  @override
  Future<Ticket?> parsePKPass(Uint8List data) async {
    return parsedTicket;
  }

  @override
  Future<Uint8List?> fetchLatestPass(
    Uint8List currentPassData, {
    DateTime? modifiedSince,
  }) async {
    return null;
  }
}

class FakeTicketDAO implements ITicketDAO {
  Ticket? handledTicket;
  bool shouldThrowError = false;

  @override
  Future<int> handleTicket(Ticket ticket) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    handledTicket = ticket;
    return 1;
  }

  @override
  Future<int> insertTicket(Ticket ticket) async {
    return handleTicket(ticket);
  }

  @override
  Future<int> updateTicketById(String id, Ticket ticket) async {
    handledTicket = ticket;
    return 1;
  }

  @override
  Future<List<Ticket>> getAllTickets() async => [];

  @override
  Future<Ticket?> getTicketById(String id) async => null;

  @override
  Future<int> deleteTicket(String id) async => 1;

  @override
  Future<List<Ticket>> getTicketsByType(String type) async => [];
}

void main() {
  group('ImportService', () {
    late ImportService importService;
    late FakeLogger fakeLogger;
    late FakePDFService fakePDFService;
    late FakeTravelParser fakeTravelParser;
    late FakeIRCTCQRParser fakeIRCTCQRParser;
    late FakeIRCTCScannerService fakeIRCTCScannerService;
    late FakePKPassParser fakePKPassParser;
    late FakeTicketDAO fakeTicketDAO;

    setUp(() {
      fakeLogger = FakeLogger();
      fakePDFService = FakePDFService();
      fakeTravelParser = FakeTravelParser();
      fakeIRCTCQRParser = FakeIRCTCQRParser();
      fakeIRCTCScannerService = FakeIRCTCScannerService();
      fakePKPassParser = FakePKPassParser();
      fakeTicketDAO = FakeTicketDAO();
      importService = ImportService(
        logger: fakeLogger,
        pdfService: fakePDFService,
        travelParser: fakeTravelParser,
        qrParser: fakeIRCTCQRParser,
        irctcScannerService: fakeIRCTCScannerService,
        pkpassParser: fakePKPassParser,
        ticketDao: fakeTicketDAO,
      );
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

    group('importAndSavePKPassFile', () {
      const testPKPassPath = 'test/assets/pkpass/Flutter Devcon.pkpass';

      test('should return empty result when ticket cannot be parsed', () async {
        fakePKPassParser.parsedTicket = null;
        final result = await importService.importAndSavePKPassFile(
          XFile(testPKPassPath),
        );
        expect(result.ticket, isNull);
        expect(result.warning, isNull);
      });

      test('should return warning when provider is not Luma', () async {
        final nonLumaTicket = testTicket.copyWith(
          extras: [ExtrasModel(title: 'Provider', value: 'Other')],
        );
        fakePKPassParser.parsedTicket = nonLumaTicket;

        final result = await importService.importAndSavePKPassFile(
          XFile(testPKPassPath),
        );

        expect(result.ticket, nonLumaTicket);
        expect(result.warning, equals('Imported pass is not from Luma'));
        expect(fakeTicketDAO.handledTicket, nonLumaTicket);
      });

      test('should return no warning when provider contains Luma', () async {
        final lumaTicket = testTicket.copyWith(
          extras: [ExtrasModel(title: 'Provider', value: 'Luma Events')],
        );
        fakePKPassParser.parsedTicket = lumaTicket;

        final result = await importService.importAndSavePKPassFile(
          XFile(testPKPassPath),
        );

        expect(result.ticket, lumaTicket);
        expect(result.warning, isNull);
        expect(fakeTicketDAO.handledTicket, lumaTicket);
      });

      test('should return warning when provider is missing', () async {
        final noProviderTicket = testTicket.copyWith(extras: []);
        fakePKPassParser.parsedTicket = noProviderTicket;

        final result = await importService.importAndSavePKPassFile(
          XFile(testPKPassPath),
        );

        expect(result.ticket, noProviderTicket);
        expect(result.warning, equals('Imported pass is not from Luma'));
      });

      test(
        'should return null ticket result when an exception occurs',
        () async {
          fakePKPassParser.parsedTicket = testTicket;
          fakeTicketDAO.shouldThrowError = true;
          final result = await importService.importAndSavePKPassFile(
            XFile(testPKPassPath),
          );
          expect(result.ticket, isNull);
        },
      );
    });
  });
}
