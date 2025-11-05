import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

class SMSService {
  TNSTCTicketModel parseTicket(String text) {
    return TNSTCSMSParser.parseTicket(text);
  }
}
