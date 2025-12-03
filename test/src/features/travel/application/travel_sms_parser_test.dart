import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_sms_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_sms_parser.dart';

void main() {
  group('TravelSMSParser', () {
    late TravelSMSParser parser;

    setUp(() {
      parser = TNSTCSMSParser();
    });

    group('parseInt', () {
      test('should return the parsed integer for a valid string', () {
        // Arrange
        const value = '123';
        // Act
        final result = parser.parseInt(value);
        // Assert
        expect(result, 123);
      });

      test('should return the default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseInt(value);
        // Assert
        expect(result, 0);
      });

      test('should return the custom default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseInt(value, defaultValue: -1);
        // Assert
        expect(result, -1);
      });
      test('should parse negative integers', () {
        expect(parser.parseInt('-123'), -123);
      });

      test('should handle whitespace', () {
        expect(parser.parseInt(' 123 '), 123);
      });
    });

    group('parseDouble', () {
      test('should return the parsed double for a valid string', () {
        // Arrange
        const value = '123.45';
        // Act
        final result = parser.parseDouble(value);
        // Assert
        expect(result, 123.45);
      });

      test('should return the default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseDouble(value);
        // Assert
        expect(result, 0.0);
      });

      test('should return the custom default value for an invalid string', () {
        // Arrange
        const value = 'abc';
        // Act
        final result = parser.parseDouble(value, defaultValue: -1);
        // Assert
        expect(result, -1.0);
      });
      test('should parse negative doubles', () {
        expect(parser.parseDouble('-123.45'), -123.45);
      });

      test('should parse scientific notation if supported', () {
        expect(parser.parseDouble('1.23e2'), 123.0);
      });
    });

    group('parseDate', () {
      test(
        'should return null for an invalid date string (FormatException)',
        () {
          // Arrange
          const value = 'XX/YY/ZZZZ'; // Invalid format for parsing
          // Act
          final result = parser.parseDate(value);
          // Assert
          expect(result, isNull);
        },
      );

      test(
        'should return null for a date string with incorrect parts count',
        () {
          // Arrange
          const value = '01/01'; // Missing year part
          // Act
          final result = parser.parseDate(value);
          // Assert
          expect(result, isNull);
        },
      );

      test('should return null for an empty date string', () {
        // Arrange
        const value = '';
        // Act
        final result = parser.parseDate(value);
        // Assert
        expect(result, isNull);
      });

      test(
        'should return a valid DateTime for a valid date string (DD/MM/YYYY)',
        () {
          // Arrange
          const value = '25/12/2023';
          // Act
          final result = parser.parseDate(value);
          // Assert
          expect(result, isNotNull);
          expect(result!.year, 2023);
          expect(result.month, 12);
          expect(result.day, 25);
        },
      );

      test(
        'should return a valid DateTime for a valid date string with single digit month/day',
        () {
          // Arrange
          const value = '5/1/2023';
          // Act
          final result = parser.parseDate(value);
          // Assert
          expect(result, isNotNull);
          expect(result!.year, 2023);
          expect(result.month, 1);
          expect(result.day, 5);
        },
      );
      test('should handle leap year dates', () {
        final leapYear = parser.parseDate('29/02/2024');
        expect(leapYear, isNotNull);
        expect(leapYear!.day, 29);
        expect(leapYear.month, 2);
      });
    });
  });
}
