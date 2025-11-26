import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_pdf_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';

import '../../../../helpers/fake_logger.dart';

void main() {
  group('TravelPDFParser', () {
    late TravelPDFParser parser;
    late FakeLogger fakeLogger;

    setUp(() {
      fakeLogger = FakeLogger();
      parser = TNSTCPDFParser(logger: fakeLogger);
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
    });
  });
}
