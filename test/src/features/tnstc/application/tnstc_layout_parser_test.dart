import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
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
  });
}
