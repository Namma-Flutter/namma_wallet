import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/application/parsers/konfhub_layout_parser.dart';
import '../../../../../fixtures/konfhub_layout_fixtures.dart';
import '../../../../../helpers/fake_logger.dart';

void main() {
  group('KonfHubLayoutParser', () {
    late KonfHubLayoutParser parser;
    late FakeLogger fakeLogger;
    final getIt = GetIt.instance;

    setUp(() {
      fakeLogger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(fakeLogger);
      }
      parser = KonfHubLayoutParser(logger: fakeLogger);
    });

    tearDown(getIt.reset);

    group('canParse', () {
      test('returns true for KonfHub keywords', () {
        expect(
          parser.canParse('konfhub\nEvent Name: xyz\nTicket Name: abc'),
          isTrue,
        );
        expect(
          parser.canParse(
            'Attendee Details\nEvent Name: xyz\nTicket Name: abc',
          ),
          isTrue,
        );
      });

      test('returns false for unrelated text', () {
        expect(parser.canParse('TNSTC PNR T123'), isFalse);
        expect(parser.canParse('BookMyShow ticket'), isFalse);
      });
    });

    group('parseTicketFromBlocks', () {
      test('parses devfest 2025 ticket', () async {
        final blocks = KonfHubLayoutFixtures.devfest2025;
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        const expected = KonfHubLayoutFixtures.devfest2025Expected;

        expect(ticket, isNotNull);
        expect(ticket!.ticketId, expected['bookingId']);
        expect(ticket.primaryText, expected['eventName']);
        expect(ticket.secondaryText, expected['ticketName']);
        expect(ticket.type, TicketType.event);
        expect(ticket.location, expected['location']);

        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime?.year, expected['eventYear']);
        expect(ticket.startTime?.month, expected['eventMonth']);
        expect(ticket.startTime?.day, expected['eventDay']);
        expect(ticket.startTime?.hour, expected['startHour']);
        expect(ticket.startTime?.minute, expected['startMinute']);

        expect(ticket.endTime, isNotNull);
        expect(ticket.endTime?.year, expected['eventYear']);
        expect(ticket.endTime?.month, expected['eventMonth']);
        expect(ticket.endTime?.day, expected['eventDay']);
        expect(ticket.endTime?.hour, expected['endHour']);
        expect(ticket.endTime?.minute, expected['endMinute']);

        final extrasMap = <String, String>{
          for (final e in ticket.extras ?? <ExtrasModel>[])
            if (e.title != null) e.title!: e.value ?? '',
        };

        expect(extrasMap['Booking ID'], expected['bookingId']);
        expect(extrasMap['Attendee'], expected['attendeeName']);
        expect(extrasMap['Organization'], expected['organization']);
        expect(extrasMap['Ticket Type'], expected['ticketName']);
      });

      test('returns null when critical fields are missing', () async {
        final blocks = [
          ...KonfHubLayoutFixtures.devfest2025.where(
            (b) => !b.text.contains('Event Name'),
          ),
        ];

        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        expect(ticket, isNull);
      });

      test(
        'returns null when explicit year is missing in date and event name',
        () async {
          final blocks = KonfHubLayoutFixtures.devfest2025.map((b) {
            if (b.text.contains('Event Name:')) {
              return b.copyWith(text: 'Event Name: DevFest');
            }
            if (b.text.contains('Event Date:')) {
              return b.copyWith(
                text: 'Event Date: November 08 (09:00 AM to 06:00 PM)',
              );
            }
            return b;
          }).toList();

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNull);
        },
      );

      test(
        'parses explicit year from eventDateRaw when absent in event name',
        () async {
          final blocks = KonfHubLayoutFixtures.devfest2025.map((b) {
            if (b.text.contains('Event Name:')) {
              return b.copyWith(text: 'Event Name: DevFest');
            }
            if (b.text.contains('Event Date:')) {
              return b.copyWith(
                text: 'Event Date: November 08 2026 (09:00 AM to 06:00 PM)',
              );
            }
            return b;
          }).toList();

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNotNull);
          expect(ticket!.startTime?.year, equals(2026));
        },
      );

      test(
        'leaves startTime and endTime null when time range is missing',
        () async {
          final blocks = KonfHubLayoutFixtures.devfest2025.map((b) {
            if (b.text.contains('Event Date:')) {
              return b.copyWith(text: 'Event Date: November 08 2025');
            }
            return b;
          }).toList();

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNotNull);
          expect(ticket!.startTime, isNull);
          expect(ticket.endTime, isNull);
        },
      );

      test(
        'leaves startTime and endTime null when time range is invalid',
        () async {
          final blocks = KonfHubLayoutFixtures.devfest2025.map((b) {
            if (b.text.contains('Event Date:')) {
              return b.copyWith(
                text: 'Event Date: November 08 2025 (invalid-time)',
              );
            }
            return b;
          }).toList();

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNotNull);
          expect(ticket!.startTime, isNull);
          expect(ticket.endTime, isNull);
        },
      );

      test(
        'returns null when calendar date is invalid',
        () async {
          final blocks = KonfHubLayoutFixtures.devfest2025.map((b) {
            if (b.text.contains('Event Date:')) {
              return b.copyWith(
                text: 'Event Date: February 31 2025 (09:00 AM to 06:00 PM)',
              );
            }
            return b;
          }).toList();

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNull);
        },
      );
    });
  });
}
