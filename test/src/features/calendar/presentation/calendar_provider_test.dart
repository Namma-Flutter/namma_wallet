import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_provider.dart';

import '../../../../helpers/fake_logger.dart';

// Fake implementations

class StubTicketDAO implements ITicketDAO {
  List<Ticket> tickets = [];

  @override
  Future<int> handleTicket(Ticket ticket) async => 0;

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
    Ticket ticket, // Updated from Map to Ticket
  ) async => 0;

  @override
  Future<List<Ticket>> getActiveTickets() async => tickets;

  @override
  Future<List<Ticket>> getArchivedTickets() async => [];

  @override
  Future<int> archivePastTickets() async => 0;

  @override
  Future<int> purgeOldArchivedTickets({int retentionDays = 30}) async => 0;
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

  group('CalendarProvider single-day operations', () {
    Ticket ticketAt(String id, DateTime when) => Ticket(
      ticketId: id,
      primaryText: 'A → B',
      secondaryText: 'Bus',
      location: 'A',
      startTime: when,
    );

    test('setSelectedDay updates the selected day and clears range', () {
      provider
        ..setSelectedRange(
          DateTimeRange(
            start: DateTime(2024),
            end: DateTime(2024, 1, 5),
          ),
        )
        ..setSelectedDay(DateTime(2024, 6, 15));

      expect(provider.selectedDay, DateTime(2024, 6, 15));
      expect(provider.selectedRange, isNull);
    });

    test('setSelectedRange aligns selectedDay to range start', () {
      final range = DateTimeRange(
        start: DateTime(2024, 6, 10),
        end: DateTime(2024, 6, 20),
      );

      provider.setSelectedRange(range);

      expect(provider.selectedRange, equals(range));
      expect(provider.selectedDay, DateTime(2024, 6, 10));
    });

    test('setSelectedRange(null) leaves selectedDay alone', () {
      provider
        ..setSelectedDay(DateTime(2024, 6, 15))
        ..setSelectedRange(null);

      expect(provider.selectedRange, isNull);
      expect(provider.selectedDay, DateTime(2024, 6, 15));
    });

    test('getTicketsForDay only returns tickets matching the day', () async {
      final day = DateTime(2024, 6, 15);
      stubTicketDao.tickets = [
        ticketAt('A', DateTime(2024, 6, 15, 10)),
        ticketAt('B', DateTime(2024, 6, 15, 23, 59)),
        ticketAt('C', DateTime(2024, 6, 16)),
      ];
      await provider.loadTickets();

      final hits = provider.getTicketsForDay(day);
      expect(hits.map((t) => t.ticketId), containsAll(['A', 'B']));
      expect(hits.map((t) => t.ticketId), isNot(contains('C')));
    });

    test('getTicketsForDay skips tickets without startTime', () async {
      stubTicketDao.tickets = [
        const Ticket(ticketId: 'NO_TIME', primaryText: 'No time'),
      ];
      await provider.loadTickets();

      expect(provider.getTicketsForDay(DateTime(2024, 6, 15)), isEmpty);
    });

    test('hasTicketsOnDay reflects getTicketsForDay', () async {
      stubTicketDao.tickets = [ticketAt('A', DateTime(2024, 6, 15))];
      await provider.loadTickets();

      expect(provider.hasTicketsOnDay(DateTime(2024, 6, 15)), isTrue);
      expect(provider.hasTicketsOnDay(DateTime(2024, 6, 16)), isFalse);
    });

    test(
      'getDatesWithTickets de-duplicates by date and skips null start times',
      () async {
        stubTicketDao.tickets = [
          ticketAt('A', DateTime(2024, 6, 15, 10)),
          ticketAt('B', DateTime(2024, 6, 15, 22)),
          ticketAt('C', DateTime(2024, 6, 16)),
          const Ticket(ticketId: 'NO_TIME'),
        ];
        await provider.loadTickets();

        expect(
          provider.getDatesWithTickets(),
          unorderedEquals([DateTime(2024, 6, 15), DateTime(2024, 6, 16)]),
        );
      },
    );

    test(
      'getEventsForDay / getEventsForRange return empty by default',
      () async {
        await provider.loadEvents();
        expect(provider.events, isEmpty);
        expect(provider.getEventsForDay(DateTime(2024, 6, 15)), isEmpty);
        expect(
          provider.getEventsForRange(
            DateTimeRange(start: DateTime(2024), end: DateTime(2024, 12, 31)),
          ),
          isEmpty,
        );
      },
    );
  });

  group('CalendarProvider error handling', () {
    test(
      'loadTickets sets errorMessage when DAO throws',
      () async {
        stubTicketDao.tickets = [];

        final throwing = _ThrowingTicketDao();
        await getIt.reset();
        getIt
          ..registerSingleton<ILogger>(fakeLogger)
          ..registerSingleton<ITicketDAO>(throwing);
        provider = CalendarProvider(logger: fakeLogger);

        await provider.loadTickets();

        expect(provider.errorMessage, contains('Failed to load tickets'));
        expect(provider.tickets, isEmpty);
      },
    );
  });
}

class _ThrowingTicketDao extends StubTicketDAO {
  @override
  Future<List<Ticket>> getAllTickets() async {
    throw Exception('db down');
  }
}
