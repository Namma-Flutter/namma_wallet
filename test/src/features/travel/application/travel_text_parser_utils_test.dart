import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/travel/application/travel_text_parser_utils.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  group('TravelTextParserUtils Tests', () {
    late FakeLogger fakeLogger;

    setUp(() {
      fakeLogger = FakeLogger();
    });

    group('extractMatch - Success Scenarios', () {
      test(
        'Given valid pattern and input with match, When extracting match, '
        'Then returns matched group',
        () {
          // Arrange (Given)
          const pattern = r'PNR NO\.\s*:\s*([A-Z0-9]+)';
          const input = 'PNR NO. : T12345678';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(pattern, input);

          // Assert (Then)
          expect(result, equals('T12345678'));
        },
      );

      test(
        'Given pattern with multiple groups, When extracting specific group, '
        'Then returns correct group',
        () {
          // Arrange (Given)
          const pattern = r'From\s*:\s*([A-Z]+)\s*To\s*:\s*([A-Z]+)';
          const input = 'From : CHENNAI To : BANGALORE';

          // Act (When)
          final result1 = TravelTextParserUtils.extractMatch(
            pattern,
            input,
            groupIndex: 1,
          );
          final result2 = TravelTextParserUtils.extractMatch(
            pattern,
            input,
            groupIndex: 2,
          );

          // Assert (Then)
          expect(result1, equals('CHENNAI'));
          expect(result2, equals('BANGALORE'));
        },
      );

      test(
        'Given case-insensitive pattern, When extracting match, '
        'Then matches regardless of case',
        () {
          // Arrange (Given)
          const pattern = r'tnstc';
          const input = 'TNSTC Bus Ticket';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(
            pattern,
            input,
            groupIndex: 0,
          );

          // Assert (Then)
          expect(result, equals('TNSTC'));
        },
      );

      test(
        'Given multiline input, When extracting match, '
        'Then finds match across lines',
        () {
          // Arrange (Given)
          const pattern = r'PNR\s*:\s*([A-Z0-9]+)';
          const input = 'Line 1\nPNR : T123\nLine 3';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(pattern, input);

          // Assert (Then)
          expect(result, equals('T123'));
        },
      );

      test(
        'Given match with whitespace, When extracting match, '
        'Then trims whitespace',
        () {
          // Arrange (Given)
          const pattern = r'Name\s*:\s*([A-Za-z\s]+)';
          const input = 'Name :   John Doe   ';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(pattern, input);

          // Assert (Then)
          expect(result, equals('John Doe'));
        },
      );
    });

    group('extractMatch - Error Scenarios', () {
      test(
        'Given pattern with no match, When extracting match, '
        'Then returns empty string',
        () {
          // Arrange (Given)
          const pattern = r'PNR\s*:\s*([A-Z0-9]+)';
          const input = 'No PNR here';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(pattern, input);

          // Assert (Then)
          expect(result, equals(''));
        },
      );

      test(
        'Given invalid group index, When extracting match, '
        'Then returns empty string',
        () {
          // Arrange (Given)
          const pattern = r'PNR\s*:\s*([A-Z0-9]+)';
          const input = 'PNR : T123';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(
            pattern,
            input,
            groupIndex: 5,
          );

          // Assert (Then)
          expect(result, equals(''));
        },
      );

      test(
        'Given empty input, When extracting match, '
        'Then returns empty string',
        () {
          // Arrange (Given)
          const pattern = r'PNR\s*:\s*([A-Z0-9]+)';
          const input = '';

          // Act (When)
          final result = TravelTextParserUtils.extractMatch(pattern, input);

          // Assert (Then)
          expect(result, equals(''));
        },
      );
    });

    group('parseDate - Success Scenarios', () {
      test(
        'Given date in DD/MM/YYYY format, When parsing date, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateStr = '15/12/2024';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.day, equals(15));
          expect(result.month, equals(12));
          expect(result.year, equals(2024));
        },
      );

      test(
        'Given date in DD-MM-YYYY format, When parsing date, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateStr = '25-06-2025';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.day, equals(25));
          expect(result.month, equals(6));
          expect(result.year, equals(2025));
        },
      );

      test(
        'Given date with single digit day and month, When parsing date, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateStr = '1/3/2024';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.day, equals(1));
          expect(result.month, equals(3));
          expect(result.year, equals(2024));
        },
      );
    });

    group('parseDate - Error Scenarios', () {
      test(
        'Given empty date string, When parsing date, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateStr = '';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given invalid date format, When parsing date, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateStr = '2024-12-15'; // Wrong format

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given date with invalid parts, When parsing date, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateStr = 'XX/12/2024';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given date with only two parts, When parsing date, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateStr = '15/12';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );
    });

    group('parseDateTime - Success Scenarios', () {
      test(
        'Given datetime in DD/MM/YYYY HH:mm format, When parsing datetime, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateTimeStr = '15/12/2024 14:30';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.day, equals(15));
          expect(result.month, equals(12));
          expect(result.year, equals(2024));
          expect(result.hour, equals(14));
          expect(result.minute, equals(30));
        },
      );

      test(
        'Given datetime in DD-MM-YYYY HH:mm format, When parsing datetime, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateTimeStr = '25-06-2025 09:15';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.day, equals(25));
          expect(result.month, equals(6));
          expect(result.year, equals(2025));
          expect(result.hour, equals(9));
          expect(result.minute, equals(15));
        },
      );

      test(
        'Given datetime with "Hrs." suffix, When parsing datetime, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateTimeStr = '15/12/2024 14:30 Hrs.';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.hour, equals(14));
          expect(result.minute, equals(30));
        },
      );

      test(
        'Given datetime with midnight time, When parsing datetime, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateTimeStr = '01/01/2024 00:00';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.hour, equals(0));
          expect(result.minute, equals(0));
        },
      );
    });

    group('parseDateTime - Error Scenarios', () {
      test(
        'Given empty datetime string, When parsing datetime, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateTimeStr = '';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given datetime with missing time part, When parsing datetime, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateTimeStr = '15/12/2024';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given datetime with invalid time format, When parsing datetime, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateTimeStr = '15/12/2024 14';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );

      test(
        'Given datetime with invalid date part, When parsing datetime, '
        'Then returns null',
        () {
          // Arrange (Given)
          const dateTimeStr = 'XX/12/2024 14:30';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNull);
        },
      );
    });

    group('parseInt - Success Scenarios', () {
      test(
        'Given valid integer string, When parsing int, '
        'Then returns correct integer',
        () {
          // Arrange (Given)
          const value = '12345';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(12345));
        },
      );

      test(
        'Given negative integer string, When parsing int, '
        'Then returns correct negative integer',
        () {
          // Arrange (Given)
          const value = '-42';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(-42));
        },
      );

      test(
        'Given zero string, When parsing int, '
        'Then returns zero',
        () {
          // Arrange (Given)
          const value = '0';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(0));
        },
      );
    });

    group('parseInt - Error Scenarios', () {
      test(
        'Given empty string, When parsing int, '
        'Then returns default value',
        () {
          // Arrange (Given)
          const value = '';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(0));
        },
      );

      test(
        'Given invalid integer string, When parsing int, '
        'Then returns default value',
        () {
          // Arrange (Given)
          const value = 'abc';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(0));
        },
      );

      test(
        'Given invalid integer with custom default, When parsing int, '
        'Then returns custom default value',
        () {
          // Arrange (Given)
          const value = 'xyz';
          const defaultValue = 999;

          // Act (When)
          final result = TravelTextParserUtils.parseInt(
            value,
            defaultValue: defaultValue,
          );

          // Assert (Then)
          expect(result, equals(999));
        },
      );

      test(
        'Given double string, When parsing int, '
        'Then returns default value',
        () {
          // Arrange (Given)
          const value = '12.34';

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(0));
        },
      );
    });

    group('parseDouble - Success Scenarios', () {
      test(
        'Given valid double string, When parsing double, '
        'Then returns correct double',
        () {
          // Arrange (Given)
          const value = '123.45';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(123.45));
        },
      );

      test(
        'Given integer string, When parsing double, '
        'Then returns correct double',
        () {
          // Arrange (Given)
          const value = '100';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(100.0));
        },
      );

      test(
        'Given negative double string, When parsing double, '
        'Then returns correct negative double',
        () {
          // Arrange (Given)
          const value = '-42.5';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(-42.5));
        },
      );

      test(
        'Given zero string, When parsing double, '
        'Then returns zero',
        () {
          // Arrange (Given)
          const value = '0.0';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(0.0));
        },
      );
    });

    group('parseDouble - Error Scenarios', () {
      test(
        'Given empty string, When parsing double, '
        'Then returns default value',
        () {
          // Arrange (Given)
          const value = '';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(0.0));
        },
      );

      test(
        'Given invalid double string, When parsing double, '
        'Then returns default value',
        () {
          // Arrange (Given)
          const value = 'abc';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(0.0));
        },
      );

      test(
        'Given invalid double with custom default, When parsing double, '
        'Then returns custom default value',
        () {
          // Arrange (Given)
          const value = 'xyz';
          const defaultValue = 99.9;

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(
            value,
            defaultValue: defaultValue,
          );

          // Assert (Then)
          expect(result, equals(99.9));
        },
      );
    });

    group('Edge Cases and Boundary Conditions', () {
      test(
        'Given date at year boundary, When parsing date, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateStr = '31/12/9999';

          // Act (When)
          final result = TravelTextParserUtils.parseDate(
            dateStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.year, equals(9999));
        },
      );

      test(
        'Given datetime at day boundary, When parsing datetime, '
        'Then returns correct DateTime',
        () {
          // Arrange (Given)
          const dateTimeStr = '31/12/2024 23:59';

          // Act (When)
          final result = TravelTextParserUtils.parseDateTime(
            dateTimeStr,
            logger: fakeLogger,
          );

          // Assert (Then)
          expect(result, isNotNull);
          expect(result!.hour, equals(23));
          expect(result.minute, equals(59));
        },
      );

      test(
        'Given very large integer string, When parsing int, '
        'Then returns correct large integer',
        () {
          // Arrange (Given)
          const value = '2147483647'; // Max 32-bit int

          // Act (When)
          final result = TravelTextParserUtils.parseInt(value);

          // Assert (Then)
          expect(result, equals(2147483647));
        },
      );

      test(
        'Given very small double, When parsing double, '
        'Then returns correct small double',
        () {
          // Arrange (Given)
          const value = '0.00001';

          // Act (When)
          final result = TravelTextParserUtils.parseDouble(value);

          // Assert (Then)
          expect(result, equals(0.00001));
        },
      );
    });
  });
}
