import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/application/movie_layout_parser.dart';
import '../../../../fixtures/district_layout_fixtures.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  group('DistrictMovieParser', () {
    late DistrictMovieParser parser;
    late FakeLogger fakeLogger;
    final getIt = GetIt.instance;

    setUp(() {
      fakeLogger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(fakeLogger);
      }
      parser = DistrictMovieParser(logger: fakeLogger);
    });

    tearDown(getIt.reset);

    group('canParse', () {
      test('returns true for District + Zomato text', () {
        expect(
          parser.canParse('district BY ZOMATO\nProject Hail Mary'),
          isTrue,
        );
      });

      test('returns false for unrelated text', () {
        expect(parser.canParse('TNSTC PNR T123'), isFalse);
        expect(parser.canParse('BookMyShow ticket'), isFalse);
      });
    });

    group('parseTicketFromBlocks', () {
      test('parses trahkmr ticket', () async {
        final blocks = DistrictLayoutFixtures.trahkmr;
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        const expected = DistrictLayoutFixtures.trahkmrExpected;

        expect(ticket, isNotNull);
        expect(ticket!.ticketId, expected['bookingId']);
        expect(ticket.primaryText, expected['movieName']);
        expect(ticket.type, TicketType.event);
        expect(ticket.location, contains('PVR VR Mall'));

        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime?.year, expected['showYear']);
        expect(ticket.startTime?.month, expected['showMonth']);
        expect(ticket.startTime?.day, expected['showDay']);
        expect(ticket.startTime?.hour, expected['showHour']);
        expect(ticket.startTime?.minute, expected['showMinute']);

        final extrasMap = <String, String>{
          for (final e in ticket.extras ?? <ExtrasModel>[])
            if (e.title != null) e.title!: e.value ?? '',
        };

        expect(extrasMap['Booking ID'], expected['bookingId']);
        expect(extrasMap['Screen'], expected['screen']);
        expect(extrasMap['Seats'], expected['seats']);
        // Provider may be tag or extra depending on fromMovie
        expect(
          ticket.tags?.any((t) => t.value == expected['provider']) ?? false,
          isTrue,
        );
      });

      test('parses tdahhpy ticket', () async {
        final blocks = DistrictLayoutFixtures.tdahhpy;
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        const expected = DistrictLayoutFixtures.tdahhpyExpected;

        expect(ticket, isNotNull);
        expect(ticket!.ticketId, expected['bookingId']);
        expect(ticket.primaryText, expected['movieName']);
        expect(ticket.type, TicketType.event);
        expect(ticket.location, contains('PVR VR Mall'));

        expect(ticket.startTime, isNotNull);
        expect(ticket.startTime?.year, expected['showYear']);
        expect(ticket.startTime?.month, expected['showMonth']);
        expect(ticket.startTime?.day, expected['showDay']);
        expect(ticket.startTime?.hour, expected['showHour']);
        expect(ticket.startTime?.minute, expected['showMinute']);

        final extrasMap = <String, String>{
          for (final e in ticket.extras ?? <ExtrasModel>[])
            if (e.title != null) e.title!: e.value ?? '',
        };

        expect(extrasMap['Booking ID'], expected['bookingId']);
        expect(extrasMap['Screen'], expected['screen']);
        expect(extrasMap['Seats'], expected['seats']);
      });

      test('returns null when movie title band is missing', () async {
        // Only logo + booking id – no title between header and rating
        final blocks = [
          ...DistrictLayoutFixtures.trahkmr.where(
            (b) => b.text != 'Project Hail Mary',
          ),
        ];
        // If your parser requires movieName, this should be null
        final ticket = await parser.parseTicketFromBlocks(blocks, '');
        expect(ticket, isNull);
      });
    });
  });
}
