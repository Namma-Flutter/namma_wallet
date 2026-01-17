import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

void main() {
  test('Ticket.fromTNSTC should combine journeyDate and serviceStartTime', () {
    final model = TNSTCTicketModel(
      journeyDate: DateTime(2026, 1, 18),
      serviceStartTime: '13:15',
      pnrNumber: 'T123456',
      corporation: 'SETC',
      routeNo: '123',
    );

    final ticket = Ticket.fromTNSTC(model);

    // Expect startTime to be 2026-01-18 13:15:00
    expect(ticket.startTime?.year, 2026);
    expect(ticket.startTime?.month, 1);
    expect(ticket.startTime?.day, 18);
    expect(ticket.startTime?.hour, 13);
    expect(ticket.startTime?.minute, 15);
  });

  test('Ticket should preserve journeyDate during serialization', () {
    final originalTicket = Ticket(
      primaryText: 'Chennai -> Bangalore',
      secondaryText: 'Train',
      location: 'Chennai',
      journeyDate: DateTime(2026, 1, 18),
    );

    final map = originalTicket.toMap();
    final reconstructedTicket = TicketMapper.fromMap(map);

    expect(reconstructedTicket.journeyDate, isNotNull);
    final localDate = reconstructedTicket.journeyDate?.toLocal();

    expect(localDate?.year, 2026);
    expect(localDate?.month, 1);
    expect(localDate?.day, 18);
  });
}
