import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';

void main() {
  test('Ticket.mergeTickets should preserve journeyDate', () {
    final existing = Ticket(
      primaryText: 'Existing',
      secondaryText: 'Detail',
      location: 'Loc',
      journeyDate: DateTime(2026, 1, 1),
    );

    final incomingWithDate = Ticket(
      primaryText: 'Incoming',
      secondaryText: 'Detail',
      location: 'Loc',
      journeyDate: DateTime(2026, 1, 2),
    );

    final merged1 = Ticket.mergeTickets(existing, incomingWithDate);
    expect(merged1.journeyDate?.day, 2);

    const incomingWithoutDate = Ticket(
      primaryText: 'Incoming',
      secondaryText: 'Detail',
      location: 'Loc',
    );

    final merged2 = Ticket.mergeTickets(existing, incomingWithoutDate);
    expect(merged2.journeyDate?.day, 1);
  });
}
