import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/features/tnstc/application/tnstc_layout_parser.dart';
import 'package:namma_wallet/src/features/travel/application/travel_pdf_parser.dart';
import '../../../../helpers/fake_logger.dart';

void main() {
  group('TravelPDFParser', () {
    late TravelPDFParser parser;
    late FakeLogger fakeLogger;

    setUp(() {
      fakeLogger = FakeLogger();
      // Using TNSTCLayoutParser as it extends TravelPDFParser
      parser = TNSTCLayoutParser(logger: fakeLogger);
    });

    group('extractMatch', () {
      test('should return the matched group for a valid regex', () {
        // Arrange
        const pdfText = 'PNR Number : T12345678';
        const regex = r'PNR Number\s*:\s*(\w+)';
        // Act
        final result = parser.extractMatch(regex, pdfText);
        // Assert
        expect(result, 'T12345678');
      });

      test('should return an empty string for a non-matching regex', () {
        // Arrange
        const pdfText = 'PNR Number : T12345678';
        const regex = r'Ticket ID\s*:\s*(\w+)';
        // Act
        final result = parser.extractMatch(regex, pdfText);
        // Assert
        expect(result, '');
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
