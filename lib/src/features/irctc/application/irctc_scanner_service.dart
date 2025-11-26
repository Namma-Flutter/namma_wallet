import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_qr_parser_interface.dart';
import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service_interface.dart';
import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';

enum IRCTCScannerContentType {
  irctcTicket,
  invalid,
}

class IRCTCScannerResult {
  const IRCTCScannerResult({
    required this.type,
    required this.isSuccess,
    this.content,
    this.irctcTicket,
    this.travelTicket,
    this.errorMessage,
  });

  factory IRCTCScannerResult.success(
    IRCTCScannerContentType type,
    String content, {
    IRCTCTicket? irctcTicket,
    Ticket? travelTicket,
  }) {
    return IRCTCScannerResult(
      type: type,
      content: content,
      irctcTicket: irctcTicket,
      travelTicket: travelTicket,
      isSuccess: true,
    );
  }

  factory IRCTCScannerResult.error(String errorMessage) {
    return IRCTCScannerResult(
      type: IRCTCScannerContentType.invalid,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  final IRCTCScannerContentType type;
  final String? content;
  final IRCTCTicket? irctcTicket;
  final Ticket? travelTicket;
  final String? errorMessage;
  final bool isSuccess;
}

class IRCTCScannerService implements IIRCTCScannerService {
  IRCTCScannerService({
    required ILogger logger,
    required IIRCTCQRParser qrParser,
    required ITicketDAO ticketDao,
  }) : _logger = logger,
       _qrParser = qrParser,
       _ticketDao = ticketDao;

  final ILogger _logger;
  final IIRCTCQRParser _qrParser;
  final ITicketDAO _ticketDao;

  @override
  Future<IRCTCScannerResult> parseAndSaveIRCTCTicket(String qrData) async {
    try {
      // Check if this is IRCTC QR data
      if (!_qrParser.isIRCTCQRCode(qrData)) {
        return IRCTCScannerResult.error('Not a valid IRCTC QR code');
      }

      // Parse IRCTC ticket
      final irctcTicket = _qrParser.parseQRCode(qrData);
      if (irctcTicket == null) {
        return IRCTCScannerResult.error('Failed to parse IRCTC ticket data');
      }

      // Convert to travel ticket model for database storage
      final travelTicket = Ticket.fromIRCTC(irctcTicket);

      // Save to database
      try {
        await _ticketDao.insertTicket(travelTicket);

        return IRCTCScannerResult.success(
          IRCTCScannerContentType.irctcTicket,
          qrData,
          irctcTicket: irctcTicket,
          travelTicket: travelTicket,
        );
      } on Object catch (e, stackTrace) {
        _logger.error('Failed to save IRCTC ticket to database', e, stackTrace);
        return IRCTCScannerResult.error(
          'Failed to save ticket. Please try again.',
        );
      }
    } on Object catch (e, stackTrace) {
      _logger.error(
        'Unexpected exception in IRCTC scanner service',
        e,
        stackTrace,
      );
      return IRCTCScannerResult.error('Unexpected error. Please try again.');
    }
  }
}
