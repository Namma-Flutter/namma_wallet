import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ocr/ocr_block.dart';
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
        expect(
          parser.canParse(
            'Booking ID: 870ef2aa\n'
            'Event Name: DevFest 2026\n'
            'Date & Time: Oct 17',
          ),
          isTrue,
        );
        expect(
          parser.canParse(
            'Booking ID: 870ef2aa\n'
            'Event Name: DevFest 2026\n'
            'Venue: IIT Madras',
          ),
          isTrue,
        );
        expect(
          parser.canParse(
            'Booking ID: cdda2c1f\n'
            'Event Name: DevFest 2025\n'
            'Event Date: Nov 08\n'
            'Location: IIT Madras',
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

      test('parses devfest 2026 ticket (new layout)', () async {
        final blocks = KonfHubLayoutFixtures.devfest2026;
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        const expected = KonfHubLayoutFixtures.devfest2026Expected;

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
        expect(extrasMap['Add-ons'], expected['addOns']);
        expect(
          extrasMap['Additional Venue Details'],
          expected['additionalVenueDetails'],
        );

        final tagValues = ticket.tags?.map((t) => t.value).toList();
        expect(tagValues, contains(expected['attendeeName']));
        expect(tagValues, contains(expected['ticketName']));
      });

      test('parses Flutter South India 2026 ticket', () async {
        final blocks = KonfHubLayoutFixtures.flutterSouthIndia2026;
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        const expected = KonfHubLayoutFixtures.flutterSouthIndia2026Expected;

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
        expect(extrasMap['Ticket Type'], expected['ticketName']);

        final tagValues = ticket.tags?.map((t) => t.value).toList();
        expect(tagValues, contains(expected['attendeeName']));
        expect(tagValues, contains(expected['ticketName']));
      });

      test(
        'correctly parses attendee and ticket when booking id and date are '
        'separate blocks',
        () async {
          final blocks = <OCRBlock>[
            OCRBlock(
              text: 'Booking ID:',
              boundingBox: const Rect.fromLTRB(100, 20, 150, 40),
              page: 0,
            ),
            OCRBlock(
              text: '870ef2aa',
              boundingBox: const Rect.fromLTRB(160, 20, 200, 40),
              page: 0,
            ),
            OCRBlock(
              text: 'Booking Date:',
              boundingBox: const Rect.fromLTRB(100, 40, 150, 60),
              page: 0,
            ),
            OCRBlock(
              text: 'Sep 06, 2026',
              boundingBox: const Rect.fromLTRB(160, 40, 200, 60),
              page: 0,
            ),
            OCRBlock(
              text: 'Professional - IDC Exclusive',
              boundingBox: const Rect.fromLTRB(0, 60, 100, 80),
              page: 0,
            ),
            OCRBlock(
              text: 'Keerthivasan S',
              boundingBox: const Rect.fromLTRB(0, 100, 100, 120),
              page: 0,
            ),
            OCRBlock(
              text: 'Thiran Technologies',
              boundingBox: const Rect.fromLTRB(0, 140, 100, 160),
              page: 0,
            ),
            OCRBlock(
              text: 'Event Name',
              boundingBox: const Rect.fromLTRB(0, 180, 100, 200),
              page: 0,
            ),
            OCRBlock(
              text: 'DevFest 2026 Chennai',
              boundingBox: const Rect.fromLTRB(0, 220, 100, 240),
              page: 0,
            ),
            OCRBlock(
              text: 'Date & Time',
              boundingBox: const Rect.fromLTRB(0, 260, 100, 280),
              page: 0,
            ),
            OCRBlock(
              text: 'Oct 17, 2026 (08:30 AM to 6PM IST)',
              boundingBox: const Rect.fromLTRB(0, 300, 100, 320),
              page: 0,
            ),
          ];

          final ticket = await parser.parseTicketFromBlocks(blocks, '');
          expect(ticket, isNotNull);
          expect(ticket!.ticketId, '870ef2aa');
          expect(ticket.secondaryText, 'Professional - IDC Exclusive');
          expect(
            ticket.tags?.map((t) => t.value),
            containsAll(['Keerthivasan S', 'Professional - IDC Exclusive']),
          );
          final extrasMap = <String, String>{
            for (final e in ticket.extras ?? <ExtrasModel>[])
              if (e.title != null) e.title!: e.value ?? '',
          };
          expect(extrasMap['Attendee'], 'Keerthivasan S');
          expect(extrasMap['Organization'], 'Thiran Technologies');
          expect(extrasMap['Ticket Type'], 'Professional - IDC Exclusive');
        },
      );

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
