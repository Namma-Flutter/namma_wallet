import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/archive/ticket_archive.dart';

void main() {
  group('shouldArchiveTicket', () {
    final now = DateTime(2026, 4, 26, 12);

    Ticket ticketWith({DateTime? start, DateTime? end}) => Ticket(
      ticketId: 'T',
      primaryText: 'A → B',
      type: TicketType.bus,
      startTime: start,
      endTime: end,
    );

    test('returns false when both startTime and endTime are null', () {
      expect(shouldArchiveTicket(ticketWith(), now: now), isFalse);
    });

    test('uses endTime when both times are present', () {
      // startTime is in the past, endTime is in the future → not archived.
      final ticket = ticketWith(
        start: now.subtract(const Duration(hours: 2)),
        end: now.add(const Duration(hours: 1)),
      );
      expect(shouldArchiveTicket(ticket, now: now), isFalse);
    });

    test('archives when endTime is in the past', () {
      final ticket = ticketWith(
        start: now.subtract(const Duration(days: 1)),
        end: now.subtract(const Duration(hours: 1)),
      );
      expect(shouldArchiveTicket(ticket, now: now), isTrue);
    });

    test('falls back to startTime when endTime is null', () {
      final past = ticketWith(start: now.subtract(const Duration(minutes: 1)));
      final future = ticketWith(start: now.add(const Duration(minutes: 1)));
      expect(shouldArchiveTicket(past, now: now), isTrue);
      expect(shouldArchiveTicket(future, now: now), isFalse);
    });

    test('returns false when relevant time equals now (strictly before)', () {
      final atNowEnd = ticketWith(end: now);
      final atNowStart = ticketWith(start: now);
      expect(shouldArchiveTicket(atNowEnd, now: now), isFalse);
      expect(shouldArchiveTicket(atNowStart, now: now), isFalse);
    });

    test('archives when both start and end are in the past', () {
      final ticket = ticketWith(
        start: now.subtract(const Duration(days: 5)),
        end: now.subtract(const Duration(days: 4)),
      );
      expect(shouldArchiveTicket(ticket, now: now), isTrue);
    });

    test(
      'archives when endTime is past but startTime is future '
      '(endTime takes precedence)',
      () {
        final ticket = ticketWith(
          start: now.add(const Duration(days: 1)),
          end: now.subtract(const Duration(hours: 1)),
        );
        expect(shouldArchiveTicket(ticket, now: now), isTrue);
      },
    );

    test('uses current time when `now` is not provided', () {
      final farPast = ticketWith(
        start: DateTime(1990),
        end: DateTime(1991),
      );
      final farFuture = ticketWith(
        start: DateTime(9999),
        end: DateTime(9999, 12, 31),
      );
      expect(shouldArchiveTicket(farPast), isTrue);
      expect(shouldArchiveTicket(farFuture), isFalse);
    });
  });

  group('archivedTicketsLocation', () {
    test('returns the all-tickets path with archive query', () {
      expect(archivedTicketsLocation(), '/all-tickets?archive=1');
      expect(archivedTicketsLocation(), contains(archiveQueryKey));
      expect(archivedTicketsLocation(), contains(archiveQueryValue));
    });
  });
}
