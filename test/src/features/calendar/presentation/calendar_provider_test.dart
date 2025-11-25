import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_view.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

import '../../../../helpers/fake_logger.dart';

// Fake implementations

class StubTicketDAO implements ITicketDAO {
  List<Ticket> tickets = [];

  @override
  Future<int> deleteTicket(String id) async => 0;

  @override
  Future<List<Ticket>> getAllTickets() async => tickets;

  @override
  Future<Ticket?> getTicketById(String id) async => null;

  @override
  Future<List<Ticket>> getTicketsByType(String type) async => [];

  @override
  Future<int> insertTicket(Ticket ticket) async => 0;

  @override
  Future<int> updateTicketById(
    String ticketId,
    Map<String, Object?> updates,
  ) async => 0;
}

void main() {
  late FakeLogger fakeLogger;
  late StubTicketDAO stubTicketDao;
  late CalendarProvider provider;

  setUp(() async {
    fakeLogger = FakeLogger();
    stubTicketDao = StubTicketDAO();

    // Setup locator
    await getIt.reset();
    getIt
      ..registerSingleton<ILogger>(fakeLogger)
      ..registerSingleton<ITicketDAO>(stubTicketDao);

    provider = CalendarProvider(logger: fakeLogger);
  });

  tearDown(getIt.reset);

  group('CalendarProvider Range Filtering', () {
    test(
      'getTicketsForRange filters correctly with inclusive bounds',
      () async {
        final rangeStart = DateTime(2023, 5, 10);
        final rangeEnd = DateTime(2023, 5, 20);
        final range = DateTimeRange(start: rangeStart, end: rangeEnd);

        final ticketInside = Ticket(
          ticketId: '1',
          primaryText: 'A -> B',
          secondaryText: 'Bus',
          location: 'A',
          startTime: DateTime(2023, 5, 15, 10),
          endTime: DateTime(2023, 5, 15, 12),
        );

        final ticketOnStart = Ticket(
          ticketId: '2',
          primaryText: 'A -> B',
          secondaryText: 'Bus',
          location: 'A',
          startTime: DateTime(2023, 5, 10, 23, 59),
          endTime: DateTime(2023, 5, 11, 1),
        );

        final ticketOnEnd = Ticket(
          ticketId: '3',
          primaryText: 'A -> B',
          secondaryText: 'Bus',
          location: 'A',
          startTime: DateTime(2023, 5, 20, 0, 1),
          endTime: DateTime(2023, 5, 20, 2),
        );

        final ticketBefore = Ticket(
          ticketId: '4',
          primaryText: 'A -> B',
          secondaryText: 'Bus',
          location: 'A',
          startTime: DateTime(2023, 5, 9, 23, 59),
          endTime: DateTime(2023, 5, 10, 1),
        );

        final ticketAfter = Ticket(
          ticketId: '5',
          primaryText: 'A -> B',
          secondaryText: 'Bus',
          location: 'A',
          startTime: DateTime(2023, 5, 21, 0, 1),
          endTime: DateTime(2023, 5, 21, 2),
        );

        stubTicketDao.tickets = [
          ticketInside,
          ticketOnStart,
          ticketOnEnd,
          ticketBefore,
          ticketAfter,
        ];

        await provider.loadTickets();
        final filteredTickets = provider.getTicketsForRange(range);

        expect(
          filteredTickets.map((t) => t.ticketId),
          containsAll(['1', '2', '3']),
        );
        expect(
          filteredTickets.map((t) => t.ticketId),
          isNot(contains('4')),
          reason: 'Ticket before start date should be excluded',
        );
        expect(
          filteredTickets.map((t) => t.ticketId),
          isNot(contains('5')),
          reason: 'Ticket after end date should be excluded',
        );
        expect(filteredTickets.length, 3);
      },
    );
  });
}
