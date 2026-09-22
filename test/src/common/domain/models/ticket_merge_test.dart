import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';

void main() {
  group('Ticket.mergeTickets - originalFilePath', () {
    test('keeps incoming originalFilePath when present', () {
      const existing = Ticket(
        ticketId: 'PNR1',
        type: TicketType.bus,
        originalFilePath: '/docs/ticket_originals/old.pdf',
      );
      const incoming = Ticket(
        ticketId: 'PNR1',
        type: TicketType.bus,
        originalFilePath: '/docs/ticket_originals/new.pdf',
      );

      final merged = Ticket.mergeTickets(existing, incoming);

      expect(merged.originalFilePath, '/docs/ticket_originals/new.pdf');
    });

    test('falls back to existing originalFilePath when incoming has none', () {
      const existing = Ticket(
        ticketId: 'PNR1',
        type: TicketType.bus,
        originalFilePath: '/docs/ticket_originals/old.pdf',
      );
      const incoming = Ticket(ticketId: 'PNR1', type: TicketType.bus);

      final merged = Ticket.mergeTickets(existing, incoming);

      expect(merged.originalFilePath, '/docs/ticket_originals/old.pdf');
    });
  });
}
