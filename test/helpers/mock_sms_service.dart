import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/application/sms_service.dart';

/// Mock SMSService for testing purposes
class MockSMSService extends SMSService {
  MockSMSService({
    Ticket? mockTicket,
  }) : _mockTicket =
           mockTicket ??
           Ticket(
             ticketId: 'TEST123',
             primaryText: 'Chennai → Bangalore',
             secondaryText: 'SETC - Trip123',
             startTime: DateTime(2024, 12, 15, 14, 30),
             location: 'Chennai',
           );

  final Ticket _mockTicket;

  @override
  Ticket parseTicket(String content) {
    return _mockTicket;
  }
}
