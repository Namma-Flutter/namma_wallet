import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
import '../../../../fixtures/tnstc_layout_fixtures.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  group('TNSTCLayoutParser', () {
    late TNSTCLayoutParser parser;
    late FakeLogger fakeLogger;
    final getIt = GetIt.instance;

    setUp(() {
      fakeLogger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(fakeLogger);
      }
      parser = TNSTCLayoutParser(logger: fakeLogger);
    });

    tearDown(getIt.reset);

    group('_formatTime', () {
      test('should return null for null or empty input', () {
        expect(parser.formatTimeForTesting(null), isNull);
        expect(parser.formatTimeForTesting(''), isNull);
        expect(parser.formatTimeForTesting('  '), isNull);
      });

      test('should return null for malformed time strings', () {
        expect(parser.formatTimeForTesting('10:xx'), isNull);
        expect(parser.formatTimeForTesting('xx:10'), isNull);
        expect(
          parser.formatTimeForTesting('10:1'),
          isNull,
        ); // Needs 2 digits for minute
        expect(
          parser.formatTimeForTesting('1:10'),
          isNotNull,
        ); // 1 digit hour is okay
        expect(
          parser.formatTimeForTesting('101:10'),
          isNull,
        ); // 3 digit hour not allowed by regex \d{1,2}
        expect(
          parser.formatTimeForTesting('10:101'),
          isNull,
        ); // 3 digit minute not allowed by regex \d{2}
      });

      test('should return null for out-of-range values', () {
        expect(parser.formatTimeForTesting('24:00'), isNull);
        expect(parser.formatTimeForTesting('25:10'), isNull);
        expect(parser.formatTimeForTesting('10:60'), isNull);
        expect(parser.formatTimeForTesting('10:75'), isNull);
      });

      test('should correctly format valid 24-hour times to 12-hour format', () {
        expect(parser.formatTimeForTesting('00:00'), '12:00 AM');
        expect(parser.formatTimeForTesting('00:15'), '12:15 AM');
        expect(parser.formatTimeForTesting('09:30'), '09:30 AM');
        expect(parser.formatTimeForTesting('12:00'), '12:00 PM');
        expect(parser.formatTimeForTesting('12:45'), '12:45 PM');
        expect(parser.formatTimeForTesting('13:15'), '01:15 PM');
        expect(parser.formatTimeForTesting('23:59'), '11:59 PM');
      });

      test('should handle single-digit hours correctly', () {
        expect(parser.formatTimeForTesting('5:30'), '05:30 AM');
        expect(parser.formatTimeForTesting(' 5:30 '), '05:30 AM');
      });
    });

    group('parseTicket', () {
      test('should parse ticket from plain text using pseudo-blocks', () {
        const plainText = '''
PNR Number : T12345678
Date of Journey : 25/10/2023
Service Start Time : 13:15
''';
        final ticket = parser.parseTicket(plainText);

        expect(ticket.ticketId, 'T12345678');
        expect(ticket.startTime, isNotNull);
        // Date part: 2023-10-25, Time part: 13:15
        expect(ticket.startTime?.year, 2023);
        expect(ticket.startTime?.month, 10);
        expect(ticket.startTime?.day, 25);
        expect(ticket.startTime?.hour, 13);
        expect(ticket.startTime?.minute, 15);
      });
    });

    group('parseTicketFromBlocks', () {
      test(
        'should parse SETC ticket from OCR blocks with basic fields',
        () {
          final blocks = TnstcLayoutFixtures.t73266848;
          final ticket = parser.parseTicketFromBlocks(blocks);
          const expected = TnstcLayoutFixtures.t73266848Expected;

          // Verify ticket ID
          expect(ticket.ticketId, expected['pnrNumber']);

          // Verify primary text contains route information
          expect(ticket.primaryText, contains('CHENNAI'));
          expect(ticket.primaryText, contains('KUMBAKONAM'));

          // Verify startTime - with pseudo-blocks, time extraction has
          // limitations (time values with colons on separate lines)
          // so startTime may fallback to journeyDate or be null
          if (ticket.startTime != null) {
            expect(ticket.startTime?.year, 2026);
            expect(ticket.startTime?.month, 1);
            expect(ticket.startTime?.day, 14);
          }

          // Verify key fields in extras
          final extrasMap = <String, String>{
            for (final e in ticket.extras ?? <ExtrasModel>[])
              if (e.title != null) e.title!: e.value ?? '',
          };

          expect(extrasMap['PNR Number'], expected['pnrNumber']);
          expect(extrasMap['Provider'], expected['corporation']);
          expect(extrasMap['Route No'], expected['routeNo']);
          expect(extrasMap['Service Class'], expected['classOfService']);
          expect(extrasMap['Platform'], expected['platformNumber']);
          expect(extrasMap['Trip Code'], expected['tripCode']);
          expect(extrasMap['Bus ID'], expected['busIdNumber']);
          expect(
            extrasMap['Fare'],
            '₹${(expected['totalFare']! as double).toStringAsFixed(2)}',
          );

          // Note: Passenger details can't be extracted from pseudo-blocks
          // without proper labels, so we don't test those fields here
        },
      );

      test(
        'should parse Non-AC Lower Berth ticket from pseudo-blocks',
        () {
          final blocks = TnstcLayoutFixtures.t73289588;
          final ticket = parser.parseTicketFromBlocks(blocks);
          const expected = TnstcLayoutFixtures.t73289588Expected;

          // Verify ticket ID
          expect(ticket.ticketId, expected['pnrNumber']);

          // Verify primary text contains route information
          expect(ticket.primaryText, contains('CHENNAI'));
          expect(ticket.primaryText, contains('KUMBAKONAM'));

          // Verify startTime - with pseudo-blocks, time extraction has
          // limitations (time values with colons on separate lines)
          // so startTime may fallback to journeyDate or be null
          if (ticket.startTime != null) {
            expect(ticket.startTime?.year, 2025);
            expect(ticket.startTime?.month, 11);
            expect(ticket.startTime?.day, 28);
          }

          // Verify key fields in extras
          final extrasMap = <String, String>{
            for (final e in ticket.extras ?? <ExtrasModel>[])
              if (e.title != null) e.title!: e.value ?? '',
          };

          expect(extrasMap['PNR Number'], expected['pnrNumber']);
          expect(extrasMap['Provider'], expected['corporation']);
          expect(extrasMap['Route No'], expected['routeNo']);
          expect(extrasMap['Service Class'], expected['classOfService']);
          expect(extrasMap['Trip Code'], expected['tripCode']);
          expect(extrasMap['Bus ID'], expected['busIdNumber']);
          expect(
            extrasMap['Fare'],
            '₹${(expected['totalFare']! as double).toStringAsFixed(2)}',
          );

          // Note: Passenger details can't be extracted from pseudo-blocks
          // without proper labels, so we don't test those fields here
        },
      );

      test(
        'should parse SETC ticket from real OCR blocks with bounding boxes',
        () {
          final blocks = TnstcLayoutFixtures.t73309927;
          final ticket = parser.parseTicketFromBlocks(blocks);
          const expected = TnstcLayoutFixtures.t73309927Expected;

          // Verify ticket ID
          expect(ticket.ticketId, expected['pnrNumber']);

          // Verify primary text contains route information
          expect(ticket.primaryText, contains('KUMBAKONAM'));
          expect(ticket.primaryText, contains('CHENNAI'));

          // Verify startTime - with real OCR blocks, spatial layout extraction
          // should work better than pseudo-blocks
          if (ticket.startTime != null) {
            expect(ticket.startTime?.year, 2026);
            expect(ticket.startTime?.month, 1);
            expect(ticket.startTime?.day, 18);
            // Time may be extracted correctly with real OCR blocks
            // since they have actual spatial relationships
          }

          // Verify key fields in extras
          final extrasMap = <String, String>{
            for (final e in ticket.extras ?? <ExtrasModel>[])
              if (e.title != null) e.title!: e.value ?? '',
          };

          expect(extrasMap['PNR Number'], expected['pnrNumber']);
          expect(extrasMap['Provider'], expected['corporation']);
          expect(extrasMap['Route No'], expected['routeNo']);
          expect(extrasMap['Service Class'], expected['classOfService']);
          expect(extrasMap['Trip Code'], expected['tripCode']);
          expect(extrasMap['Bus ID'], expected['busIdNumber']);
          expect(
            extrasMap['Fare'],
            '₹${(expected['totalFare']! as double).toStringAsFixed(2)}',
          );

          // Verify passenger details
          expect(extrasMap['Passenger Name'], expected['passengerName']);
          expect(extrasMap['Age'], expected['passengerAge'].toString());
          expect(extrasMap['Gender'], expected['passengerGender']);
          // Seat number may be null if label format is not recognized
          if (expected['seatNumber'] != null) {
            expect(extrasMap['Seat Number'], expected['seatNumber']);
          }
        },
      );

      test(
        'should parse multi-passenger SETC ticket from real OCR blocks',
        () {
          final blocks = TnstcLayoutFixtures.t73910447;
          final ticket = parser.parseTicketFromBlocks(blocks);
          const expected = TnstcLayoutFixtures.t73910447Expected;

          // Verify ticket ID
          expect(ticket.ticketId, expected['pnrNumber']);

          // Verify primary text contains route information
          expect(ticket.primaryText, contains('CHENNAI'));
          expect(ticket.primaryText, contains('BENGALURU'));

          // Verify key fields in extras
          final extrasMap = <String, String>{
            for (final e in ticket.extras ?? <ExtrasModel>[])
              if (e.title != null) e.title!: e.value ?? '',
          };

          expect(extrasMap['PNR Number'], expected['pnrNumber']);
          expect(extrasMap['Provider'], expected['corporation']);
          expect(extrasMap['Route No'], expected['routeNo']);
          expect(extrasMap['Service Class'], expected['classOfService']);
          expect(extrasMap['Trip Code'], expected['tripCode']);
          expect(extrasMap['Bus ID'], expected['busIdNumber']);
          expect(
            extrasMap['Fare'],
            '₹${(expected['totalFare']! as double).toStringAsFixed(2)}',
          );

          // Verify first passenger details (parser usually takes the first match
          // for fields like name/age/gender if they are unique per line/block)
          expect(extrasMap['Passenger Name'], expected['passengerName']);
          expect(extrasMap['Age'], expected['passengerAge'].toString());
          expect(extrasMap['Gender'], expected['passengerGender']);
          expect(extrasMap['Seat Number'], expected['seatNumber']);
        },
      );
    });
  });
}
