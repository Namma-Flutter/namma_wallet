import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  group('TNSTCLayoutParser', () {
    late TNSTCLayoutParser parser;
    late FakeLogger fakeLogger;

    setUp(() {
      fakeLogger = FakeLogger();
      parser = TNSTCLayoutParser(logger: fakeLogger);
    });

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
  });
}
