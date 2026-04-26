import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';

import '../../../../helpers/fake_logger.dart';
import '../../../../helpers/mock_ticket_dao.dart';

class _StubQRParser implements IIRCTCQRParser {
  _StubQRParser({required this.isIrctc, this.parsed});
  final bool isIrctc;
  final IRCTCTicket? parsed;

  @override
  bool isIRCTCQRCode(String qrData) => isIrctc;

  @override
  IRCTCTicket? parseQRCode(String qrData) => parsed;
}

class _ThrowingTicketDao extends MockTicketDAO {
  @override
  Future<int> insertTicket(_) async {
    throw Exception('db down');
  }
}

void main() {
  group('IRCTCScannerService.parseAndSaveIRCTCTicket', () {
    test('returns error when the QR is not an IRCTC code', () async {
      final service = IRCTCScannerService(
        logger: FakeLogger(),
        qrParser: _StubQRParser(isIrctc: false),
        ticketDao: MockTicketDAO(),
      );

      final result = await service.parseAndSaveIRCTCTicket('hi');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Not a valid IRCTC'));
    });

    test('returns error when the parser cannot decode the QR', () async {
      final service = IRCTCScannerService(
        logger: FakeLogger(),
        qrParser: _StubQRParser(isIrctc: true),
        ticketDao: MockTicketDAO(),
      );

      final result = await service.parseAndSaveIRCTCTicket('PNR No.:1');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Failed to parse'));
    });

    test('returns success and saves the ticket on the happy path', () async {
      final dao = MockTicketDAO();
      const irctc = IRCTCTicket(
        pnrNumber: '1234567890',
        trainNumber: '12345',
        trainName: 'Test',
        fromStation: 'A',
        toStation: 'B',
      );
      final service = IRCTCScannerService(
        logger: FakeLogger(),
        qrParser: _StubQRParser(isIrctc: true, parsed: irctc),
        ticketDao: dao,
      );

      final result = await service.parseAndSaveIRCTCTicket('PNR No.:1');

      expect(result.isSuccess, isTrue);
      expect(result.irctcTicket, equals(irctc));
      expect(result.travelTicket?.ticketId, '1234567890');
      expect(dao.insertedTickets, hasLength(1));
    });

    test('returns error when the DAO insert fails', () async {
      const irctc = IRCTCTicket(
        pnrNumber: '1234567890',
        trainNumber: '12345',
        fromStation: 'A',
        toStation: 'B',
      );
      final service = IRCTCScannerService(
        logger: FakeLogger(),
        qrParser: _StubQRParser(isIrctc: true, parsed: irctc),
        ticketDao: _ThrowingTicketDao(),
      );

      final result = await service.parseAndSaveIRCTCTicket('PNR No.:1');

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('Failed to save'));
    });
  });
}
