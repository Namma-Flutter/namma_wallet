import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class SMSService {
  final ILogger _logger;
  final TNSTCSMSParser _smsParser;

  SMSService({ILogger? logger, TNSTCSMSParser? smsParser})
      : _logger = logger ?? getIt<ILogger>(),
        _smsParser = smsParser ?? getIt<TNSTCSMSParser>();

  TNSTCTicketModel parseTicket(String text) {
    try {
      _logger.logService('SMS', 'Parsing ticket from SMS text');
      final ticket = _smsParser.parseTicket(text);
      final pnr = ticket.pnrNumber;
      final pnrSuffix = pnr != null && pnr.length >= 4
          ? pnr.substring(pnr.length - 4)
          : 'N/A';
      _logger.logTicketParsing(
        'SMS',
        'Successfully parsed ticket with PNR: ***$pnrSuffix',
      );
      return ticket;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to parse SMS ticket',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
