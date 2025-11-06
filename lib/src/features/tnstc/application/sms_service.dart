import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_service.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class SMSService {
  LoggerService get _logger => getIt<LoggerService>();

  TNSTCTicketModel parseTicket(String text) {
    try {
      _logger.logService('SMS', 'Parsing ticket from SMS text');
      final ticket = TNSTCSMSParser.parseTicket(text);
      _logger.logTicketParsing(
        'SMS',
        'Successfully parsed ticket with PNR: ${ticket.pnrNumber}',
      );
      return ticket;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to parse SMS ticket',
        e is Exception ? e : null,
        stackTrace,
      );
      rethrow;
    }
  }
}
